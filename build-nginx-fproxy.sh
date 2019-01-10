#!/usr/bin/env bash
# Run as root or with sudo
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root or with sudo."
  exit 1
fi

# Make script exit if a simple command fails and
# Make script print commands being executed
set -e -x

# Set names of latest versions of each package
version_pcre=pcre-8.42
version_zlib=zlib-1.2.11
version_openssl=openssl-1.1.1a
version_nginx=nginx-1.15.8

# See https://github.com/chobits/ngx_http_proxy_connect_module#install for patch/NGINX version
proxy_patch_file=proxy_connect_rewrite_1015.patch

# Set checksums of latest versions
sha256_pcre=69acbc2fbdefb955d42a4c606dfde800c2885711d2979e356c0636efde9ec3b5
sha256_zlib=c3e5e9fdd5004dcb542feda5ee4f0ff0744628baf8ed2dd5d66f8ca1197cb1a1
sha256_openssl=fc20130f8b7cbd2fb918b2f14e2f429e109c31ddd0fb38fc5d71d9ffed3f9f41
sha256_nginx=a8bdafbca87eb99813ae4fcac1ad0875bf725ce19eb265d28268c309b2b40787

# Set URLs to the source directories
source_pcre=https://ftp.pcre.org/pub/pcre/
source_zlib=https://zlib.net/
source_openssl=https://www.openssl.org/source/
source_nginx=https://nginx.org/download/

# Set where OpenSSL and NGINX will be built
bpath=$(pwd)/build

# Make a "today" variable for use in back-up filenames later
today=$(date +"%Y-%m-%d")

# Clean out any files from previous runs of this script
rm -rf \
  "$bpath" \
  /etc/nginx-default
mkdir "$bpath"

# Ensure the required software to compile NGINX is installed
apt-get update && apt-get -y install \
  binutils \
  build-essential \
  curl \
  dirmngr \
  libssl-dev

# Download the source files and verify their checksums
curl -L "${source_pcre}${version_pcre}.tar.gz" -o "${bpath}/pcre.tar.gz" && \
  echo "${sha256_pcre} ${bpath}/pcre.tar.gz" | sha256sum -c -
curl -L "${source_zlib}${version_zlib}.tar.gz" -o "${bpath}/zlib.tar.gz" && \
  echo "${sha256_zlib} ${bpath}/zlib.tar.gz" | sha256sum -c -
curl -L "${source_openssl}${version_openssl}.tar.gz" -o "${bpath}/openssl.tar.gz" && \
  echo "${sha256_openssl} ${bpath}/openssl.tar.gz" | sha256sum -c -
curl -L "${source_nginx}${version_nginx}.tar.gz" -o "${bpath}/nginx.tar.gz" && \
  echo "${sha256_nginx} ${bpath}/nginx.tar.gz" | sha256sum -c -

# Expand the source files
cd "$bpath"
for archive in ./*.tar.gz; do
  tar xzf "$archive"
done

# Clean up source files
rm -rf \
  "$bpath"/*.tar.*

# Clone HTTP proxy module
git clone https://github.com/chobits/ngx_http_proxy_connect_module.git

# Rename the existing /etc/nginx directory so it's saved as a back-up
if [ -d "/etc/nginx" ]; then
  mv /etc/nginx "/etc/nginx-${today}"
fi

# Create NGINX cache directories if they do not already exist
if [ ! -d "/var/cache/nginx/" ]; then
  mkdir -p \
    /var/cache/nginx/client_temp \
    /var/cache/nginx/proxy_temp \
    /var/cache/nginx/fastcgi_temp \
    /var/cache/nginx/uwsgi_temp \
    /var/cache/nginx/scgi_temp
fi

# Add NGINX group and user if they do not already exist
id -g nginx &>/dev/null || addgroup --system nginx
id -u nginx &>/dev/null || adduser --disabled-password --system --home /var/cache/nginx --shell /sbin/nologin --group nginx

# Patch then configure NGINX with various modules included/excluded
cd "$bpath/$version_nginx"
patch -p1 < $bpath/ngx_http_proxy_connect_module/patch/$proxy_patch_file
./configure \
  --prefix=/etc/nginx \
  --with-pcre="$bpath/$version_pcre" \
  --with-zlib="$bpath/$version_zlib" \
  --with-openssl="$bpath/$version_openssl" \
  --sbin-path=/usr/sbin/nginx \
  --modules-path=/usr/lib/nginx/modules \
  --conf-path=/etc/nginx/nginx.conf \
  --error-log-path=/var/log/nginx/error.log \
  --http-log-path=/var/log/nginx/access.log \
  --pid-path=/var/run/nginx.pid \
  --lock-path=/var/run/nginx.lock \
  --http-client-body-temp-path=/var/cache/nginx/client_temp \
  --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
  --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
  --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
  --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
  --user=nginx \
  --group=nginx \
  --with-stream \
  --with-stream_ssl_module \
  --with-stream_ssl_preread_module \
  --add-module="$bpath/ngx_http_proxy_connect_module" \
  --with-threads \
  --without-http_empty_gif_module \
  --without-http_geo_module \
  --without-http_split_clients_module \
  --without-http_ssi_module \
  --without-mail_imap_module \
  --without-mail_pop3_module \
  --without-mail_smtp_module
make
make install
make clean
strip -s /usr/sbin/nginx*

# Install man pages
cp "$bpath/$version_nginx/man/nginx.8" /usr/share/man/man8
gzip /usr/share/man/man8/nginx.8

if [ -d "/etc/nginx-${today}" ]; then
  # Rename the default /etc/nginx settings directory so it's accessible as a reference to the new NGINX defaults
  mv /etc/nginx /etc/nginx-default

  # Restore the previous version of /etc/nginx to /etc/nginx so the old settings are kept
  mv "/etc/nginx-${today}" /etc/nginx
fi

# Create NGINX systemd service file if it does not already exist
if [ ! -e "/lib/systemd/system/nginx.service" ]; then
  # Control will enter here if the NGINX service doesn't exist.
  file="/lib/systemd/system/nginx.service"

  /bin/cat >$file <<'EOF'
[Unit]
Description=The NGINX reverse and forward proxy server
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/var/run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t
ExecStart=/usr/sbin/nginx
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
fi

echo "All done.";
echo "Start with sudo systemctl start nginx"
echo "or with sudo nginx"
