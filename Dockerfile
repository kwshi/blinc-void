FROM voidlinux/voidlinux

# xbps setup
COPY ["xbps/xbps.conf", "/etc/xbps.d/"]
RUN ["xbps-install", "-S"]

# core tools
RUN ["xbps-install", "-y", "base-system", "squashfs-tools-ng", "curl", "wget", "git", "iwd", "unzip", "exa", "bat", "docker", "ntp", "rsync", "mercurial", "gcc", "clang", "make", "m4", "chrony"]

# core tools setup
COPY ["rc.conf", "/etc/rc.conf"]
COPY ["sudoers", "/etc/sudoers.d/wheel"]
COPY ["libc-locales", "/etc/default/libc-locales"]
COPY ["docker", "/etc/docker"]
COPY ["locale.conf", "/etc/locale.conf"]
COPY ["iwd", "/etc/iwd"]

RUN ["ln", "-s", "/usr/share/zoneinfo/America/Los_Angeles", "/etc/localtime"]

WORKDIR "/etc/runit/runsvdir/default"
RUN ["ln", "-s", "/etc/sv/iwd"]
RUN ["ln", "-s", "/etc/sv/dbus"]
RUN ["ln", "-s", "/etc/sv/docker"]
RUN ["ln", "-s", "/etc/sv/chronyd"]

RUN ["xbps-reconfigure", "-fa"]

# editors
RUN ["xbps-install", "-y", "neovim", "emacs", "vscode"]

# editor setup

RUN ["mkdir", "-p", "/usr/local/share/nvim/site/pack/my/start"]
WORKDIR "/usr/local/share/nvim/site/pack/my/start"
RUN ["git", "clone", "https://github.com/morhetz/gruvbox", "gruvbox"]

COPY ["nvim", "/etc/xdg/nvim"]

# programming languages
RUN ["xbps-install", "-y", "valgrind"]

RUN ["xbps-install", "-y", "python3-ipython", "python3-numpy", "python3-sympy", "python3-scipy"]

RUN ["xbps-install", "-y", "nodejs"]
RUN ["npm", "config", "-g", "set", "user", "root"]
RUN ["npm", "i", "-g", "typescript", "webpack", "webpack-dev-server", "parcel-bundler", "elm"]

RUN ["xbps-install", "-y", "opam"]
RUN ["opam", "init", "--disable-sandboxing", "-n", "--root=/usr/share/opam"]

RUN ["xbps-install", "-y", "shellcheck"]

RUN ["xbps-install", "-y", "texlive-full", "tectonic"]

# user setup
RUN ["chsh", "-s", "/bin/bash"]

RUN ["useradd", "-mG", "wheel,docker,audio", "kshi"]
RUN ["chsh", "-s", "/bin/bash", "kshi"]

# graphical stuff
RUN ["xbps-install", "-y", "xorg", "bspwm", "sxhkd", "redshift", "polybar", "dmenu", "rofi", "dunst", "lightdm", "alacritty", "firefox", "flatpak", "Signal-Desktop", "steam", "pulseaudio", "pavucontrol", "bluez", "xdg-user-dirs", "peek", "sxiv", "vlc", "spotify-tui", "spotifyd"]

# fonts
RUN ["xbps-install", "-y", "google-fonts-ttf", "font-awesome5"]

# stuff
COPY ["extra/", "/"]
COPY ["extra-setup.sh", "/extra-setup.sh"]
RUN ["chmod", "+x", "/extra-setup.sh"];

ENTRYPOINT ["/extra-setup.sh"]

# graphical setup
COPY ["lightdm", "/etc/lightdm"]
RUN ["ln", "-s", "/etc/sv/lightdm", "/etc/runit/runsvdir/default"]
RUN ["groupadd", "-r", "autologin"]
RUN ["usermod", "-aG", "autologin", "kshi"]

COPY ["xorg/workman.conf" , "/etc/X11/xorg.conf.d/00-workman.conf"]
COPY ["alacritty", "/etc/xdg/alacritty"]

# user-specific setup
USER "kshi"
WORKDIR "/home/kshi"

COPY --chown=kshi:kshi ["bspwm/bspwmrc", ".config/bspwm/"]
COPY --chown=kshi:kshi ["bspwm/sxhkdrc", ".config/sxhkd/"]
COPY --chown=kshi:kshi ["polybar", ".config/polybar"]
COPY --chown=kshi:kshi ["git/config", ".gitconfig"]

RUN ["chmod", "+x", ".config/bspwm/bspwmrc"]

RUN ["ln", "-s", "/run/initramfs/live/cfg", "live"]
RUN ["ln", "-s", "/data/signal", ".config/Signal"]
RUN ["ln", "-s", "/data/hacks"    ]
RUN ["ln", "-s", "/data/documents"]

COPY --chown=kshi:kshi ["user-dirs/dirs"  , ".config/user-dirs.dirs"  ]
COPY --chown=kshi:kshi ["user-dirs/locale", ".config/user-dirs.locale"]
RUN ["xdg-user-dirs-update"]

USER "root"
