FROM voidlinux/voidlinux AS base
COPY ["xbps/xbps.conf", "/etc/xbps.d/"]
RUN ["xbps-install", "-S"]
RUN ["xbps-install", "-y", "base-system", "base-devel"]

FROM base AS core.util
RUN ["xbps-install", "-y", "xtools", "flatpak"]
RUN ["xbps-install", "-y", "dbus", "fuse", "chrony", "cronutils", "geoclue2"]
RUN ["xbps-install", "-y", "docker", "squashfs-tools-ng"]
RUN ["xbps-install", "-y", "git", "curl", "wget", "zip", "exa", "bat", "pandoc", "pass"]
RUN ["xbps-install", "-y", "sl", "lolcat-c", "cowsay", "ponysay"]
RUN ["xbps-install", "-y", "fortune-mod", "fortune-mod-void"]
RUN ["xbps-install", "-y", "nvme-cli"]
RUN ["xbps-install", "-y", "inotify-tools", "mupdf-tools"]
RUN ["xbps-install", "-y", "xdg-user-dirs"]

FROM core.util AS core.edit
RUN ["xbps-install", "-y", "neovim", "emacs", "xi-editor"]

FROM core.edit AS core.lang
RUN ["xbps-install", "-y", "gmp", "cblas", "lapacke", "openblas"]
RUN ["xbps-install", "-y", "clang", "valgrind"]
RUN ["xbps-install", "-y", "python3", "python3-pip", "python3-ipython", "python3-mypy"]
RUN ["xbps-install", "-y", "python3-numpy", "python3-sympy", "python3-scipy", "python3-matplotlib"]
RUN ["xbps-install", "-y", "python3-bokeh", "python3-pandas"]
RUN ["xbps-install", "-y", "julia"]
RUN ["xbps-install", "-y", "clojure"]
RUN ["xbps-install", "-y", "kotlin-bin"]
RUN ["xbps-install", "-y", "rust"]
RUN ["xbps-install", "-y", "go"]
RUN ["xbps-install", "-y", "factor"]
RUN ["xbps-install", "-y", "tectonic", "texlive-full"]
RUN ["xbps-install", "-y", "nodejs", "yarn"]
RUN ["xbps-install", "-y", "opam"]
RUN ["xbps-install", "-y", "shellcheck"]
RUN ["xbps-install", "-y", "ghc", "hoogle"]

FROM core.lang AS core.wifi
RUN ["xbps-install", "-y", "iwd", "openresolv", "iw"]

FROM core.wifi as core

FROM core AS desk.core
RUN ["xbps-install", "-y", "xorg", "lightdm"]
RUN ["xbps-install", "-y", "bspwm", "sxhkd", "polybar", "dunst", "rofi", "dmenu"]
RUN ["xbps-install", "-y", "redshift", "redshift-gtk", "caffeine-ng"]
RUN ["xbps-install", "-y", "pulseaudio", "bluez", "pavucontrol", "pamixer"]

FROM desk.core AS desk.font
RUN ["xbps-install", "-y", "fontconfig", "fontconfig-32bit"]
RUN ["xbps-install", "-y", "google-fonts-ttf", "font-awesome5", "noto-fonts-cjk"]

FROM desk.font AS desk.misc
RUN ["xbps-install", "-y", "alacritty", "st"]
RUN ["xbps-install", "-y", "vscode", "intellij-idea-community-edition", "pycharm-community"]
RUN ["xbps-install", "-y", "firefox", "chromium"]
RUN ["xbps-install", "-y", "scrot", "peek", "sxiv"]
RUN ["xbps-install", "-y", "xournal", "xournalpp", "mupdf", "zathura-pdf-mupdf", "zathura", "zathura-ps"]
RUN ["xbps-install", "-y", "Signal-Desktop", "gtk2fontsel", "solvespace", "puzzles"]
RUN ["xbps-install", "-y", "vlc", "spotifyd", "spotify-tui"]
RUN ["xbps-install", "-y", "tigervnc", "remmina"]

FROM desk.misc AS desk.art
RUN ["xbps-install", "-y", "inkscape", "gimp", "blender", "krita", "musescore", "openshot", "shotcut", "obs"]

FROM desk.art AS desk.game
RUN ["xbps-install", "-y", "steam", "libglvnd-32bit", "libdrm-32bit", "mesa-dri-32bit"]
RUN ["xbps-install", "-y", "MultiMC"]

FROM desk.game AS desk

