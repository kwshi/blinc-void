# vi: ft=dockerfile
FROM "blinc/void.base"

WORKDIR "/opt/blinc/heroku"
RUN ["chown", "root:wheel", "."]
RUN ["chmod", "4755", "."]

ADD ["https://cli-assets.heroku.com/heroku-linux-x64.tar.gz", "heroku.tar.gz"]
RUN ["tar", "-xz", "--strip-components", "1", "-f", "heroku.tar.gz"]
