VOID_RELEASE_URL := https://alpha.us.repo.voidlinux.org/live/current
VOID_VERSION     := 20191109
VOID_SIGNIFY_KEY := /etc/signify/void-release-$(VOID_VERSION).pub

void_rootfs_filename := void-x86_64-ROOTFS-$(VOID_VERSION).tar.xz

export OUTPUT_DIR := 'build'

$(VOID_SIGNIFY_KEY):
	sudo xbps-install -y 'void-release-keys'

build/download/sha256.sig:
	curl -fLo 'build/download/sha256.sig' '$(VOID_RELEASE_URL)/sha256.sig'

build/download/$(void_rootfs_filename): $(VOID_SIGNIFY_KEY) build/download/sha256.sig
	cd 'build/download' \
		&& curl -fLO '$(VOID_RELEASE_URL)/$(void_rootfs_filename)' \
		&& signify -C -p '$(VOID_SIGNIFY_KEY)' -x 'sha256.sig' '$(void_rootfs_filename)'

build/phase/base: build/download/$(void_rootfs_filename)
	scripts/base.sh

