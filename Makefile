SHELL := /bin/bash

export VOID_RELEASE_URL := https://alpha.us.repo.voidlinux.org/live/current
export VOID_VERSION     := 20191109

void_signify_key := sigs/void-release-$(VOID_VERSION).pub
void_rootfs_filename := void-x86_64-ROOTFS-$(VOID_VERSION).tar.xz

podman_build = podman build -t 'blinc/void.$(notdir $@)' -f '$<' '.'
podman_build_tee = $(podman_build) | tee '$@'

download:
	mkdir -p 'download'

download/$(void_rootfs_filename): $(void_signify_key) | download
	mkdir -p '/tmp/blinc-void' \
	&& cd '/tmp/blinc-void' \
	&& curl -fLo '$(void_rootfs_filename)' \
	  '$(VOID_RELEASE_URL)/$(void_rootfs_filename)' \
	&& curl -fLo 'sha256.sig' \
	  '$(VOID_RELEASE_URL)/sha256.sig' \
	&& signify -Cp '$(CURDIR)/$(void_signify_key)' \
	  -x 'sha256.sig' \
	  '$(void_rootfs_filename)' \
	&& mv -t '$(CURDIR)/download' \
	  '$(void_rootfs_filename)' \
	&& rm -rf '/tmp/blinc-void'

log/rootfs: src/rootfs.Containerfile download/$(void_rootfs_filename)
	$(podman_build) \
		--build-arg 'void_rootfs_filename=$(void_rootfs_filename)' \
		| tee '$@'

log/base: src/base.Containerfile log/rootfs
	$(podman_build_tee)

log/pkgs-cli: src/pkgs-cli.Containerfile log/base
	$(podman_build_tee)

log/pkgs-desk: src/pkgs-desk.Containerfile log/pkgs-cli
	$(podman_build_tee)

log/opt.%: src/opt/%.Containerfile log/base
	$(podman_build_tee)

log/opt: \
	src/opt.Containerfile \
	blinc/void.pkgs-desk \
	blinc/void.opt.pip \
	blinc/void.opt.poetry \
	blinc/void.opt.npm \
	blinc/void.opt.opam
	$(podman_build_tee)

log/cfg: src/cfg.Containerfile blinc/void.pkgs-desk blinc/void.opt
	$(podman_build_tee)
