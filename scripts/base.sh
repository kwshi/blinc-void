#!/bin/sh -e

. "scripts/lib.sh"

USAGE="$0 $COMMON_OPTIONS_USAGE <rootfs>"

DESCRIPTION="$(cat << EOF
Builds and commits (using buildah) a Void container image from scratch with the provided <rootfs> archive, updates its package repository, and installs the following base packages:

  base-system
  base-devel
  git
  acl-progs

The resulting image ID will be printed to stdout.
EOF
)"

OPTIONS="$COMMON_OPTIONS_HELP"

rootfs="$1"
if [ -z "$rootfs" ]; then help '<rootfs> argument missing/empty'; fi

ctr="$(with_buildah_from 'scratch')"

buildah add "$ctr" "$rootfs"
buildah run "$ctr" xbps-install -Suy \
  'base-system' 'base-devel' 'git' 'acl-progs'

buildah commit "$ctr" "$opt_name"
