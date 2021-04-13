# vi: ft=dockerfile
FROM "blinc/void.base"

WORKDIR "/opt/blinc/vpkgs"
RUN ["chown", "vpkgs", "."]

USER "vpkgs"
RUN ["git", "clone", "https://github.com/void-linux/void-packages", "."]
RUN ["./xbps-src", "binary-bootstrap"]

RUN echo "XBPS_ALLOW_RESTRICTED"="yes" >> etc/conf

# dirty hack: pre-load the spotify deb with wget, b/c spotify repos are
# preposterously flaky
ENV "SPOTIFY_REPO_URL"="http://repository.spotify.com/pool/non-free/s/spotify-client"
ENV "SPOTIFY_DEB_NAME"="spotify-client_1.1.56.595.g2d2da0de_amd64.deb"
RUN wget -P "hostdir/sources/spotify-1.1.56" "$SPOTIFY_REPO_URL/$SPOTIFY_DEB_NAME"
RUN ["./xbps-src", "pkg", "spotify"]

RUN ["./xbps-src", "pkg", "zoom"]
RUN ["./xbps-src", "pkg", "slack-desktop"]
RUN ["./xbps-src", "pkg", "discord"]
