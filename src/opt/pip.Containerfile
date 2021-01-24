# vi: ft=dockerfile
FROM "blinc/void.base"

RUN ["xbps-install", "-y", "python3-pip", "python3-devel"]

WORKDIR "/opt/blinc/pip"
RUN ["chown", "pip:wheel", "."]
RUN ["chmod", "4775", "."]

USER "pip"
ENV "PIP_PREFIX"="."
RUN ["pip", "install", "ipython"]
RUN ["pip", "install", "black"]
RUN ["pip", "install", "numpy", "scipy", "sympy", "gmpy2", "mpmath"]
RUN ["pip", "install", "pandas", "bokeh"]