FROM base AS opt.opam
ENV OPAMROOTISOK="1"
ENV OPAMROOT="/opt/opam"
RUN ["xbps-install", "-y", "opam", "gmp-devel", "cblas-devel", "lapacke-devel", "openblas-devel", "zlib-devel"]
RUN ["opam", "init", "--disable-sandboxing", "-ny"]
RUN ["opam", "install", "-y", "dune", "utop", "odoc", "odig", "ocaml-lsp-server"]
RUN ["opam", "install", "-y", "alcotest", "containers", "ppxlib", "zarith", "owl"]
RUN ["opam", "install", "-y", "lwt", "parmap"]
RUN ["opam", "install", "-y", "yojson", "toml"]
RUN ["opam", "install", "-y", "fmt", "zed", "linenoise", "ANSITerminal", "uutf"]
RUN ["opam", "install", "-y", "menhir", "sedlex", "angstrom"]
RUN ["opam", "install", "-y", "cohttp", "cohttp-lwt", "cohttp-lwt-unix"]

FROM base AS opt.poetry
WORKDIR "/opt/poetry"
ENV POETRY_HOME="."
ADD ["https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py", "get-poetry.py"]
RUN ["xbps-install", "-y", "python3"]
RUN ["python", "get-poetry.py", "--yes", "--no-modify-path"]

FROM base AS opt.elm
WORKDIR "/opt/elm/bin"
ADD ["https://github.com/elm/compiler/releases/download/0.19.1/binary-for-linux-64-bit.gz", "elm.gz"]
RUN ["gunzip", "elm.gz"]
RUN ["chmod", "+x", "elm"]

FROM base AS opt.deno
WORKDIR "/opt/deno"
ENV DENO_INSTALL="."
RUN ["xbps-install", "-y", "curl"]
ADD ["https://deno.land/x/install/install.sh", "install.sh"]
RUN ["sh", "install.sh"]

FROM base AS opt.nvim
WORKDIR "/opt/nvim"
ADD ["https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz", "nvim.tar.gz"]
RUN ["tar", "-x", "--strip", "1", "-f", "nvim.tar.gz"]
RUN ["rm", "nvim.tar.gz"]

FROM base AS opt.tectonic
COPY --from=rekka/tectonic ["/root/.cache/Tectonic", "/opt/tectonic/cache"]

FROM base AS misc.npm
RUN ["xbps-install", "-y", "nodejs"]
RUN ["npm", "i", "-g", "--no-progress", "typescript", "typescript-language-server", "pnpm", "prettier"]

FROM base AS misc.nvim
WORKDIR "/usr/local/share/nvim/site/pack/custom/start"
RUN ["xbps-install", "-y", "git"]
RUN ["git", "clone", "https://github.com/gruvbox-community/gruvbox"]
RUN ["git", "clone", "https://github.com/neovim/nvim-lspconfig"    ]

FROM base AS misc.steam
# https://wiki.archlinux.org/index.php/Steam/Troubleshooting#Text_is_corrupt_or_missing
# https://support.steampowered.com/kb_article.php?ref=1974-YFKL-4947
WORKDIR "/usr/share/fonts/steam"
ADD ["https://support.steampowered.com/downloads/1974-YFKL-4947/SteamFonts.zip", "/tmp/steam-fonts.zip"]
RUN ["unzip", "/tmp/steam-fonts.zip"]

FROM desk AS main.opt
COPY --from=opt.opam     ["/opt/opam"    , "/opt/opam"    ]
COPY --from=opt.nvim     ["/opt/nvim"    , "/opt/nvim"    ]
COPY --from=opt.deno     ["/opt/deno"    , "/opt/deno"    ]
COPY --from=opt.poetry   ["/opt/poetry"  , "/opt/poetry"  ]
COPY --from=opt.elm      ["/opt/elm"     , "/opt/elm"     ]
COPY --from=opt.tectonic ["/opt/tectonic", "/opt/tectonic"]

WORKDIR "/usr/local/bin"
RUN ["ln", "-s", "/opt/nvim/bin/nvim"    ]
RUN ["ln", "-s", "/opt/poetry/bin/poetry"]
RUN ["ln", "-s", "/opt/deno/bin/deno"    ]
RUN ["ln", "-s", "/opt/elm/bin/elm"      ]

FROM main.opt AS main.misc
COPY --from=misc.nvim  ["/usr/local/share/nvim" , "/usr/local/share/nvim" ]
COPY --from=misc.npm   ["/usr/lib/node_modules" , "/usr/lib/node_modules" ]
COPY --from=misc.steam ["/usr/share/fonts/steam", "/usr/share/fonts/steam"]
RUN ["fc-cache", "-fv"]

WORKDIR "/usr/local/bin"
RUN ["ln", "-s", "/usr/lib/node_modules/typescript/bin/tsserver"]
RUN ["ln", "-s", "/usr/lib/node_modules/typescript/bin/tsc"     ]
RUN ["ln", "-sT", "/usr/lib/node_modules/typescript-language-server/lib/cli.js", "typescript-language-server"]
RUN ["ln", "-sT", "/usr/lib/node_modules/pnpm/bin/pnpm.js", "pnpm"]
RUN ["ln", "-sT", "/usr/lib/node_modules/pnpm/bin/pnpx.js", "pnpx"]
RUN ["ln", "-sT", "/usr/lib/node_modules/prettier/bin-prettier.js", "prettier"]

