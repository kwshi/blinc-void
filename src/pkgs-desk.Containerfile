# vi: ft=dockerfile
FROM "blinc/void.pkgs-cli"

# core
RUN xbps-install -y \
  xorg lightdm bspwm sxhkd picom \
  polybar dunst rofi dmenu stalonetray \
  pulseaudio bluez alsa-plugins-pulseaudio \
  caffeine-ng \
  mesa-vaapi mesa-vdpau mesa-vulkan-radeon \
  fontconfig fontconfig-32bit \
  barrier

# tools
RUN xbps-install -y \
  redshift redshift-gtk sct \
  xsel hsetroot xclip xdotool \
  scrot peek \
  fswebcam cheese \
  sxiv \
  pavucontrol pamixer ponymix paprefs pasystray \
  lxappearance \
  alacritty st \
  tigervnc remmina \
  gtk2fontsel

# editors
RUN xbps-install -y \
  emacs-gtk3 \
  vscode \
  intellij-idea-community-edition \
  pycharm-community \
  gxi

# documents
RUN xbps-install -y \
  xournal xournalpp \
  mupdf \
  zathura zathura-pdf-mupdf zathura-ps \
  apvlv

# browser
RUN xbps-install -y \
  firefox chromium browsh

# graphical languages
RUN xbps-install -y \
  openscad factor octave

# media players
RUN xbps-install -y \
  spotifyd spotify-tui \
  vlc mplayer mpv

# art & modeling
RUN xbps-install -y \
  inkscape gimp krita darktable \
  blender solvespace \
  musescore lilypond \
  openshot shotcut obs

# messengers
RUN xbps-install -y \
  Signal-Desktop

# fonts
RUN xbps-install -y \
  google-fonts-ttf \
  font-awesome5 \
  noto-fonts-cjk

# toys/games
RUN xbps-install -y \
  MultiMC \
  puzzles \
  steam \
  libglvnd-32bit libdrm-32bit mesa-dri-32bit \
  vulkan-loader-32bit mesa-vulkan-radeon-32bit

# virtualization
RUN xbps-install -y \
  qemu qemu-ga qemu-user-static qemuconf virtme \
  libvirt virt-manager virt-manager-tools

# misc
RUN xbps-install -y \
  flatpak