export VOID_RELEASE_URL := https://alpha.us.repo.voidlinux.org/live/current
export VOID_VERSION     := 20191109
export VOID_SIGNIFY_KEY := sigs/void-release-$(VOID_VERSION).pub

export build_dir            := build
export script_dir           := scripts
export void_rootfs_filename := void-x86_64-ROOTFS-$(VOID_VERSION).tar.xz
export download_dir         := $(build_dir)/download
export phase_dir            := $(build_dir)/phase

$(build_dir):
	mkdir '$(build_dir)'

$(download_dir): | $(build_dir)
	mkdir '$(download_dir)'

$(phase_dir): | $(build_dir)
	mkdir '$(phase_dir)'

$(download_dir)/sha256.sig: | $(download_dir)
	curl -fLo '$(download_dir)/sha256.sig' '$(VOID_RELEASE_URL)/sha256.sig'

$(download_dir)/$(void_rootfs_filename): $(download_dir)/sha256.sig | $(VOID_SIGNIFY_KEY) $(download_dir)
	cd '$(download_dir)' \
		&& curl -fLO '$(VOID_RELEASE_URL)/$(void_rootfs_filename)' \
		&& signify -C -p '$(VOID_SIGNIFY_KEY)' -x 'sha256.sig' '$(void_rootfs_filename)'

$(phase_dir)/base: $(script_dir)/base.sh $(download_dir)/$(void_rootfs_filename) | $(phase_dir)
	'$<' '$(download_dir)/$(void_rootfs_filename)'



