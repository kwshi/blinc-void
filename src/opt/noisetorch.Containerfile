# vi: ft=dockerfile
FROM blinc/void.base

WORKDIR "/opt/blinc/noisetorch"
RUN ["chown", "root:wheel", "."]
RUN ["chmod", "2775", "."]

ENV "NOISETORCH_URL"="https://github.com/lawl/NoiseTorch/releases/download/0.10.0/"
ADD ["$NOISETORCH_URL/NoiseTorch_x64.tgz", "noisetorch.tgz"]
RUN ["tar", "-xz", "--strip-components", "1", "-f", "noisetorch.tgz"]
