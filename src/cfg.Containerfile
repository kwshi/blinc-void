# vi: ft=dockerfile
FROM "blinc/void.opt"

RUN ["flatpak", "remote-add", "flathub", "https://flathub.org/repo/flathub.flatpakrepo"]

RUN ["rm", "-rf", "/nix"]
RUN ["ln", "-sT", "/data/nix", "/nix"]

WORKDIR "/usr/share/blinc"
COPY [".", "."]
RUN ["chown", "-R", "root:wheel", "."]
RUN ["chmod", "-R", "g+rw", "."]
RUN ["chmod", "2775", "."]

WORKDIR "/etc"
RUN ["mkdir", "docker"]
RUN ["rm", "-rf", "containers", "ssh/ssh_config", "lightdm/lightdm.conf", "pulse/daemon.conf"]
RUN ln -sft . \
  /usr/share/blinc/dotfiles/misc/locale.conf \
  /usr/share/blinc/dotfiles/misc/rc.local \
  /usr/share/blinc/dotfiles/misc/rc.conf \
  /usr/share/blinc/dotfiles/misc/fstab \
  /usr/share/blinc/dotfiles/cli/containers
RUN ["ln", "-sfT", "/usr/share/blinc/dotfiles/misc/libc-locales", "default/libc-locales"]
RUN ["stow", "-d", "/usr/share/blinc/dotfiles/misc", "-t", "sudoers.d", "sudoers"]
RUN ["stow", "-d", "/usr/share/blinc/dotfiles/cli", "-t", "ssh", "ssh"]
RUN ["stow", "-d", "/usr/share/blinc/dotfiles/desk", "-t", "X11", "x11"]
RUN ["stow", "-d", "/usr/share/blinc/dotfiles/desk", "-t", "lightdm", "lightdm"]
RUN ["stow", "-d", "/usr/share/blinc/dotfiles/desk", "-t", "pulse", "pulse"]
RUN ["ln", "-sT", "/usr/share/zoneinfo/America/Los_Angeles", "localtime"]
RUN ["chown", "root:root", "sudoers.d/wheel"]

WORKDIR "/etc/xdg"
RUN ln -st '.' \
  /usr/share/blinc/dotfiles/cli/git \
  /usr/share/blinc/dotfiles/cli/github \
  /usr/share/blinc/dotfiles/cli/bat \
  /usr/share/blinc/dotfiles/cli/pip \
  /usr/share/blinc/dotfiles/cli/nvim \
  /usr/share/blinc/dotfiles/desk/alacritty \
  /usr/share/blinc/dotfiles/desk/polybar \
  /usr/share/blinc/dotfiles/desk/bspwm \
  /usr/share/blinc/dotfiles/desk/sxhkd \
  /usr/share/blinc/dotfiles/desk/xournal
RUN ["ln", "-sfT", "/usr/share/blinc/dotfiles/misc/user-dirs", "user-dirs.defaults"]
RUN ["chmod", "+x", "bspwm/bspwmrc"]

RUN ["ln", "-sT", "/data/containers/root", "/var/lib/containers"]

WORKDIR "/etc/fonts"
RUN ["ln", "-st", ".", "/usr/share/fontconfig/conf.avail/70-no-bitmaps.conf"]

WORKDIR "/etc/runit/runsvdir/default"

RUN ln -st . \
  /etc/sv/dbus \
  /etc/sv/docker \
  /etc/sv/iwd \
  /etc/sv/lightdm \
  /etc/sv/bluetoothd \
  /etc/sv/chronyd

RUN ["mkdir", "/data", "/efi"]

RUN ["groupadd", "-r", "autologin"]
RUN ["useradd", "-m", "kshi"]
RUN ["usermod", "-aG", "wheel,docker,audio,video,autologin", "kshi"]

