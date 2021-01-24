# vi: ft=dockerfile
FROM "blinc/void.rootfs"

COPY ["src/xbps", "/etc/xbps.d"]
RUN ["chmod", "4774", "/etc/xbps.d"]

RUN ["xbps-install", "-Suy", "xbps"]
RUN ["xbps-install", "-uy"]
RUN ["xbps-install", "-y", "base-system", "base-devel", "curl", "git"]
RUN ["xbps-reconfigure", "-f", "glibc-locales"]

RUN ["useradd", "-r", "void-pkgs"]

ENV "LANG"="en_US.UTF-8"
SHELL ["/bin/bash"]
CMD ["/bin/bash"]
