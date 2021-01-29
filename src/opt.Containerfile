# vi: ft=dockerfile
FROM "blinc/void.pkgs-desk"

COPY --from="blinc/void.opt.opam"   ["/opt/blinc", "/opt/blinc"]
COPY --from="blinc/void.opt.pip"    ["/opt/blinc", "/opt/blinc"]
COPY --from="blinc/void.opt.npm"    ["/opt/blinc", "/opt/blinc"]
COPY --from="blinc/void.opt.poetry" ["/opt/blinc", "/opt/blinc"]
COPY --from="blinc/void.opt.deno"   ["/opt/blinc", "/opt/blinc"]
COPY --from="blinc/void.opt.elm"    ["/opt/blinc", "/opt/blinc"]
COPY --from="blinc/void.opt.nvim"   ["/opt/blinc", "/opt/blinc"]
COPY --from="blinc/void.opt.heroku" ["/opt/blinc", "/opt/blinc"]
