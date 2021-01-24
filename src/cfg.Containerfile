# vi: ft=dockerfile
FROM "blinc/void.base"

WORKDIR "/usr/share/blinc"
RUN ["git", "clone", "https://github.com/kwshi/dotfiles"]
RUN ["chown", "-R", "root:wheel", "dotfiles"]
RUN ["chmod", "-R", "0774", "dotfiles"]
RUN ["chmod", "g+s", "dotfiles"]

WORKDIR "dotfiles"
RUN ["ln", "-sT", "cli/bash", "/etc/bash"]
RUN ["ln", "-sT", "cli/profile", "/etc/profile.d"]
RUN ["ln", "-sT", "cli/iwd", "/etc/iwd"]
RUN ["ln", "-sT", "cli/docker", "/etc/docker"]
RUN ["ln", "-sT", "cli/containers", "/etc/containers"]
RUN ["ln", "-sT", "cli/ssh", "/etc/ssh"]
RUN ["ln", "-sT", "desk/x11", "/etc/X11"]
RUN ["ln", "-sT", "desk/lightdm", "/etc/lightdm"]
RUN ["ln", "-sT", "desk/fonts", "/etc/fonts"]
RUN ["ln", "-sT", "misc/libc-locales", "/etc/default/libc-locales"]
RUN ["ln", "-sT", "misc/locale.conf", "/etc/locale.conf"]
RUN ["ln", "-sT", "misc/rc.local", "/etc/rc.local"]
RUN ["ln", "-sT", "misc/rc.conf", "/etc/rc.conf"]
RUN ["ln", "-sT", "misc/fstab", "/etc/fstab"]

# TODO localtime

# TODO services
