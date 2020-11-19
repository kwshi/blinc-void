FROM voidlinux/voidlinux AS base
COPY ["xbps", "/etc/xbps.d"]
RUN ["xbps-install", "-S"]
RUN ["xbps-install", "-y", "base-system", "base-devel", "xdg-user-dirs", "git"]

RUN ["useradd", "-r", "void"]
RUN ["useradd", "-m", "kshi"]

FROM base AS core.util
RUN ["xbps-install", "-y", "dbus", "docker", "docker-compose", "podman", "podman-compose", "buildah", "fuse", "chrony", "cronutils", "geoclue2", "flatpak"]
RUN ["xbps-install", "-y", "xtools", "curl", "wget", "zip", "exa", "bat", "pass", "inotify-tools", "mupdf-tools", "squashfs-tools-ng", "lm_sensors", "nvme-cli"]
RUN ["xbps-install", "-y", "sl", "lolcat-c", "cowsay", "ponysay", "fortune-mod", "fortune-mod-void"]

FROM core.util AS core.edit
RUN ["xbps-install", "-y", "neovim", "emacs", "xi-editor"]

FROM core.edit AS core.lang
RUN ["xbps-install", "-y", "clang", "valgrind", "ccls"]
RUN ["xbps-install", "-y", "tectonic", "texlive-full"]
RUN ["xbps-install", "-y", "opam", "gmp", "cblas", "lapacke", "openblas"]
RUN ["xbps-install", "-y", "ghc", "hoogle"]
RUN ["xbps-install", "-y", "rust"]
RUN ["xbps-install", "-y", "go", "gopls"]
RUN ["xbps-install", "-y", "python3-pip"]
RUN ["xbps-install", "-y", "nodejs", "yarn"]
RUN ["xbps-install", "-y", "julia", "clojure", "kotlin-bin", "factor", "shellcheck", "pandoc"]

FROM core.lang AS core.wifi
RUN ["xbps-install", "-y", "iwd", "openresolv", "iw"]

FROM core.wifi as core

FROM core AS desk.core
RUN ["xbps-install", "-y", "xorg", "lightdm", "picom", "bspwm", "sxhkd", "polybar", "dunst", "rofi", "dmenu", "redshift", "redshift-gtk", "caffeine-ng"]
RUN ["xbps-install", "-y", "pulseaudio", "bluez", "pavucontrol", "pamixer"]

FROM desk.core AS desk.font
RUN ["xbps-install", "-y", "fontconfig", "fontconfig-32bit"]
RUN ["xbps-install", "-y", "google-fonts-ttf", "font-awesome5", "noto-fonts-cjk"]

FROM desk.font AS desk.misc
RUN ["xbps-install", "-y", "alacritty", "st"]
RUN ["xbps-install", "-y", "emacs-gtk3", "vscode", "intellij-idea-community-edition", "pycharm-community", "gxi"]
RUN ["xbps-install", "-y", "firefox", "chromium"]
RUN ["xbps-install", "-y", "xournal", "xournalpp", "mupdf", "zathura-pdf-mupdf", "zathura", "zathura-ps"]
RUN ["xbps-install", "-y", "tigervnc", "remmina"]
RUN ["xbps-install", "-y", "scrot", "peek", "sxiv"]
RUN ["xbps-install", "-y", "Signal-Desktop", "gtk2fontsel", "solvespace", "puzzles"]
RUN ["xbps-install", "-y", "vlc", "spotifyd", "spotify-tui"]

FROM desk.misc AS desk.art
RUN ["xbps-install", "-y", "inkscape", "gimp", "blender", "krita", "musescore", "openshot", "shotcut", "obs"]

FROM desk.art AS desk.game
RUN ["xbps-install", "-y", "steam", "libglvnd-32bit", "libdrm-32bit", "mesa-dri-32bit"]
RUN ["xbps-install", "-y", "MultiMC"]

FROM desk.game AS desk