WORKDIR "/usr/local/bin"
RUN ln -st . \
  /opt/blinc/nvim/bin/nvim \
  /opt/blinc/deno/bin/deno \
  /opt/blinc/elm/bin/elm \
  /opt/blinc/poetry/.poetry/bin/poetry \
  /opt/blinc/talon/talon \
  /opt/blinc/cadmus/cadmus/cadmus \
  /opt/blinc/heroku/bin/heroku

WORKDIR "/usr/local/share/nvim/site"
RUN ["chown", "root:wheel", "."]
RUN ["chmod", "2775", "."]
WORKDIR "/usr/local/share/nvim/site/autoload"
ADD --chown=root:wheel ["https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim", "plug.vim"]
RUN ["chmod", "0775", "plug.vim"]
WORKDIR "/usr/local/share/nvim/site/vim-plug"
RUN ["chown", "root:wheel", "."]
RUN ["chmod", "2775", "."]
RUN ["nvim", "+silent", "+PlugInstall", "+qa"]
RUN ["chmod", "-R", "g+rw", "."]

WORKDIR "/usr/share/fonts"
ADD ["https://support.steampowered.com/downloads/1974-YFKL-4947/SteamFonts.zip", "steam.zip"]
RUN ["unzip", "steam.zip"]

WORKDIR "/usr/share/blinc/dotfiles/cli"
RUN ["stow", "-t", "/etc/bash", "bash"]
RUN ["stow", "-t", "/etc/profile.d", "profile"]
RUN ["stow", "-t", "/etc/iwd", "iwd"]
RUN ["stow", "-t", "/etc", "npm"]

WORKDIR "/home/kshi"
USER "kshi"
RUN ["mkdir", "-p", ".cache", ".config/github", ".mozilla", ".ssh", ".local/share"]
RUN ["rm", ".bashrc", ".bash_profile"]
RUN ["ln", "-st", ".", "/data/documents", "/data/hacks", "/data/movies"]
RUN ["ln", "-sT", "/data/browser/firefox", ".mozilla/firefox"]
RUN ["ln", "-sT", "/data/browser/chromium", ".config/chromium"]
RUN ["ln", "-sT", "/data/zoom", ".zoom"]
RUN ["ln", "-sT", "/data/github/hosts.yml", ".config/github/hosts.yml"]
RUN ["ln", "-sT", "/data/games/klei", ".klei"]
RUN ["ln", "-sT", "/data/games/multimc", ".multimc"]
RUN ["ln", "-sT", "/data/games/steam/home", ".steam"]
RUN ["ln", "-sT", "/data/games/steam/share", ".local/share/Steam"]
RUN ["ln", "-sT", "/data/containers/rootless", ".local/share/containers"]
RUN ["ln", "-sT", "/data/signal", ".config/Signal"]
RUN ["ln", "-sT", "/data/slack", ".config/Slack"]
RUN ["ln", "-sT", "/opt/blinc/tectonic", ".cache/Tectonic"]
RUN ["ln", "-sT", "/usr/share/blinc", "blinc"]
RUN ["ln", "-st", ".config", "/etc/xdg/bspwm", "/etc/xdg/sxhkd", "/etc/xdg/polybar", "/etc/xdg/git"]
RUN ["xdg-user-dirs-update"]

USER "root"

#FROM main.opt AS main.misc
#COPY --from=misc.nvim  ["/tmp/nvim" , "/usr/local/share/nvim" ]
#COPY --from=misc.steam ["/tmp/fonts", "/usr/share/fonts/steam"]
#RUN ["fc-cache", "-fv"]
#
#FROM main.misc AS main.cfg
#COPY --from=cfg ["/tmp/root", "/"]
#RUN ["xbps-reconfigure", "-f", "glibc-locales"]
#
#FROM main.user AS main
#
#FROM main AS entry
#WORKDIR "/tmp/entry"
#COPY ["entry", "."]
#RUN  ["chmod", "+x", "init"]
#ENTRYPOINT ["./init"]
