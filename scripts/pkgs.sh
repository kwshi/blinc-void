#!/bin/sh -e

. 'scripts/lib.sh'

USAGE="$0 $COMMON_OPTIONS_USAGE <from> <pkg-list>..."

DESCRIPTION="$(cat << EOF
Builds and commits (using buildah) a container image from base image <from>, running \`xbps-install -y\` on packages listed in the <pkg-list> files.  Each <pkg-list> file should contain a whitespace-delimited list of package names.

The resulting image ID will be printed to stdout.
EOF
)"

OPTIONS="$COMMON_OPTIONS_HELP"

EXAMPLES="$(cat << EOF
$0 'docker.io/voidlinux/voidlinux' 'pkgs/cli/core'

$0 'docker.io/voidlinux/voidlinux' \\\\
  'pkgs/cli/core' 'pkgs/cli/edit'
EOF
)"

shift "$(parse_common_opts "$@")"

from="$1"
if [ -z "$from" ]; then help '<from-image> argument missing/empty'; fi
shift
if [ $# -eq 0 ]; then help 'no <pkg-list> arguments provided'; fi

ctr="$(with_buildah_from "$from")"

for list in "$@"
do xargs -a "$list" -- buildah run "$ctr" -- xbps-install -y
done

buildah commit "$ctr" "$opt_name"
