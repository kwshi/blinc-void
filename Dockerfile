# base system
FROM voidlinux/voidlinux AS base
COPY ["xbps/xbps.conf", "/etc/xbps.d/"]
RUN ["xbps-install", "-Sy", "base-system", "base-devel", "curl", "git"]

FROM base AS util.core
RUN ["xbps-install", "-y", "dbus"]
COPY ["util/core/rc.conf"     , "/etc/rc.conf"             ]
COPY ["util/core/sudoers"     , "/etc/sudoers.d/wheel"     ]
COPY ["util/core/libc-locales", "/etc/default/libc-locales"]
COPY ["util/core/locale.conf" , "/etc/locale.conf"         ]
RUN ["ln", "-s", "/etc/sv/dbus", "/etc/runit/runsvdir/default/dbus"]

FROM base AS util.net
RUN ["xbps-install", "-y", "iwd", "openresolv", "iw"]
RUN ["ln", "-s", "/etc/sv/iwd", "/etc/runit/runsvdir/default/iwd"]
COPY ["util/net/iwd", "/etc/iwd"]

FROM base as util.datetime
RUN ["xbps-install", "-y", "chrony"]
RUN ["ln", "-s", "/usr/share/zoneinfo/America/Los_Angeles", "/etc/localtime"]

FROM base AS util.docker
RUN ["xbps-install", "-y", "docker"]
RUN ["ln", "-s", "/etc/sv/docker", "/etc/runit/runsvdir/default/docker"]
COPY ["util/docker", "/etc/docker"]

FROM base AS util.xdg-user-dirs
RUN ["xbps-install", "-y", "xdg-user-dirs"]
COPY ["util/xdg-user-dirs/user-dirs.defaults", "/etc/xdg/user-dirs.defaults"]

FROM base AS util.misc
RUN ["xbps-install", "-y", "wget", "squashfs-tools-ng", "zip", "exa", "bat", "fuse", "flatpak"]
COPY ["util/misc/bat", "/etc/xdg/bat"]
COPY ["util/misc/ssh", "/etc/ssh"    ]
COPY ["util/misc/git", "/etc/xdg/git"]

FROM base AS lang.c
RUN ["xbps-install", "-y", "clang", "valgrind"]

FROM base AS lang.py
ENV POETRY_HOME="/opt/poetry"
ENV POETRY_HOME="1"
RUN ["xbps-install", "-y", "python3-ipython", "python3-numpy", "python3-sympy", "python3-scipy", "python3-mypy"]
ADD ["https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py", "/opt/poetry/get-poetry.py"]
RUN ["python", "/opt/poetry/get-poetry.py", "--yes", "--no-modify-path"]

FROM base AS lang.tex
RUN ["xbps-install", "-y", "tectonic"]

FROM base AS lang.js
ENV DENO_INSTALL="/opt/deno"
RUN ["xbps-install", "-y", "nodejs"]
RUN ["npm", "i", "-g", "typescript", "webpack"]
ADD ["https://deno.land/x/install/install.sh", "/opt/deno/install.sh"]
RUN ["sh", "/opt/deno/install.sh"]

FROM base AS lang.ocaml
ENV OPAMROOTISOK="1"
RUN ["xbps-install", "-y", "opam"]
RUN ["opam", "init", "--disable-sandboxing", "-ny", "--root=/opt/opam"]
RUN ["opam", "install", "-y", "--root=/opt/opam", "dune", "utop", "odoc", "odig"]
RUN ["opam", "install", "-y", "--root=/opt/opam", "containers", "alcotest"]
RUN ["opam", "install", "-y", "--root=/opt/opam", "cohttp", "cohttp-lwt", "cohttp-lwt-unix"]

FROM base AS lang.elm
ADD ["https://github.com/elm/compiler/releases/download/0.19.1/binary-for-linux-64-bit.gz", "/usr/bin/elm.gz"]
RUN ["gunzip", "/usr/bin/elm.gz"]
RUN ["chmod", "+x", "/usr/bin/elm"]

FROM base AS lang.sh
RUN ["xbps-install", "-y", "shellcheck"]

FROM base AS edit.nvim
# RUN ["xbps-install", "-y", "neovim"]
ADD ["https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz", "/tmp/nvim.tar.gz"]
RUN ["tar", "--strip", "1", "-C", "/usr", "-xf", "/tmp/nvim.tar.gz"]
RUN ["mkdir", "-p", "/usr/local/share/nvim/site/pack/my/start"]
WORKDIR "/usr/local/share/nvim/site/pack/my/start"
RUN ["git", "clone", "https://github.com/gruvbox-community/gruvbox"]
RUN ["git", "clone", "https://github.com/neovim/nvim-lspconfig"    ]
COPY ["edit/nvim" , "/etc/xdg/nvim"]

FROM base AS desk.core
RUN ["xbps-install", "-y", "xorg", "lightdm"]
RUN ["ln", "-s", "/etc/sv/lightdm", "/etc/runit/runsvdir/default/lightdm"]
COPY ["desk/core/xorg"   , "/etc/X11/xorg.conf.d"]
COPY ["desk/core/lightdm", "/etc/lightdm"        ]

