# vi: ft=dockerfile
FROM "blinc/void.base"

WORKDIR "/opt/blinc/deno"
RUN ["chown", "root:wheel", "."]
RUN ["chmod", "4755"      , "."]

ENV "DENO_URL"="https://github.com/denoland/deno/releases/download/v1.5.3"
ADD ["$DENO_URL/deno-x86_64-unknown-linux-gnu.zip", "deno.zip"]
RUN ["unzip", "-d", "bin", "deno.zip"]
