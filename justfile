void_repo_url := 'https://alpha.us.repo.voidlinux.org/live/current'
void_version  := '20210218'

void_rootfs_filename := 'void-x86_64-ROOTFS-' + void_version + '.tar.xz'
void_rootfs_url      := void_repo_url + '/' + void_rootfs_filename
void_sig_url         := void_repo_url + '/sha256sum.sig'

void_key_filename    := 'void-release-' + void_version + '.pub'
void_key_path        := invocation_directory() + '/sigs/' + void_key_filename

set positional-arguments

download_dir := invocation_directory() + '/build/download'
tmp := '/tmp/blinc'

_default:
  @just --choose

_lib:
  #!/bin/bash
  set -euo pipefail
  cat << 'EOF'

  log_prefix=$'\e[2m[blinc]\e[m '
  function _log_with_prefix {
    echo $'\e[2m[blinc '"$(date +'%F %T %Z')"$']\e[m \e['"$1m""$2"$'\e[m' >&2
  }
  function log_phase { _log_with_prefix '96;1' "PHASE: $1"; }
  function log_done  { _log_with_prefix '92;1' "DONE: $1";  }
  function log_err   { _log_with_prefix '91;1' "ERR: $1";   }
  function log       { _log_with_prefix '36'   "$1";        }

  function parse_args {
    while getopts 'f' arg; do
      case "$arg" in
        f) force=;;
      esac
    done
  }
  parse_args "$@"

  EOF

# download and/or verify void rootfs
download *opts:
  #!/bin/bash
  set -euo pipefail

  . <(just _lib)

  log_phase 'download'

  function download {
    mkdir -p '{{tmp}}/download'
    cd '{{tmp}}/download'

    log 'downloading rootfs'
    curl -fLo '{{void_rootfs_filename}}' '{{void_rootfs_url}}'

    log 'downloading sha256sum.sig'
    curl -fLo 'sha256sum.sig'            '{{void_sig_url}}'

    log 'verify signature and checksum...'
    signify -Cp '{{void_key_path}}' -x 'sha256sum.sig' '{{void_rootfs_filename}}'

    mkdir -p '{{download_dir}}'
    cp --no-preserve 'mode' -t '{{download_dir}}' \
      '{{void_rootfs_filename}}' 'sha256sum.sig'
  }

  if [[ 
    -e '{{download_dir}}/{{void_rootfs_filename}}' &&
    -e '{{download_dir}}/sha256sum.sig'
  ]]; then
    if [[ "${force+_}" == '_' ]]; then
      log 'existing download detected, overwriting'
      download
    else
      log 'existing download detected, verification only'
      cd '{{download_dir}}'
      signify -Cp '{{void_key_path}}' -x 'sha256sum.sig' '{{void_rootfs_filename}}'
    fi
  else download; fi

  log_done 'download'

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
#
#$(build)/log/rootfs: src/rootfs.Containerfile \
#	$(build)/download/$(void_rootfs_filename) \
#	| $(build)/log $(tmp)/log
#	$(podman_build) \
#		--build-arg 'void_rootfs_filename=$(void_rootfs_filename)' \
#		| tee '$(tmp)/log/$(notdir $@)' \
#		&& cp --no-preserve 'mode' '$(tmp)/log/$(notdir $@)' '$@'
#
#$(build)/log/base: src/base.Containerfile $(build)/log/rootfs
#	$(podman_build_tee)
#
#$(build)/log/pkgs-cli: src/pkgs-cli.Containerfile $(build)/log/base
#	$(podman_build_tee)
#
#$(build)/log/pkgs-desk: src/pkgs-desk.Containerfile $(build)/log/pkgs-cli
#	$(podman_build_tee)
#
#$(build)/log/opt.%: src/opt/%.Containerfile $(build)/log/base
#	$(podman_build_tee)
#
#$(build)/log/skel.%: src/home/%.Containerfile $(build)/log/base
#	$(podman_build_tee)
#
#$(build)/log/opt: \
#	src/opt.Containerfile \
#	$(build)/log/pkgs-desk \
#	$(build)/log/opt.pip \
#	$(build)/log/opt.poetry \
#	$(build)/log/opt.npm \
#	$(build)/log/opt.vpkgs \
#	$(build)/log/opt.deno \
#	$(build)/log/opt.nvim \
#	$(build)/log/opt.elm \
#	$(build)/log/opt.heroku \
#	$(build)/log/opt.talon \
#	$(build)/log/opt.opam \
#	$(build)/log/opt.rust \
#	$(build)/log/opt.noisetorch \
#	$(build)/log/opt.breaktimer \
#	$(build)/log/opt.cadmus
#	$(podman_build_tee)
#
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
#$(build)/prep/kernel: $(build)/prep/mnt
#	paths=('$(mnt)/lib/modules/'*) \
#	&& for p in "$${paths[@]}"; do basename "$$p"; done \
#	| sort -V | tail -n 1 > '$@'
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
