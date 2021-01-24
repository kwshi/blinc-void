# vi: ft=dockerfile
FROM "blinc/void.base"

WORKDIR "/opt/blinc/elm"
RUN ["chown", "root:wheel", "."]
RUN ["chmod", "4755"      , "."]

WORKDIR "bin"
ENV "ELM_URL"="https://github.com/elm/compiler/releases/download/0.19.1"
ADD ["$ELM_URL/binary-for-linux-64-bit.gz", "elm.gz"]
RUN ["gunzip", "elm.gz"]
RUN ["chmod", "+x", "elm"]
