# vi: ft=dockerfile
FROM blinc/void.base

RUN ["xbps-install", "-y", "rustup"]

WORKDIR "/opt/blinc/rust"
ENV "RUSTUP_HOME"="rustup"
ENV "CARGO_HOME"="cargo"
RUN ["rustup-init", "-y"]
RUN ["chown", "-R", "root:wheel"]

RUN ["cargo/bin/rustup", "toolchain", "install", "nightly", "beta"]
RUN ["cargo/bin/rustup", "default", "beta"]
