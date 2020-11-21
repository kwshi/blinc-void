log () {
  fmt="$1"
  shift
  printf "$fmt\n" $@ >&2
}
