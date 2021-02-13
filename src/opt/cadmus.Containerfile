# vi: ft=dockerfile
FROM "blinc/void.base"

WORKDIR "/opt/blinc/cadmus"
RUN ["chown", "root:wheel", "."]
RUN ["chmod", "2755", "."]

ENV "CADMUS_URL"="https://github.com/josh-richardson/cadmus/releases/download"
ADD ["$CADMUS_URL/0.0.3/cadmus.zip", "cadmus-0.0.3.zip"]
RUN ["unzip", "cadmus-0.0.3.zip"]