FROM base AS opt.opam
WORKDIR "/opt/opam"
ENV OPAMROOTISOK="1"
ENV OPAMROOT="."
ENV OPAMYES="1"
RUN ["chown", "root:wheel", "."]
RUN ["chmod", "6775"      , "."]
RUN ["xbps-install", "-y", "opam", "gmp-devel", "cblas-devel", "lapacke-devel", "openblas-devel", "zlib-devel"]
RUN ["opam", "init", "--disable-sandboxing", "-ny"]
RUN ["opam", "install", "dune", "utop", "odoc", "odig", "ocaml-lsp-server", "ppxlib"]
RUN ["opam", "install", "containers", "alcotest", "lwt", "parmap"]
RUN ["opam", "install", "yojson", "toml"]
RUN ["opam", "install", "menhir", "sedlex", "angstrom"]
RUN ["opam", "install", "ANSITerminal", "fmt", "uutf", "linenoise", "zed"]
RUN ["opam", "install", "owl", "zarith"]
RUN ["opam", "install", "cohttp", "cohttp-lwt", "cohttp-lwt-unix"]

FROM base AS opt.poetry
WORKDIR "/opt/poetry"
ENV POETRY_HOME="."
RUN ["chown", "root:wheel", "."]
RUN ["chmod", "6775"      , "."]
ADD ["https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py", "get-poetry.py"]
RUN ["xbps-install", "-y", "python3"]
RUN ["python", "get-poetry.py", "--yes", "--no-modify-path"]
RUN ["chmod", "+x", "bin/poetry"]

FROM base AS opt.elm
WORKDIR "/opt/elm"
RUN ["chown", "root:wheel", "."]
RUN ["chmod", "6775"      , "."]

WORKDIR "bin"
ADD ["https://github.com/elm/compiler/releases/download/0.19.1/binary-for-linux-64-bit.gz", "elm.gz"]
RUN ["gunzip", "elm.gz"]
RUN ["chmod", "+x", "elm"]

FROM base AS opt.deno
WORKDIR "/opt/deno"
RUN ["chown", "root:wheel", "."]
RUN ["chmod", "6775"      , "."]
ADD ["https://github.com/denoland/deno/releases/download/v1.5.3/deno-x86_64-unknown-linux-gnu.zip", "deno.zip"]
RUN ["unzip", "-d", "bin", "deno.zip"]

FROM base AS opt.nvim
WORKDIR "/opt/nvim"
RUN ["chown", "root:wheel", "."]
RUN ["chmod", "6775"      , "."]
ADD ["https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz", "nvim.tar.gz"]
RUN ["tar", "-x", "--strip", "1", "-f", "nvim.tar.gz"]
RUN ["rm", "nvim.tar.gz"]

FROM base AS opt.tectonic
WORKDIR "/opt/tectonic"
RUN ["chown", "root:wheel", "."]
RUN ["chmod", "6775"      , "."]
COPY --from=rekka/tectonic ["/root/.cache/Tectonic", "cache"]

FROM base AS opt.pip
WORKDIR "/opt/pip"
ENV PIP_PREFIX="."
ENV PIP_CACHE_DIR=".cache"
ENV PIP_NO_WARN_SCRIPT_LOCATION="1"
RUN ["chown", "root:wheel", "."]
RUN ["chmod", "6775"      , "."]
RUN ["xbps-install", "-y", "python3-pip"]
RUN ["pip", "install", "ipython", "python-language-server", "black", "mypy"]
RUN ["pip", "install", "numpy", "sympy", "scipy", "matplotlib"]
RUN ["pip", "install", "pytest", "hypothesis"]
RUN ["pip", "install", "bokeh", "seaborn", "pandas"]

FROM base AS opt.npm
WORKDIR "/opt/npm"
ENV NPM_CONFIG_PREFIX="."
ENV NPM_CONFIG_GLOBAL="true"
ENV NPM_CONFIG_PROGRESS="false"
RUN ["chown", "root:wheel", "."]
RUN ["chmod", "6775"      , "."]
RUN ["xbps-install", "-y", "nodejs"]
RUN ["npm", "i", "typescript", "typescript-language-server", "pnpm", "prettier"]

FROM base AS opt.void
WORKDIR "/opt/void"
RUN ["chown", "void:wheel", "."]
RUN ["chmod", "6775"      , "."]
USER "void"
RUN ["git", "clone", "https://github.com/void-linux/void-packages", "."]

