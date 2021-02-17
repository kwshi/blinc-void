# vi: ft=dockerfile
FROM "blinc/void.base"

WORKDIR "/opt/blinc/vpkgs"
RUN ["chown", "vpkgs", "."]

USER "vpkgs"
RUN ["git", "clone", "https://github.com/void-linux/void-packages", "."]
RUN ["./xbps-src", "binary-bootstrap"]

RUN echo "XBPS_ALLOW_RESTRICTED"="yes" >> etc/conf

RUN ["./xbps-src", "pkg", "zoom"]
RUN ["./xbps-src", "pkg", "slack-desktop"]
#RUN ["./xbps-src", "pkg", "spotify"]
RUN ["./xbps-src", "pkg", "discord"]
