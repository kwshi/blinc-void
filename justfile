void_repo_url := 'https://alpha.us.repo.voidlinux.org/live/current'
void_version  := '20210218'

void_rootfs_filename := 'void-x86_64-ROOTFS-' + void_version + '.tar.xz'
void_rootfs_url      := void_repo_url + '/' + void_rootfs_filename
void_sig_url         := void_repo_url + '/sha256sum.sig'

void_key_filename    := 'void-release-' + void_version + '.pub'
void_key_path        := justfile_directory() + '/sigs/' + void_key_filename

set positional-arguments

pkgs_dir := justfile_directory() + '/pkgs'
opt_dir := justfile_directory() + '/opt'
xpkgs_dir := justfile_directory() + '/xpkgs'

download_dir := justfile_directory() + '/build/download'
vpkgs_dir := justfile_directory() + '/build/vpkgs'

tmp := '/tmp/blinc'

buildah_prefix := 'blinc-void'

_default:
  @just --choose

# download and/or verify void rootfs
download *opts:
  script/phase/download {{opts}}

img-rootfs *opts: download
  script/phase/rootfs {{opts}}

img-base *opts: img-rootfs
  script/phase/base {{opts}}
  
img-xpkgs *opts: img-base
  script/phase/xpkgs {{opts}}
  
img-pkgs *opts: img-xpkgs
  script/phase/pkgs {{opts}} 

img-opt *opts: img-base
  script/phase/opt {{opts}}

img-home *opts: img-xpkgs img-pkgs
  buildah unshare script/phase/home {{opts}}

img-final *opts: img-home
  script/phase/final {{opts}}

build name: img-final
  script/build/main {{name}}

install name: (build name)
  sudo ./script/install {{name}}

#tmp := /tmp/blinc-void
#live := /run/initramfs/live
#boot := /efi/loader/entries
#build := build
#
#podman_build = podman build -t 'blinc/void.$(notdir $@)' -f '$<' '.'
#podman_build_tee = \
#	$(podman_build) \
#	| tee '$(tmp)/log/$(notdir $@)' \
#	&& cp --no-preserve 'mode' '$(tmp)/log/$(notdir $@)' '$@'
#
#copy_shadow = s/'^$1:.*$$'/"$$(grep '^$1:' '/etc/shadow' | sed 's/[\/&]/\\&/g')"/g

#$(build)/log/cfg: src/cfg.Containerfile $(build)/log/opt dotfiles
#	$(podman_build_tee)
#
#$(build)/prep/ctr: $(build)/log/cfg | $(build)/prep
#	buildah from 'blinc/void.cfg' | tee '$@'
#
#$(build)/prep/mnt: $(build)/prep/ctr
#	buildah mount "$$(cat '$<')" | tee '$@'
#
#mnt = $(file < $(build)/prep/mnt)
#ker = $(file < $(build)/prep/kernel)
#
#/run/initramfs/live/void-%.img: $(build)/prep/mnt
#	read -r mnt < '$<' \
#	&& cp '/etc/hostname' "$$mnt/etc/hostname" \
#	&& sed -i \
#		-e $(call copy_shadow,kshi) \
#		-e $(call copy_shadow,root) \
#		"$$mnt/etc/shadow" \
#	&& mksquashfs "$$mnt" '$@' \
#
#/efi/loader/entries/void-%.conf: $(build/prep/kernel) install/boot.conf
#	sed \
#		-e ':a' -e '/\\$$/N; s/\\\n\s*//; ta' \
#		-e 's/{STAMP}/$*/g' \
#		-e 's/{KERNEL}/$(ker)/g' \
#		'$<' \
#	| tee '$@'
#
#/efi/linux/void/%: $(build)/prep/mnt $(build)/prep/kernel | /efi/linux/void
#	rm -rf '$@' && mkdir '$@' && cp -t '$@' \
#		'$(mnt)/boot/vmlinuz-$(ker)' \
#		'$(mnt)/boot/initramfs-$(ker).img'
#
#.PHONY: clean
#clean:
#	buildah umount '$(file < $(build)/prep/ctr)' || true
#	rm -rf '$(build)/prep' '$(build)/log'
#
# https://www.reddit.com/r/voidlinux/comments/aefcn5/how_to_increase_open_files_limit/

# LINE chromium --app=chrome-extension://ophjlpahpchlmihnnnihgmmeilfjmjjc/index.html
