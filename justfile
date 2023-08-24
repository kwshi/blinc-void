set positional-arguments
set dotenv-load

_default:
  @just --choose

build *args:
  script/main "$@"

rebuild:
  script/main -r 'img/base' 'img/final'

retry:
  script/main 'img/final'

main *args:
  script/main "$@"

pack name:
  script/build/main {{name}}

install name:
  sudo ./script/install {{name}}


# https://www.reddit.com/r/voidlinux/comments/aefcn5/how_to_increase_open_files_limit/

# LINE chromium --app=chrome-extension://ophjlpahpchlmihnnnihgmmeilfjmjjc/index.html
