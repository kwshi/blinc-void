SHELL := /bin/bash

export VOID_RELEASE_URL := https://alpha.us.repo.voidlinux.org/live/current
export VOID_VERSION     := 20191109

void_signify_key := sigs/void-release-$(VOID_VERSION).pub
void_rootfs_filename := void-x86_64-ROOTFS-$(VOID_VERSION).tar.xz

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

.PHONY: blinc/void.rootfs
blinc/void.rootfs: src/rootfs.Containerfile download/$(void_rootfs_filename)
	podman build -t '$@' -f '$<' '.' \
		--build-arg 'void_rootfs_filename=$(void_rootfs_filename)'

.PHONY: blinc/void.base
blinc/void.base: src/base.Containerfile blinc/void.rootfs
	podman build -t '$@' -f '$<' '.'

.PHONY: blinc/void.pkgs-cli
blinc/void.pkgs-cli: src/pkgs-cli.Containerfile blinc/void.base
	podman build -t '$@' -f '$<' '.'

.PHONY: blinc/void.pkgs-desk
blinc/void.pkgs-desk: src/pkgs-desk.Containerfile blinc/void.pkgs-cli
	podman build -t '$@' -f '$<' '.'

.PHONY: blinc/void.cfg
blinc/void.cfg: src/cfg.Containerfile blinc/void.pkgs-desk
	podman build -t '$@' -f '$<' '.'
