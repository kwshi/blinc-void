export VOID_RELEASE_URL := https://alpha.us.repo.voidlinux.org/live/current
export VOID_VERSION     := 20191109
export VOID_SIGNIFY_KEY := sigs/void-release-$(VOID_VERSION).pub

export void_rootfs_filename := void-x86_64-ROOTFS-$(VOID_VERSION).tar.xz

build:
	mkdir 'build'

build/download: | build
	mkdir 'build/download'

build/phase: | build
	mkdir 'build/phase'

build/phase/core: | build/phase
	mkdir 'build/phase/core'

build/download/sha256.sig: | build/download
	curl -fLo 'build/download/sha256.sig' '$(VOID_RELEASE_URL)/sha256.sig'

build/download/$(void_rootfs_filename): build/download/sha256.sig | $(VOID_SIGNIFY_KEY)
	cd 'build/download' \
		&& curl -fLO '$(VOID_RELEASE_URL)/$(void_rootfs_filename)' \
		&& signify -C -p '$(VOID_SIGNIFY_KEY)' -x 'sha256.sig' '$(void_rootfs_filename)'

build/phase/base: script/base.sh build/download/$(void_rootfs_filename) | build/phase
	'$<' 'build/download/$(void_rootfs_filename)'

build/phase/core/util: script/core/util.sh build/phase/base | build/phase/core
	'$<'
