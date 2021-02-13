# vi: ft=dockerfile
FROM "blinc/void.base"

RUN ["xbps-install", "-y", "python3"]

WORKDIR "/opt/blinc/poetry"
RUN ["chmod", "2775", "."]
RUN ["chown", "poetry:wheel", "."]

USER "poetry"
ENV "POETRY_URL"="https://raw.githubusercontent.com/python-poetry/poetry/master"
ENV "POETRY_ACCEPT"="1"
ADD --chown="poetry":"poetry" ["$POETRY_URL/get-poetry.py", "."]
RUN ["python3", "get-poetry.py"]
RUN ["chmod", "g+rwx", ".poetry/bin/poetry"]

RUN ["mkdir", "global"]
WORKDIR "global"
ENV "POETRY_VIRTUALENVS_IN_PROJECT"="1"
RUN ["../.poetry/bin/poetry", "init", "-n"]
RUN ["../.poetry/bin/poetry", "add", "-n", "black"]
