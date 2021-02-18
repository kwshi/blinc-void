SHELL := /bin/bash -o pipefail

export VOID_RELEASE_URL := https://alpha.us.repo.voidlinux.org/live/current
export VOID_VERSION     := 20191109

void_signify_key := sigs/void-release-$(VOID_VERSION).pub
void_rootfs_filename := void-x86_64-ROOTFS-$(VOID_VERSION).tar.xz

tmp := /tmp/blinc-void
build := build

podman_build = podman build -t 'blinc/void.$(notdir $@)' -f '$<' '.'
podman_build_tee = \
	$(podman_build) \
	| tee '$(tmp)/log/$(notdir $@)' \
	&& cp --no-preserve 'mode' '$(tmp)/log/$(notdir $@)' '$@'

copy_shadow = s/'^$1:.*$$'/"$$(grep '^$1:' '/etc/shadow' | sed 's/[\/&]/\\&/g')"/g

$(build)/log:
	mkdir -p '$@'

$(build)/download:
	mkdir -p '$@'
	
$(build)/img:
	mkdir -p '$@'

$(tmp)/%:
	mkdir -p '$@'

$(build)/download/$(void_rootfs_filename): $(void_signify_key) | $(build)/download $(tmp)/download
	cd '$(tmp)/download' \
	&& curl -fLo '$(void_rootfs_filename)' \
	  '$(VOID_RELEASE_URL)/$(void_rootfs_filename)' \
	&& curl -fLo 'sha256.sig' \
	  '$(VOID_RELEASE_URL)/sha256.sig' \
	&& signify -Cp '$(CURDIR)/$(void_signify_key)' \
	  -x 'sha256.sig' \
	  '$(void_rootfs_filename)' \
	&& cp --no-preserve 'mode' -t '$(CURDIR)/$(build)/download' \
	  '$(void_rootfs_filename)'

$(build)/log/rootfs: src/rootfs.Containerfile \
	$(build)/download/$(void_rootfs_filename) \
	| $(build)/log $(tmp)/log
	$(podman_build) \
		--build-arg 'void_rootfs_filename=$(void_rootfs_filename)' \
		| tee '$(tmp)/log/$(notdir $@)' \
		&& cp --no-preserve 'mode' '$(tmp)/log/$(notdir $@)' '$@'

$(build)/log/base: src/base.Containerfile $(build)/log/rootfs
	$(podman_build_tee)

$(build)/log/pkgs-cli: src/pkgs-cli.Containerfile $(build)/log/base
	$(podman_build_tee)

$(build)/log/pkgs-desk: src/pkgs-desk.Containerfile $(build)/log/pkgs-cli
	$(podman_build_tee)

$(build)/log/opt.%: src/opt/%.Containerfile $(build)/log/base
	$(podman_build_tee)

$(build)/log/opt: \
	src/opt.Containerfile \
	$(build)/log/pkgs-desk \
	$(build)/log/opt.pip \
	$(build)/log/opt.poetry \
	$(build)/log/opt.npm \
	$(build)/log/opt.vpkgs \
	$(build)/log/opt.deno \
	$(build)/log/opt.nvim \
	$(build)/log/opt.elm \
	$(build)/log/opt.heroku \
	$(build)/log/opt.talon \
	$(build)/log/opt.opam \
	$(build)/log/opt.noisetorch \
	$(build)/log/opt.breaktimer \
	$(build)/log/opt.cadmus
	$(podman_build_tee)

$(build)/log/cfg: src/cfg.Containerfile $(build)/log/opt dotfiles
	$(podman_build_tee)

$(build)/img/%.img: $(build)/log/cfg | $(build)/img
	ctr=$$(buildah from 'blinc/void.cfg') \
	&& echo "$$ctr" \
	&& mnt=$$(buildah mount "$$ctr") \
	&& echo "$$mnt" \
	&& cp '/etc/hostname' "$$mnt/etc/hostname" \
	&& sed -i -e $(call copy_shadow,kshi) -e $(call copy_shadow,root) "$$mnt/etc/shadow" \
	&& mksquashfs "$$mnt" '$@' \
	&& buildah umount "$$ctr" \
	&& buildah rm "$$ctr"
