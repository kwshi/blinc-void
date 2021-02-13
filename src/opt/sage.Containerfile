# vi: ft=dockerfile
FROM "blinc/void.base"

WORKDIR "/opt/blinc/sage"
RUN ["chown", "root:wheel", "."]
RUN ["chmod", "2755", "."]

ENV "SAGE_URL"="http://files.sagemath.org/linux/64bit"
ADD ["$SAGE_URL/sage-9.2-Debian_GNU_Linux_10-x86_64.tar.bz2", "sage-9.2.tar.bz2"]
RUN ["tar", "-xz", "--strip-components", "1", "-f", "sage-9.2.tar.bz2"]