FROM base AS opt
WORKDIR "/tmp/opt"
COPY --chown=root:wheel --from=opt.opam     ["/opt/opam"    , "opam"    ]
COPY --chown=root:wheel --from=opt.nvim     ["/opt/nvim"    , "nvim"    ]
COPY --chown=root:wheel --from=opt.deno     ["/opt/deno"    , "deno"    ]
COPY --chown=root:wheel --from=opt.poetry   ["/opt/poetry"  , "poetry"  ]
COPY --chown=root:wheel --from=opt.elm      ["/opt/elm"     , "elm"     ]
COPY --chown=root:wheel --from=opt.tectonic ["/opt/tectonic", "tectonic"]
COPY --chown=root:wheel --from=opt.pip      ["/opt/pip"     , "pip"     ]
COPY --chown=root:wheel --from=opt.npm      ["/opt/npm"     , "npm"     ]
COPY --chown=void:wheel --from=opt.void     ["/opt/void"    , "void"    ]
RUN ["chmod", "6775", "opam", "nvim", "deno", "poetry", "elm", "tectonic", "pip", "npm", "void"]

WORKDIR "/tmp/bin"
RUN ["ln", "-s", "/opt/nvim/bin/nvim"    ]
RUN ["ln", "-s", "/opt/poetry/bin/poetry"]
RUN ["ln", "-s", "/opt/deno/bin/deno"    ]
RUN ["ln", "-s", "/opt/elm/bin/elm"      ]

FROM base AS misc.nvim
WORKDIR "/tmp/nvim/site/pack/me/start"
RUN ["chown", "root:wheel", "."]
RUN ["chmod", "6775"      , "."]
RUN ["git", "clone", "https://github.com/gruvbox-community/gruvbox"]
RUN ["git", "clone", "https://github.com/neovim/nvim-lspconfig"    ]

FROM base AS misc.steam
# https://wiki.archlinux.org/index.php/Steam/Troubleshooting#Text_is_corrupt_or_missing
# https://support.steampowered.com/kb_article.php?ref=1974-YFKL-4947
WORKDIR "/tmp/fonts"
ADD ["https://support.steampowered.com/downloads/1974-YFKL-4947/SteamFonts.zip", "/tmp/steam-fonts.zip"]
RUN ["unzip", "/tmp/steam-fonts.zip"]

FROM base AS cfg
WORKDIR "/tmp/root"
ADD ["https://flathub.org/repo/flathub.flatpakrepo", "etc/flatpak/remotes.d/flathub.conf"]
COPY ["cfg", "/tmp/root"]

FROM base AS home.kshi
WORKDIR "/home/kshi"
RUN ["chown", "kshi:kshi", "."]
RUN ["chmod", "6700"     , "."]
USER "kshi"
COPY --chown=kshi:kshi ["cfg/home/kshi", "."]
RUN ["xdg-user-dirs-update"]

FROM desk AS main.opt
COPY --from=opt ["/tmp/opt", "/opt"          ]
COPY --from=opt ["/tmp/bin", "/usr/local/bin"]

FROM main.opt AS main.misc
COPY --from=misc.nvim  ["/tmp/nvim" , "/usr/local/share/nvim" ]
COPY --from=misc.steam ["/tmp/fonts", "/usr/share/fonts/steam"]
RUN ["fc-cache", "-fv"]

FROM main.misc AS main.cfg
COPY --from=cfg ["/tmp/root", "/"]
RUN ["xbps-reconfigure", "-f", "glibc-locales"]

FROM main.cfg AS main.home
COPY --from=home.kshi ["/home/kshi", "/home/kshi"]

FROM main.home AS main.user
RUN ["groupadd", "-r", "autologin"]
RUN ["usermod", "-s", "/bin/bash", "root"]
RUN ["usermod", "-s", "/bin/bash", "void"]
RUN ["usermod", "-s", "/bin/bash", "-aG", "wheel,docker,audio,video,autologin", "kshi"]

FROM main.home AS main

FROM main AS entry
WORKDIR "/tmp/entry"
COPY ["entry", "."]
RUN  ["chmod", "+x", "init"]
ENTRYPOINT ["./init"]
