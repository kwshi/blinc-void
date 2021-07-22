set positional-arguments

_default:
  @just --choose

build *args:
  script/main "$@"

pack name: (build 'img/final')
  script/build/main {{name}}

install name: (build name)
  sudo ./script/install {{name}}


# https://www.reddit.com/r/voidlinux/comments/aefcn5/how_to_increase_open_files_limit/

# LINE chromium --app=chrome-extension://ophjlpahpchlmihnnnihgmmeilfjmjjc/index.html
