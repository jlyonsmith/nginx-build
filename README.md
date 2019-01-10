# `nginx` Forward Proxy Build Script

This is a build script for creating a version of `nginx` that can be used as a forward HTTPS and SSH proxy. It incorporates [chobits/ngx_http_proxy_connect_module](https://github.com/chobits/ngx_http_proxy_connect_module.git) on an Ubuntu machine.

We build to `/usr/sbin`, so this script is not intended for running simultaneously with an `apt` installed version of `nginx`.

## Usage

NOTE: Always review downloaded scripts before executing.

### Installation

1. `sudo mkdir /usr/local/src/nginx/`
2. `cd /usr/local/src/nginx/`
3. `sudo curl -L https://raw.githubusercontent.com/jlyonsmith/nginx-build-fproxy/master/build-nginx-fproxy.sh -o nginx-build-fproxy.sh`
4. `cat nginx-build-fproxy.sh`
5. `sudo chmod +x nginx-build-fproxy.sh`
6. `sudo ./nginx-build-fproxy.sh`
7. `sudo nginx`

### Upgrading

1. `cd /usr/local/src/nginx/`
2. `sudo rm /usr/local/src/nginx/nginx-build-fproxy.sh`
3. `sudo curl -L https://raw.githubusercontent.com/jlyonsmith/nginx-build-fproxy/master/build-nginx-fproxy.sh -o nginx-build-fproxy.sh`
4. `cat nginx-build-fproxy.sh`
5. `sudo chmod +x nginx-build-fproxy.sh`
6. `sudo kill -QUIT $( cat /var/run/nginx.pid )`
7. `sudo ./nginx-build-fproxy.sh`
8. `sudo nginx`

## Issues

If you have any problems with or questions about this image, please create a [GitHub Issue](https://github.com/jlyonsmith/nginx-build-fproxy/issues).

## Contributing

You are invited to contribute fixes and/or updates.

## Acknowledgments

The script was originally based on the [build_nginx.sh](https://gist.github.com/MattWilcox/402e2e8aa2e1c132ee24) script from [@MatthewVance](https://github.com/MatthewVance), but revised to create `nginx` as a forward proxy.

## License

Unless otherwise specified, all code is released under the MIT License (MIT). See the [repository's `LICENSE` file](https://github.com/jlyonsmith/nginx-build/blob/master/LICENSE) for details.
