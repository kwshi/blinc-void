SHELL := /bin/bash

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

build/phase/cli: | build/phase
	mkdir 'build/phase/cli'

build/phase/desk: | build/phase
	mkdir 'build/phase/desk'

build/download/sha256.sig: | build/download
	curl -fLo 'build/download/sha256.sig' '$(VOID_RELEASE_URL)/sha256.sig'

build/download/$(void_rootfs_filename): build/download/sha256.sig | $(VOID_SIGNIFY_KEY)
	cd 'build/download' \
		&& curl -fLO '$(VOID_RELEASE_URL)/$(void_rootfs_filename)' \
		&& signify -C -p '$(VOID_SIGNIFY_KEY)' -x 'sha256.sig' '$(void_rootfs_filename)'

build/phase/root: build/download/$(void_rootfs_filename) | build/phase
	./blinc -o '$@' root '$<'

build/phase/base: build/phase/root pkgs/base
	./blinc -o '$@' pkgs '$(file < $<)' 'pkgs/base'

build/phase/cli/util: build/phase/base pkgs/cli/util | build/phase/cli
	./blinc -o '$@' pkgs '$(file < $<)' 'pkgs/cli/util'

build/phase/cli/edit: build/phase/cli/util pkgs/cli/edit 
	./blinc -o '$@' pkgs '$(file < $<)' 'pkgs/cli/edit'

build/phase/cli/lang: build/phase/cli/edit pkgs/cli/lang 
	./blinc -o '$@' pkgs '$(file < $<)' 'pkgs/cli/lang'

build/phase/cli/wifi: build/phase/cli/edit pkgs/cli/wifi 
	./blinc -o '$@' pkgs '$(file < $<)' 'pkgs/cli/wifi'

build/phase/desk/core: build/phase/desk/core pkgs/desk/core | build/phase/desk
	./blinc -o '$@' pkgs '$(file < $<)' 'pkgs/desk/core'

space:=$(empty) $(empty)
split=$(subst :, ,$(basename $1))
head=$(firstword $(call split,$1))
tail=$(subst $(space),:,$(wordlist 2,$(words $(call split,$1)),$(call split,$1)))

dep=$()


	#echo "$(shell f='$(basename $@)'; echo "$${f##*:}")"
	#echo "$(shell f='$@'; echo "$${f%:*}")"
#$(shell f='$(basename '$@')'; g="${f##*:}"; if [ "$f" != "$g" ]; then echo "$g"; fi)
.PHONY: %.stamp
%.stamp: $(shell echo '%.abc')
	echo "$@" "$^"

.PHONY: %.abc
%.abc: 
	echo hi
