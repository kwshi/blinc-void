#!/bin/bash -e
# vim:textwidth=60 fo-=t

prefix () {
  printf '\033[0;2m[\033[0;32m%s\033[0;2m | \033[0;34m%s\033[0;2m]\033[m\n' \
    "$prog" "$(date '+%F %T')"
}

log () {
  printf '%b %b\n' "$(prefix)" \
    "$(fmt_msg <<< "$1")" \
    >&2
}

main () {
  while getopts 'hn:' f
  do
    case "$f" in
      'n') opt_name="$OPTARG";;
      'h') help; exit 0;;
      '?') help >&2; exit 1;;
    esac
  done
  shift $((OPTIND - 1))

  if [ -z "$1" ]; then help 'no <!command> specified' >&2; exit 1; fi

  if [ -n "$opt_name" ]; then log "using output image name \"$opt_name\""; fi

  cmd="$1"
  shift 1
  case "$cmd" in
    'help') help; exit 0;;
    'base') cmd_base "$@";;
    'pkgs') cmd_pkgs "$@";;
    *) help "invalid command \"$1\""; exit 1;;
  esac
}

cleanup () {
  status=$?
  trap '' 'EXIT'
  case "$1" in
    'EXIT') ;;
    'HUP')  status=129;;
    'INT')  status=130;;
    'QUIT') status=131;;
    'TERM') status=143;;
  esac
  echo >&2
  if [ "$1" != 'EXIT' ]
  then log "received signal \`$1\`, trying to exit gracefully..."
  fi
  log 'cleaning up...'
  log '  removing container...'
  log "    done: \"$(buildah rm "$ctr")\""
  log 'all cleaned up; exiting now.'
  exit "$status"
}

commit () {
  log 'committing image...'
  img="$(buildah commit "$ctr" "$opt_name")"
  log "done committing image: \"$img\"" "${opt_name:+ (name \"$opt_name\")}"
  echo "$img"
}

cmd_base () {
  if [ -z "${1+_}" ]
  then 
    help 'no <rootfs> given' >&2
    exit 1
  fi
  if [ ! -e "$1" ] 
  then 
    help "rootfs \"$1\" does not exist" >&2
    exit 1
  fi
  if [ ! -r "$1" ]
  then
    help "rootfs \"$1\" is not readable (check permissions?)" >&2
    exit 1
  fi
  rootfs="$1"

  log "using rootfs \"$rootfs\""

  log 'initializing container...'
  ctr="$(buildah from 'scratch')"
  trap 'cleanup EXIT' 'EXIT'
  trap 'cleanup HUP'  'HUP'
  trap 'cleanup INT'  'INT'
  trap 'cleanup QUIT' 'QUIT'
  trap 'cleanup TERM' 'TERM'
  log "done initializing container: \"$ctr\""

  log 'adding rootfs...'
  add="$(buildah add "$ctr" "$rootfs")"
  log "done adding rootfs: \"$add\""

  log 'updating packages...'
  buildah run "$ctr" -- xbps-install -Suy >&2
  log 'done updating packages'

  commit
}

cmd_pkgs () {
  if [ -z "${1+_}" ]; then help 'no <from> image specified' >&2; exit 1; fi
  from="$1"

  shift
  if [ $# -eq 0 ]; then help 'no <pkg-list> files given' >&2; exit 1; fi

  for list in "$@"
  do 
    if [ ! -e "$list" ]
    then
      help "file \"$list\" does not exist"
      exit 1
    fi
    if [ ! -r "$list" ] 
    then
      help "file \"$list\" is not readable (check permissions?)"
      exit 1
    fi
  done

  log 'initializing container...'
  ctr="$(buildah from "$from")"
  trap 'cleanup EXIT' 'EXIT'
  trap 'cleanup HUP'  'HUP'
  trap 'cleanup INT'  'INT'
  trap 'cleanup QUIT' 'QUIT'
  trap 'cleanup TERM' 'TERM'
  log "done initializing container: \"$ctr\""

  for list in "$@"
  do 
    log "adding packages from \"$list\"..."

    readarray -t pkgs < "$list"
    log "packages to add: $(sed -e 's/[^ ]\+/"&"/g' <<< "${pkgs[*]}")"

    # TODO: ctrl-c doesn't seem to work, may be an issue
    # with buildah
    buildah run "$ctr" -- xbps-install -y "${pkgs[@]}" >&2
    log "done adding packages from \"$list\""
  done

  commit
}

sed_quote () {
  printf 's/%s/%s/g' \
    "$2\\([^$3]\\+\\)$3" \
    "\\\\033[$1;2m$2\\\\033[22m\\1\\\\033[21;2m$3\\\\033[m"
}
sed_opt="$(
printf 's/%s/%s/g' \
  '\(^\| \)-\([A-Za-z0-9]\+\)\([^A-Za-z]\|$\)' \
  '\1\\033[1;2m-\\033[22;1m\2\\033[21m\3'
)"
sed_var="$(sed_quote '96;3' '<' '>')"
sed_strs="$(sed_quote '96' "'" "'")"
sed_strd="$(sed_quote '96' '"' '"')"
sed_code="$(sed_quote '95' '`' '`')"
sed_cmd='s|!\([0-9A-Za-z./_-]\+\)|\\033[1m\1\\033[21m|g'
sed_punct='s/[][()|]\|\.\.\./\\033[2m&\\033[22m/g'
sed_head='s/^[A-Za-z ]\+:/\\033[0;1;92m&\\033[m/'
sed_err='s/^[A-Za-z ]\+:/\\033[0;1;91m&\\033[m/'

function fmt_misc {
  sed -e "$sed_cmd" -e "$sed_opt" -e "$sed_var" \
    -e "$sed_code" -e "$sed_strs" -e "$sed_strd"
}

fmt_msg () {
  sed -e "$sed_punct" | fmt_misc
}

fmt_err () {
  sed -e "$sed_err" | fmt_misc
}

fmt_help () {
  sed -e "$sed_punct" -e "$sed_head" | fmt_misc
}

prog="${0##*/}"
help="$(fmt_help << EOF
usage: !$prog [-n <name> | -h] <!command> [<args>...]

Builds a Void container image according to <!command> and
prints the resulting image ID to stdout.

commands:
  !base <rootfs>
    Unpack the Void <rootfs> archive into a new image from
    scratch and runs \`xbps-install -Suy\` to update its
    base packages.
  
  !pkgs <from> <pkg-list>...
    Starting with base image <from>, run \`xbps-install -y\`
    on packages listed in each <pkg-list> file.  Each
    <pkg-list> file should be formatted as a
    whitespace-delimited list of package names.

  !help
    Show this help message (same as -h).

options:
  -n <name>
     Name the resulting image as <name>.  If
     omitted or empty, the resulting image will not be
     named.
  -h
     Show this help message.

examples:
  !$prog           !base 'void-x86_64-ROOTFS-20191109.tar.xz'
  !$prog -n 'musl' !base 'void-x86_64-musl-ROOTFS-20191109.tar.xz'
  
  !$prog -n 'core' !pkgs 'xbps' 'edit' 'lang'
EOF
)"

help () {
  if [ -n "$1" ]
  then printf '%b\n' "$(fmt_err <<< "$1")"
  fi
  printf '%b\n' "$help"
}

main "$@"
