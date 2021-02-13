# vi: ft=dockerfile
FROM "blinc/void.base"

RUN xbps-install -y \
  "opam" \
  "gmp" "gmp-devel" \
  "lapacke" "lapacke-devel" \
  "openblas" "openblas-devel" \
  "cblas" "cblas-devel" \
  "zlib" "zlib-devel" \
  "libressl" "libressl-devel" \
  "bubblewrap"

WORKDIR "/opt/blinc/opam"
RUN ["chown", "opam:wheel", "."]
RUN ["chmod", "2775", "."]

USER "opam"
ENV "OPAMYES"="1"

RUN ["opam", "init", "-n", "--disable-sandboxing"]
RUN ["chown", "-R", "opam:wheel", "."]
RUN ["chmod", "g+s", ".", ".opam"]

RUN ["opam", "install", "dune", "utop"]
RUN ["opam", "install", "odoc", "odig"]
RUN ["opam", "install", "ocp-indent", "ocp-browser", "ocp-index"]
RUN ["opam", "install", "ocaml-lsp-server", "ocamlformat"]
RUN ["opam", "install", "containers", "alcotest", "lwt"]
RUN ["opam", "install", "ANSITerminal", "fmt", "uutf", "linenoise", "zed"]
RUN ["opam", "install", "menhir", "sedlex", "angstrom"]
RUN ["opam", "install", "yojson", "toml"]
RUN ["opam", "install", "tyxml", "lambdasoup"]
RUN ["opam", "install", "owl", "zarith"]
RUN ["opam", "install", "h2", "h2-lwt", "h2-lwt-unix"]
RUN ["opam", "install", "obus"]
RUN ["opam", "install", "pgocaml", "pgocaml_ppx"]
RUN ["opam", "install", "parmap"]

# temporary fix for cohttp
RUN ["opam", "pin", "add", "ssl", "0.5.9"]
RUN ["opam", "pin", "add", "cohttp.3.0.0", "--dev-repo"]
RUN ["opam", "install", "cohttp", "cohttp-lwt", "cohttp-lwt-unix-ssl"]
