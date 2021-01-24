# vi: ft=dockerfile
FROM "blinc/void.rootfs"

COPY ["src/xbps", "/etc/xbps.d"]
RUN ["chmod", "4774", "/etc/xbps.d"]

RUN ["xbps-install", "-Suy", "xbps"]
RUN ["xbps-install", "-uy"]
RUN ["xbps-install", "-y", "base-system", "base-devel", "curl", "git"]

RUN ["useradd", "-rb", "/opt/blinc", "vpkgs"]
RUN ["useradd", "-rb", "/opt/blinc", "opam"]
RUN ["useradd", "-rb", "/opt/blinc", "npm"]
RUN ["useradd", "-rb", "/opt/blinc", "pip"]
RUN ["useradd", "-rb", "/opt/blinc", "poetry"]

CMD ["/bin/bash"]
