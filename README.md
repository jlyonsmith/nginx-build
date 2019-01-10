# `nginx` Forward Proxy Build Script

This is a build script for creating a version of `nginx` that can be used as a forward HTTPS and SSH proxy. It incorporates [chobits/ngx_http_proxy_connect_module](https://github.com/chobits/ngx_http_proxy_connect_module.git) on an Ubuntu machine.

We build to `/usr/sbin`, so this script is not intended for running simultaneously with an `apt` installed version of `nginx`.

## Usage

NOTE: Always review downloaded scripts before executing.

### Installation & Upgrade

1. `sudo mkdir /usr/local/src/nginx/`
2. `cd /usr/local/src/nginx/`
3. `sudo rm /usr/local/src/nginx/nginx-build-fproxy.sh`
4. `sudo curl -L https://raw.githubusercontent.com/jlyonsmith/nginx-build-fproxy/master/build-nginx-fproxy.sh -o build-nginx-fproxy.sh`
5. `sudo chmod +x build-nginx-fproxy.sh`
6. `sudo kill -QUIT $( cat /var/run/nginx.pid )`
7. `sudo ./build-nginx-fproxy.sh`
8. `sudo nginx`

## Acknowledgments

The script was originally based on the [build-nginx.sh](https://gist.github.com/MattWilcox/402e2e8aa2e1c132ee24) script from [@MatthewVance](https://github.com/MatthewVance), but revised to create `nginx` as a forward proxy.

## License

Unless otherwise specified, all code is released under the MIT License (MIT). See the [repository's `LICENSE` file](https://github.com/jlyonsmith/nginx-build/blob/master/LICENSE) for details.

## References

- [How to Build Nginx from Source](https://www.howtoforge.com/tutorial/how-to-build-nginx-from-source-on-ubuntu-1804-lts/)
- [Running SSL and Non-SSL Protocols Over the Same Port](https://www.nginx.com/blog/running-non-ssl-protocols-over-ssl-port-nginx-1-15-2/)
- [Nginx ngx_stream_core_module](https://nginx.org/en/docs/stream/ngx_stream_core_module.html#resolver)
- [TCP Load Balancing with Nginx](https://serversforhackers.com/c/tcp-load-balancing-with-nginx-ssl-pass-thru)
- [SSH Proxy Command Example](https://www.cyberciti.biz/faq/linux-unix-ssh-proxycommand-passing-through-one-host-gateway-server/)
