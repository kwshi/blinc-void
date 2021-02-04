# vi: ft=dockerfile
FROM blinc/void.base

WORKDIR "/opt/blinc/talon"
RUN ["chown", "root:wheel", "."]
RUN ["chmod", "2755", "."]

ADD ["https://talonvoice.com/dl/latest/talon-linux.tar.xz", "talon.tar.xz"]
RUN ["tar", "-xv", "--strip-components", "1", "-f", "talon.tar.xz"]
