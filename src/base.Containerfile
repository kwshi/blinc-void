# vi: ft=dockerfile
FROM "blinc/void.rootfs"

COPY ["src/xbps/xbps.conf", "/etc/xbps/xbps.conf"]
RUN ["chmod", "4774", "/etc/xbps"]

RUN ["xbps-install", "-Suy", "xbps"]
RUN ["xbps-install", "-uy"]
RUN ["xbps-install", "-y", "base-system", "base-devel", "curl", "git"]

RUN ["useradd", "-r", "void-pkgs"]