FROM base AS desk.desk
RUN ["xbps-install", "-y", "bspwm", "sxhkd", "polybar", "dunst", "rofi", "dmenu", "redshift"]
COPY ["desk/desk/bspwm"  , "/etc/xdg/bspwm"  ]
COPY ["desk/desk/sxhkd"  , "/etc/xdg/sxhkd"  ]
COPY ["desk/desk/polybar", "/etc/xdg/polybar"]
RUN ["chmod", "+x", "/etc/xdg/bspwm/bspwmrc"]

FROM base AS desk.term
RUN ["xbps-install", "-y", "alacritty"]
COPY ["desk/term/alacritty", "/etc/xdg/alacritty"]

FROM base AS desk.web
RUN ["xbps-install", "-y", "firefox", "chromium"]

FROM base AS desk.audio
RUN ["xbps-install", "-y", "pulseaudio", "bluez", "pavucontrol"]

FROM base AS desk.misc
RUN ["xbps-install", "-y", "scrot", "peek"]
RUN ["xbps-install", "-y", "Signal-Desktop", "steam", "vlc", "spotifyd", "spotify-tui", "solvespace"]

FROM base AS desk.font
RUN ["xbps-install", "-y", "fontconfig", "fontconfig-32bit"]
RUN ["xbps-install", "-y", "google-fonts-ttf", "font-awesome5", "noto-fonts-cjk"]

FROM base AS user.init
RUN ["groupadd", "-r", "autologin"]
RUN ["groupadd", "-r", "docker"]
RUN ["usermod", "-s", "/bin/bash", "root"]
RUN ["useradd", "-s", "/bin/bash", "-mG", "wheel,docker,audio,autologin", "kshi"]

FROM user.init AS user.home.kshi
USER "kshi"
WORKDIR "/home/kshi"

COPY --from=util.xdg-user-dirs ["/usr", "/usr"]
COPY --from=util.xdg-user-dirs ["/etc/xdg", "/etc/xdg"]
RUN ["xdg-user-dirs-update"]

RUN ["mkdir", ".ssh"]
RUN ["ln", "-s", "/data/signal"           , ".config/Signal" ]
RUN ["ln", "-s", "/etc/xdg/bspwm"         , ".config/bspwm"  ]
RUN ["ln", "-s", "/etc/xdg/sxhkd"         , ".config/sxhkd"  ]
RUN ["ln", "-s", "/etc/xdg/polybar"       , ".config/polybar"]
RUN ["ln", "-s", "/etc/xdg/bat"           , ".config/bat"    ]
RUN ["ln", "-s", "/etc/xdg/git"           , ".config/git"    ]
RUN ["ln", "-s", "/run/initramfs/live/cfg", "live"           ]
RUN ["ln", "-s", "/data/hacks"            , "hacks"          ]
RUN ["ln", "-s", "/data/documents"        , "documents"      ]

FROM base AS extra
COPY ["extra", "/opt/extra"]
RUN ["chmod", "+x", "/opt/extra/init"]

FROM base AS main

COPY --from=util.core          ["/usr", "/usr"]
COPY --from=util.core          ["/etc", "/etc"]
COPY --from=util.net           ["/usr", "/usr"]
COPY --from=util.net           ["/etc", "/etc"]
COPY --from=util.datetime      ["/usr", "/usr"]
COPY --from=util.datetime      ["/etc", "/etc"]
COPY --from=util.docker        ["/usr", "/usr"]
COPY --from=util.docker        ["/etc", "/etc"]
COPY --from=util.xdg-user-dirs ["/usr", "/usr"]
COPY --from=util.xdg-user-dirs ["/etc", "/etc"]
COPY --from=util.misc          ["/usr", "/usr"]
COPY --from=util.misc          ["/etc", "/etc"]

COPY --from=lang.c     ["/usr"        , "/usr"        ]
COPY --from=lang.py    ["/usr"        , "/usr"        ]
COPY --from=lang.py    ["/opt/poetry" , "/opt/poetry" ]
COPY --from=lang.js    ["/usr"        , "/usr"        ]
COPY --from=lang.js    ["/opt/deno"   , "/opt/deno"   ]
COPY --from=lang.ocaml ["/usr"        , "/usr"        ]
COPY --from=lang.ocaml ["/opt/opam"   , "/opt/opam"   ]
COPY --from=lang.elm   ["/usr/bin/elm", "/usr/bin/elm"]
COPY --from=lang.sh    ["/usr"        , "/usr"        ]
COPY --from=lang.tex   ["/usr"        , "/usr"        ]

COPY --from=edit.nvim ["/usr"    , "/usr"    ]
COPY --from=edit.nvim ["/etc/xdg", "/etc/xdg"]

COPY --from=desk.core ["/usr", "/usr"]
COPY --from=desk.core ["/etc", "/etc"]

COPY --from=desk.desk ["/usr"    , "/usr"    ]
COPY --from=desk.desk ["/etc/xdg", "/etc/xdg"]

COPY --from=desk.term ["/usr"    , "/usr"    ]
COPY --from=desk.term ["/etc/xdg", "/etc/xdg"]

COPY --from=desk.audio ["/usr", "/usr"]
COPY --from=desk.audio ["/etc", "/etc"]

COPY --from=desk.web  ["/usr", "/usr"]
COPY --from=desk.misc ["/usr", "/usr"]
COPY --from=desk.font ["/usr", "/usr"]

COPY --from=user.init ["/etc" , "/etc" ]

COPY --from=user.home.kshi ["/home/kshi", "/home/kshi"]

COPY --from=extra ["/opt/extra", "/opt/extra"]
ENTRYPOINT ["/opt/extra/init"]
