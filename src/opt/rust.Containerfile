# vi: ft=dockerfile
FROM blinc/void.base

RUN ["xbps-install", "-y", "rustup"]

WORKDIR "/opt/blinc/rust"
ENV "RUSTUP_HOME"="."
ENV "CARGO_HOME"="."

RUN ["rustup", "toolchain", "install", "nightly"]
RUN ["rustup", "default", "nightly"]
