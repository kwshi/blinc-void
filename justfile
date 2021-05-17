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

download_dir := justfile_directory() + '/build/download'
vpkgs_dir := justfile_directory() + '/build/vpkgs'

tmp := '/tmp/blinc'

buildah_prefix := 'blinc-void'

rebuild := ''

_default:
  @just --choose

_lib:
  #!/bin/bash
  set -euo pipefail

  cat << 'EOF'

    function _log_with_prefix {
      echo $'\e[2m[blinc '"$(date +'%F %T %Z')"$']\e[m \e['"$1m""$2"$'\e[m' >&2
    }
    function log_phase { _log_with_prefix '96;1' "PHASE: $1"; }
    function log_done  { _log_with_prefix '32;1' "DONE: $1"$'\n';  }
    function log_err   { _log_with_prefix '91;1' "ERR: $1";   }
    function log       { _log_with_prefix '36'   "$1";        }

    function query_img_meta {
      local img date time offset zone
      if read -r img date time offset zone < <(
        buildah images --format '{{ '{{.ID}} {{.CreatedAtRaw}}' }}' \
          '{{buildah_prefix}}'/"$1" \
          2> /dev/null
      ); then
        echo "$img $(date -d "$date $time $offset" +'%s')"
      else return 1; fi
    }

    function fetch_opt {
      local out='{{download_dir}}'/"opt/$1/$3"
      mkdir -p '{{download_dir}}'/"opt/$1"

      log "fetching ${1@Q} (version ${2@Q})"
      curl -fsSL -o "$out" "$5"

      log "verifying checksum"
      sha256sum -c --quiet <<< "$4 $out"

      echo "$out"
    }

    function phase_img {
      local img ctr from img_name stamp parent parent_stamp

      log_phase "img/$1"

      if read -r img stamp < <(query_img_meta "$1"); then
        if [[ "${3+_}" == '_' ]] \
          && read -r parent parent_stamp < <(query_img_meta "$3") \
          && [[ "$parent_stamp" > "$stamp" ]]
        then
          log "existing image ${img@Q}, newer parent ${parent@Q}, overwriting"
        elif [[ "${force+_}" == '_' || '{{rebuild}}' == "img/$1" ]]; then
          log "existing image ${img@Q}, overwriting"
        else
          log 'image exists, skipping'
          log_done "img/$1"
          return
        fi
      fi

      if ctr="$(buildah containers -q -f name='{{buildah_prefix}}'/"$1" 2> /dev/null)" \
        && [[ -n "$ctr" ]]; then
        log "existing container ${ctr@Q}, overwriting"
        buildah rm "$ctr" > /dev/null
      fi

      if [[ "${3+_}" == '_' ]]; then from='{{buildah_prefix}}'/"$3"
      else from='scratch'; fi

      log 'creating container'
      ctr="$(buildah from --name '{{buildah_prefix}}'/"$1" "$from")"
      log "created container ${ctr@Q}"

      "$2" "$ctr"

      log 'committing container'
      buildah commit --rm "$ctr" '{{buildah_prefix}}'/"$1"

      log_done "img/$1"
    }

    function parse_args {
      while getopts 'fF' arg; do
        case "$arg" in
          f) force=;;
        esac
      done
    }

    set -euo pipefail
    parse_args "$@"
  EOF

# download and/or verify void rootfs
download *opts:
  #!/bin/bash
  . <(just _lib)

  log_phase 'download'

  function verify {
    signify -Cqp '{{void_key_path}}' -x 'sha256sum.sig' '{{void_rootfs_filename}}'
  }

  function download {
    mkdir -p '{{tmp}}/download'
    cd '{{tmp}}/download'

    log 'downloading rootfs'
    curl -fLo '{{void_rootfs_filename}}' '{{void_rootfs_url}}'

    log 'downloading sha256sum.sig'
    curl -fLo 'sha256sum.sig'            '{{void_sig_url}}'

    log 'verify signature and checksum...'
    verify

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
      verify
    fi
  else download; fi

  log_done 'download'

img-rootfs *opts: download
  #!/bin/bash
  . <(just _lib)
  function phase_img_rootfs {
    log 'extracting rootfs'
    buildah add -q "$1" '{{download_dir}}/{{void_rootfs_filename}}'
  }
  phase_img 'rootfs' 'phase_img_rootfs'

img-base *opts: img-rootfs
  #!/bin/bash
  . <(just _lib)
  function phase_img_base {
    buildah copy -q "$1" 'src/xbps'   '/etc/xbps.d'
    buildah copy -q "$1" 'src/dracut' '/etc/dracut.conf.d'
    buildah copy -q "$1" '/var/cache/xbps' '/var/cache/xbps'
    buildah run "$1" -- xbps-install -Suy 'xbps' 'base-files'
    buildah run "$1" -- xbps-install -uy
    buildah run "$1" -- xbps-install -y 'base-system' 'base-devel' 'curl' 'wget' 'git'

    buildah run "$1" -- useradd -rb '/opt/blinc' -G 'wheel' 'vpkgs'
    buildah run "$1" -- useradd -m -G 'wheel' 'kshi'
    buildah run "$1" -- usermod -s '/bin/bash' 'root'
  }
  phase_img 'base' 'phase_img_base' 'rootfs'

img-pkgs *opts: img-base
  #!/bin/bash
  . <(just _lib)

  declare -a pkgs lists
  declare name

  function phase_img_pkgs {
    log 'loading packages'
    pkgs=()
    while read -r line; do
      line="${line%%#*}"
      read -ra ps <<< "$line"
      for pkg in "${ps[@]}"; do pkgs+=("$pkg"); done
    done < '{{pkgs_dir}}'/"$name"
    log "loaded, ${#pkgs[@]} packages"

    buildah run "$1" -- xbps-install -y "${pkgs[@]}"
  }

  lists=('{{pkgs_dir}}'/*)
  for (( i = 0; i < ${#lists[@]}; ++i )); do
    name="${lists[i]##*/}"
    if [[ $i == 0 ]]; then prev='base'; else prev="pkgs/${lists[i-1]##*/}"; fi
    phase_img "pkgs/$name" 'phase_img_pkgs' "$prev"
  done

  log_phase 'img/pkgs'
  log "tagging alias for final image: ${name@Q}"
  buildah tag '{{buildah_prefix}}/pkgs'/"$name" '{{buildah_prefix}}/pkgs'
  log_done 'img/pkgs'

img-xpkgs *opts: img-base
  #!/bin/bash
  . <(just _lib)

  cd '{{vpkgs_dir}}
  if [[ ! -e '.git' ]]; then
    git clone 'https://github.com/void-linux/void-packages' '.'
  fi

  git clean -df
  git reset --hard
  git checkout 'origin/master'


img-opt *opts: img-base
  #!/bin/bash
  . <(just _lib)

  function phase_img_opt {
    buildah config --workingdir "/opt/blinc/$name" "$1"
    ( . '{{opt_dir}}'/"$name" )
  }

  for script in '{{opt_dir}}'/*; do
    name="${script##*/}"
    phase_img "opt/$name" 'phase_img_opt' 'base'
  done


img-home *opts: img-base
  #!/bin/bash
  . <(just _lib)

  function phase_home {
  }

img-final *opts: img-pkgs
  #!/bin/bash
  . <(just _lib)

  function phase_final {
  }

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
