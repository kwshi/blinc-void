# vi: ft=dockerfile
FROM "blinc/void.base"

WORKDIR "/opt/blinc/nvim"
RUN ["chown", "root:wheel", "."]
RUN ["chmod", "2755"      , "."]
ENV "NVIM_URL"="https://github.com/neovim/neovim/releases/download/nightly"
ADD ["$NVIM_URL/nvim-linux64.tar.gz", "nvim.tar.gz"]
RUN ["tar", "-x", "--strip", "1", "-f", "nvim.tar.gz"]
RUN ["rm", "nvim.tar.gz"]