FROM main.misc AS main.cfg

ADD ["https://flathub.org/repo/flathub.flatpakrepo", "/etc/flatpak/remotes.d/flathub.conf"]

RUN ["ln", "-st", "/etc/runit/runsvdir/default", "/etc/sv/dbus"   ]
RUN ["ln", "-st", "/etc/runit/runsvdir/default", "/etc/sv/docker" ]
RUN ["ln", "-st", "/etc/runit/runsvdir/default", "/etc/sv/iwd"    ]
RUN ["ln", "-st", "/etc/runit/runsvdir/default", "/etc/sv/lightdm"]
RUN ["ln", "-st", "/etc/runit/runsvdir/default", "/etc/sv/chronyd"]
RUN ["ln", "-s", "/usr/share/zoneinfo/America/Los_Angeles", "/etc/localtime"]
RUN ["ln", "-st", "/etc/fonts/conf.d", "/usr/share/fontconfig/conf.avail/70-no-bitmaps.conf"]

RUN ["mkdir", "/efi", "/data", "/var/lib/docker"]
COPY ["cfg/base/fstab"         , "/etc/fstab"                 ]
COPY ["cfg/base/rc.local"      , "/etc/rc.local"              ]
COPY ["cfg/base/rc.conf"       , "/etc/rc.conf"               ]
COPY ["cfg/base/sudoers"       , "/etc/sudoers.d/wheel"       ]
COPY ["cfg/base/libc-locales"  , "/etc/default/libc-locales"  ]
COPY ["cfg/base/locale.conf"   , "/etc/locale.conf"           ]
COPY ["cfg/base/profile"       , "/etc/profile.d"             ]
COPY ["cfg/base/bashrc"        , "/etc/bash/bashrc.d"         ]
COPY ["cfg/core/util/docker"   , "/etc/docker"                ]
COPY ["cfg/core/util/bat"      , "/etc/xdg/bat"               ]
COPY ["cfg/core/util/ssh"      , "/etc/ssh"                   ]
COPY ["cfg/core/util/git"      , "/etc/xdg/git"               ]
COPY ["cfg/core/util/xdg-dirs" , "/etc/xdg/user-dirs.defaults"]
COPY ["cfg/core/edit/nvim"     , "/etc/xdg/nvim"              ]
COPY ["cfg/core/wifi/iwd"      , "/etc/iwd"                   ]
COPY ["cfg/desk/core/xorg"     , "/etc/X11/xorg.conf.d"       ]
COPY ["cfg/desk/core/lightdm"  , "/etc/lightdm"               ]
COPY ["cfg/desk/core/bspwm"    , "/etc/xdg/bspwm"             ]
COPY ["cfg/desk/core/sxhkd"    , "/etc/xdg/sxhkd"             ]
COPY ["cfg/desk/core/polybar"  , "/etc/xdg/polybar"           ]
COPY ["cfg/desk/misc/alacritty", "/etc/xdg/alacritty"         ]

RUN ["chmod", "+x", "/etc/xdg/bspwm/bspwmrc"]

RUN ["xbps-reconfigure", "-f", "glibc-locales"]

FROM main.cfg AS main.grp
RUN ["groupadd", "-r", "autologin"]

FROM main.grp AS main.user.root
RUN ["usermod", "-s", "/bin/bash", "root"]

FROM main.user.root AS main.user.kshi
RUN ["useradd", "-s", "/bin/bash", "-G", "wheel", "-m", "kshi"]
RUN ["usermod", "-aG", "docker,audio,video,autologin", "kshi"]

USER "kshi"
WORKDIR "/home/kshi"
RUN ["mkdir", ".ssh", ".config", ".cache", ".mozilla"]
RUN ["ln", "-s", "/data/signal"           , ".config/Signal"  ]
RUN ["ln", "-s", "/etc/xdg/bspwm"         , ".config/bspwm"   ]
RUN ["ln", "-s", "/etc/xdg/sxhkd"         , ".config/sxhkd"   ]
RUN ["ln", "-s", "/etc/xdg/polybar"       , ".config/polybar" ]
RUN ["ln", "-s", "/etc/xdg/bat"           , ".config/bat"     ]
RUN ["ln", "-s", "/etc/xdg/git"           , ".config/git"     ]
RUN ["ln", "-s", "/data/firefox"          , ".mozilla/firefox"]
RUN ["ln", "-s", "/opt/tectonic/cache"    , ".cache/Tectonic" ]
RUN ["ln", "-s", "/run/initramfs/live/cfg", "live"            ]
RUN ["ln", "-s", "/data/hacks"            , "hacks"           ]
RUN ["ln", "-s", "/data/documents"        , "documents"       ]
RUN ["xdg-user-dirs-update"]

FROM main.user.kshi AS main
USER "root"

FROM main AS extra
WORKDIR "/tmp/extra"
COPY ["extra", "."]
RUN  ["chmod", "+x", "init"]
ENTRYPOINT ["./init"]
