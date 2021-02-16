# vi: ft=dockerfile
FROM blinc/void.base

WORKDIR "/opt/blinc/breaktimer"
RUN ["chown", "root:wheel", "."]
RUN ["chmod", "2755", "."]

ENV "BREAKTIMER_URL"="https://github.com/tom-james-watson/breaktimer-app/releases/latest/download"
ADD ["$BREAKTIMER_URL/BreakTimer.tar.gz", "breaktimer.tar.gz"]
RUN ["tar", "-xz", "--strip-components", "1", "-f", "breaktimer.tar.gz"]
