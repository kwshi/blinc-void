log () {
  fmt="$1"
  shift
  printf "$fmt\n" "$@" >&2
}

indent () {
  while IFS='' read -r line
  do echo "  $line"
  done
}

help () {
  if [ ! -z "$1" ]
  then
    log '\n%b %b' \
      "$(printf_err_header 'usage error:')" \
      "$(echo "$1" | fmt_vars)"
  fi
  if [ ! -z "$USAGE" ]
  then
    log '\n%b %b' \
      "$(printf_header 'usage:')" \
      "$(echo "$USAGE" | fmt_usage)"
  fi
  if [ ! -z "$DESCRIPTION" ]
  then
    log '\n%b' "$(echo "$DESCRIPTION" | fmt_desc)"
  fi
  if [ ! -z "$OPTIONS" ]
  then
    log '\n%b\n%b' \
      "$(printf_header 'options:')" \
      "$(echo "$OPTIONS" | fmt_options)"
  fi
  if [ ! -z "$EXAMPLES" ]
  then
    log '\n%b\n%b' \
      "$(printf_header 'examples:')" \
      "$(echo "$EXAMPLES" | fmt_examples)"
  fi
  log ''
  exit 1
}

with_buildah_from () {
  ctr="$(buildah from "$from")"
  trap "buildah rm '$ctr'" EXIT
  echo "$ctr"
}

parse_common_opts () {
  while getopts 'hn:' f
  do
    case "$f" in
      'n') opt_name="$OPTARG";;
      'h'|'?') help;;
    esac
  done
  echo "$((OPTIND - 1))"
}

printf_err_header() {
  printf '\033[0;1;91m%s\033[m' "$1"
}

printf_header () {
  printf '\033[0;1;96m%s\033[m' "$1"
}

fmt_vars () {
  sed -e 's/<[^>]\+>/\\033[0;3;95m&\\033[m/g'
}

fmt_opt () {
  sed -e 's/\(-[A-Za-z0-9]\)\([^A-Za-z0-9]\|$\)/\\033[1m\1\\033[21m\2/g'
}

fmt_cmd () {
  sed -e 's/^ *[^ ]\+/\\033[0;36m&\\033[m/g'
}

fmt_usage () {
  sed -e 's/[][|]\|\.\{3\}/\\033[0;2m&\\033[m/g' \
    | fmt_cmd | fmt_opt | fmt_vars
}

fmt_str () {
  sed \
    -e "s/'\\([^']\\+\\)'/\\\\033[0;2;95m'\\\\033[22m\\1\\\\033[2m'\\\\033[m/g" \
    -e 's/"\([^"]\+\)"/\\033[0;2;95m"\\033[22m\1\\033[2m"\\\\033[m/g'
}

fmt_desc () {
  sed -e 's/`\([^`]\+\)`/\\033[0;2;94m`\\033[22m\1\\033[2m`\\033[m/g' \
    | fmt_vars | fmt_opt
}

fmt_options () {
  indent | fmt_opt | fmt_vars
}

fmt_examples () {
  sed -e 's/\\/\\033[0;2m\\\\\\033[m/g' \
    | indent | fmt_cmd | fmt_opt | fmt_vars | fmt_str
}

COMMON_OPTIONS_USAGE='[-n <name> | -h]'
COMMON_OPTIONS_HELP="$(cat << EOF
-n <name>
  Name the resulting image as \033[3;36m<name>\033[m.  If omitted or empty, the resulting image will not be named.
-h
  Show this help message.
EOF
)"
