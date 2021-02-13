# vi: ft=dockerfile
FROM "blinc/void.base"

RUN ["xbps-install", "-y", "python3-pip", "python3-devel"]
RUN ["xbps-install", "-y", "gmp-devel", "mpfr-devel", "libmpc-devel"]

WORKDIR "/opt/blinc/pip"
RUN ["chown", "pip:wheel", "."]
RUN ["chmod", "2775", "."]

USER "pip"
ENV "PIP_PREFIX"="/opt/blinc/pip"
RUN ["pip", "install", "ipython"]
RUN ["pip", "install", "black"]
RUN ["pip", "install", "numpy", "scipy", "sympy", "gmpy2", "mpmath"]
RUN ["pip", "install", "pandas", "bokeh"]
