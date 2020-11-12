FROM voidlinux/voidlinux

# xbps setup
COPY ["xbps/xbps.conf", "/etc/xbps.d/"]
RUN ["xbps-install", "-S"]

# core tools
RUN ["xbps-install", "-y", "base-system", "squashfs-tools-ng", "curl", "wget", "git", "iwd", "unzip", "exa", "bat", "docker", "ntp"]

# core tools setup
COPY ["rc.conf", "/etc/rc.conf"]
COPY ["sudoers", "/etc/sudoers.d/wheel"]
COPY ["libc-locales", "/etc/default/libc-locales"]
COPY ["docker", "/etc/"]
COPY ["locale.conf", "/etc/"]
COPY ["iwd.conf", "/etc/iwd/main.conf"]

WORKDIR "/etc/runit/runsvdir/default"
RUN ["ln", "-s", "/etc/sv/iwd"]
RUN ["ln", "-s", "/etc/sv/dbus"]
RUN ["ln", "-s", "/etc/sv/docker"]
RUN ["ln", "-s", "/etc/sv/isc-ntpd"]

RUN ["xbps-reconfigure", "-fa"]

# user setup
RUN ["chsh", "-s", "/bin/bash"]

RUN ["useradd", "-mG", "wheel,docker,audio", "kshi"]
RUN ["chsh", "-s", "/bin/bash", "kshi"]

# editors
RUN ["xbps-install", "-y", "neovim", "emacs", "vscode"]

# editor setup

RUN ["mkdir", "-p", "/usr/local/share/nvim/site/pack/my/start"]
WORKDIR "/usr/local/share/nvim/site/pack/my/start"
RUN ["git", "clone", "https://github.com/morhetz/gruvbox", "gruvbox"]

COPY ["nvim", "/etc/xdg/nvim"]

# graphical stuff
RUN ["xbps-install", "-y", "xorg", "bspwm", "sxhkd", "redshift", "polybar", "dmenu", "rofi", "dunst", "lightdm", "alacritty", "firefox", "flatpak", "Signal-Desktop", "steam", "pulseaudio", "pavucontrol", "bluez", "xdg-user-dirs-update"]

# fonts
RUN ["xbps-install", "-y", "google-fonts-ttf"]

# stuff
COPY ["extra/", "/"]
COPY ["extra-setup.sh", "/extra-setup.sh"]
RUN ["chmod", "+x", "/extra-setup.sh"];

ENTRYPOINT ["/extra-setup.sh"]

# graphical setup
COPY ["lightdm", "/etc/"]
RUN ["ln", "-s", "/etc/sv/lightdm", "/etc/runit/runsvdir/default"]
RUN ["groupadd", "-r", "autologin"]
RUN ["usermod", "-aG", "autologin", "kshi"]

COPY ["xorg/workman.conf" , "/etc/X11/xorg.conf.d/00-workman.conf"]
COPY ["alacritty", "/etc/xdg/"]

# user-specific setup
USER "kshi"
WORKDIR "/home/kshi"

COPY --chown=kshi:kshi ["bspwm/bspwmrc", ".config/bspwm/"]
COPY --chown=kshi:kshi ["bspwm/sxhkdrc", ".config/sxhkd/"]
COPY --chown=kshi:kshi ["polybar", ".config/"]

RUN ["chmod", "+x", ".config/bspwm/bspwmrc"]

RUN ["ln", "-s", "/data/signal", ".config/Signal"]
RUN ["ln", "-s", "/run/initramfs/live/cfg", "live"]

RUN ["ln", "-s", "/data/hacks"    ]
RUN ["ln", "-s", "/data/documents"]

COPY --chown=kshi:kshi ["user-dirs/dirs"  , ".config/user-dirs.dirs"  ]
COPY --chown=kshi:kshi ["user-dirs/locale", ".config/user-dirs.locale"]
RUN ["xdg-user-dirs-update"]

USER "root"
