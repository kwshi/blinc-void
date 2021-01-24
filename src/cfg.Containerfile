# vi: ft=dockerfile
FROM "blinc/void.base"

WORKDIR "/usr/share/blinc"
RUN ["git", "clone", "https://github.com/kwshi/blinc-void", "."]
RUN ["chown", "-R", "root:wheel", "."]
RUN ["chmod", "-R", "g+rw", "."]
RUN ["chmod", "4775", "."]

WORKDIR "dotfiles"
RUN ["ln", "-sT", "cli/bash", "/etc/bash"]
RUN ["ln", "-sT", "cli/profile", "/etc/profile.d"]
RUN ["ln", "-sT", "cli/iwd", "/etc/iwd"]
RUN ["ln", "-sT", "cli/docker", "/etc/docker"]
RUN ["ln", "-sT", "cli/containers", "/etc/containers"]
RUN ["ln", "-sT", "cli/ssh", "/etc/ssh"]
RUN ["ln", "-sT", "cli/github", "/etc/xdg/github"]
RUN ["ln", "-sT", "cli/bat", "/etc/xdg/bat"]
RUN ["ln", "-sT", "cli/git", "/etc/xdg/git"]

RUN ["ln", "-sT", "desk/x11", "/etc/X11"]
RUN ["ln", "-sT", "desk/lightdm", "/etc/lightdm"]
RUN ["ln", "-sT", "desk/fonts", "/etc/fonts"]
RUN ["ln", "-sT", "desk/alacritty", "/etc/xdg/alacritty"]
RUN ["ln", "-sT", "desk/bspwm", "/etc/xdg/bspwm"]
RUN ["ln", "-sT", "desk/sxhkd", "/etc/xdg/sxhkd"]

RUN ["ln", "-sT", "misc/libc-locales", "/etc/default/libc-locales"]
RUN ["ln", "-sT", "misc/locale.conf", "/etc/locale.conf"]
RUN ["ln", "-sT", "misc/rc.local", "/etc/rc.local"]
RUN ["ln", "-sT", "misc/rc.conf", "/etc/rc.conf"]
RUN ["ln", "-sT", "misc/fstab", "/etc/fstab"]
RUN ["ln", "-sT", "misc/sudoers", "/etc/sudoers.d"]
RUN ["ln", "-sT", "misc/user-dirs", "/etc/xdg/user-dirs.defaults"]

# TODO localtime
RUN ["ln", "-sT", "/usr/share/zoneinfo/America/Los_Angeles", "/etc/localtime"]

WORKDIR "/etc/runit/runsvdir/default"

RUN ["ln", "-s", "/etc/sv/dbus"]
RUN ["ln", "-s", "/etc/sv/docker"]
RUN ["ln", "-s", "/etc/sv/iwd"]
RUN ["ln", "-s", "/etc/sv/lightdm"]
RUN ["ln", "-s", "/etc/sv/bluetoothd"]
RUN ["ln", "-s", "/etc/sv/chronyd"]

RUN ["mkdir", "-p", "/data", "/efi"]

WORKDIR "/home/kshi"
RUN ["mkdir", "-p", ".cache", ".config", ".mozilla", ".ssh", ".local/share"]
RUN ["ln", "-s", "/data/documents"]
RUN ["ln", "-s", "/data/hacks"]
RUN ["ln", "-sT", "/data/firefox", ".mozilla/firefox"]
RUN ["ln", "-sT", "/data/zoom", ".zoom"]
RUN ["ln", "-sT", "/data/github/hosts.yml", ".config/github/hosts.yml"]
RUN ["ln", "-sT", "/data/games/klei", ".klei"]
RUN ["ln", "-sT", "/data/games/multimc", ".multimc"]
RUN ["ln", "-sT", "/data/games/steam/home", ".steam"]
RUN ["ln", "-sT", "/data/games/steam/share", ".local/share/Steam"]
RUN ["ln", "-sT", "/data/containers", ".local/share/containers"]
RUN ["ln", "-sT", "/data/signal", ".config/Signal"]
RUN ["ln", "-sT", "/data/slack", ".config/Slack"]

RUN ["ln", "-sT", "/opt/blinc/tectonic", ".cache/Tectonic"]


#FROM main.opt AS main.misc
#COPY --from=misc.nvim  ["/tmp/nvim" , "/usr/local/share/nvim" ]
#COPY --from=misc.steam ["/tmp/fonts", "/usr/share/fonts/steam"]
#RUN ["fc-cache", "-fv"]
#
#FROM main.misc AS main.cfg
#COPY --from=cfg ["/tmp/root", "/"]
#RUN ["xbps-reconfigure", "-f", "glibc-locales"]
#
#FROM main.cfg AS main.home
#WORKDIR "/home/kshi"
#RUN ["chown", "kshi:kshi", "."]
#RUN ["chmod", "6700"     , "."]
#USER "kshi"
#COPY --from=home.kshi ["/home/kshi", "."]
#RUN ["xdg-user-dirs-update"]
#
#FROM main.home AS main.user
#USER "root"
#RUN ["groupadd", "-r", "autologin"]
#RUN ["usermod", "-s", "/bin/bash", "root"]
#RUN ["usermod", "-s", "/bin/bash", "void"]
#RUN ["usermod", "-s", "/bin/bash", "-aG", "wheel,docker,audio,video,autologin", "kshi"]
#
#FROM main.user AS main
#
#FROM main AS entry
#WORKDIR "/tmp/entry"
#COPY ["entry", "."]
#RUN  ["chmod", "+x", "init"]
#ENTRYPOINT ["./init"]
