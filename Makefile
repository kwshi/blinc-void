SHELL := /bin/bash -o pipefail

export VOID_RELEASE_URL := https://alpha.us.repo.voidlinux.org/live/current
export VOID_VERSION     := 20191109

void_signify_key := sigs/void-release-$(VOID_VERSION).pub
void_rootfs_filename := void-x86_64-ROOTFS-$(VOID_VERSION).tar.xz

tmpdir := /tmp/blinc-void

podman_build = podman build -t 'blinc/void.$(notdir $@)' -f '$<' '.'
podman_build_tee = $(podman_build) \
									 | tee '$(tmpdir)/$@' \
									 && cp --no-preserve 'mode' '$(tmpdir)/$@' '$@'

download:
	mkdir -p 'download'

log:
	mkdir -p 'log'

$(tmpdir)/%:
	mkdir -p '$@'

download/$(void_rootfs_filename): $(void_signify_key) | download $(tmpdir)/download
	cd '$(tmpdir)/download' \
	&& curl -fLo '$(void_rootfs_filename)' \
	  '$(VOID_RELEASE_URL)/$(void_rootfs_filename)' \
	&& curl -fLo 'sha256.sig' \
	  '$(VOID_RELEASE_URL)/sha256.sig' \
	&& signify -Cp '$(CURDIR)/$(void_signify_key)' \
	  -x 'sha256.sig' \
	  '$(void_rootfs_filename)' \
	&& cp --no-preserve 'mode' -t '$(CURDIR)/download' \
	  '$(void_rootfs_filename)'

log/rootfs: src/rootfs.Containerfile download/$(void_rootfs_filename) | log $(tmpdir)/log
	$(podman_build) \
		--build-arg 'void_rootfs_filename=$(void_rootfs_filename)' \
		| tee '$(tmpdir)/$@' \
		&& cp --no-preserve 'mode' '$(tmpdir)/$@' '$@'

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
	log/pkgs-desk \
	log/opt.pip \
	log/opt.poetry \
	log/opt.npm \
	log/opt.vpkgs \
	log/opt.deno \
	log/opt.nvim \
	log/opt.elm \
	log/opt.heroku \
	log/opt.talon \
	log/opt.opam \
	log/opt.noisetorch \
	log/opt.breaktimer \
	log/opt.cadmus
	$(podman_build_tee)

log/cfg: src/cfg.Containerfile log/opt dotfiles
	$(podman_build_tee)
