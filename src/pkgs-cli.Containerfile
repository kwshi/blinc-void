# vi: ft=dockerfile
FROM "blinc/void.base"

# hardware monitors
RUN xbps-install -y \
  nvme-cli lm_sensors

# common system daemons/libs/tools
RUN xbps-install -y \
  chrony \
  cronutils \
  dbus \
  fuse fuse-overlayfs \
  geoclue2 \
  xdg-user-dirs \
  acl-progs \
  iwd openresolv \
  bubblewrap

# servers
RUN xbps-install -y \
  nginx lighttpd \
  postgresql sqlite sqlite-devel

# tools
RUN xbps-install -y \
  docker docker-compose podman podman-compose buildah \
  wget jq pgcli zip exa bat hyperfine \
  github-cli grip git-cal ghi hub \
  inotify-tools \
  mupdf-tools \
  squashfs-tools-ng \
  pandoc html-xml-utils mmark glow hugo

# void-specific stuff
RUN xbps-install -y \
  xtools vpm vpsm \
  void-release-keys void-docs void-docs-browse

# toys
RUN xbps-install -y \
  sl lolcat-c cowsay ponysay \
  fortune-mod fortune-mod-void

# editors
RUN xbps-install -y \
  neovim emacs xi-editor

# languages
RUN xbps-install -y \
  clang \
  tectonic \
  opam \
  ghc \
  rust \
  go \
  python3-pip \
  nodejs \
  zig \
  julia \
  clojure \
  kotlin-bin \
  erlang \
  elixir \
  ruby \
  apl j \
  wasmtime wabt \
  elvish nushell zsh fish-shell

# language support tools
RUN xbps-install -y \
  clang clang-analyzer clang-tools-extra valgrind ccls \
  gopls \
  shellcheck \
  ghc-doc hoogle \
  python3-language-server black

# extra libraries
RUN xbps-install -y \
  mpfr mpfr-devel \
  gmp gmp-devel \
  libmpc libmpc-devel \
  lapacke lapacke-devel \
  cblas cblas-devel \
  openblas openblas-devel \
  zlib zlib-devel \
  libressl libressl-devel \
  catch2 cgal

# python libraries
RUN xbps-install -y \
  python3-devel \
  python3-numpy \
  python3-matplotlib \
  python3-scipy \
  python3-sympy \
  python3-ipython \
  python3-tkinter \
  python3-bokeh \
  python3-pandas \
  python3-mpmath

# texlive kinda sucks
#RUN xbps-install -y \
#  texlive-full
RUN xbps-install -y \
  texlive
