# vi: ft=dockerfile
FROM "blinc/void.pkgs-desk"

COPY --from="blinc/void.opt.vpkgs"   ["/opt/blinc", "/opt/blinc"]
RUN xbps-install -yR /opt/blinc/vpkgs/hostdir/binpkgs/nonfree \
  zoom \
  slack-desktop \
  spotify
#discord

COPY --from="blinc/void.opt.opam"       ["/opt/blinc", "/opt/blinc"]
COPY --from="blinc/void.opt.pip"        ["/opt/blinc", "/opt/blinc"]
COPY --from="blinc/void.opt.npm"        ["/opt/blinc", "/opt/blinc"]
COPY --from="blinc/void.opt.poetry"     ["/opt/blinc", "/opt/blinc"]
COPY --from="blinc/void.opt.deno"       ["/opt/blinc", "/opt/blinc"]
COPY --from="blinc/void.opt.elm"        ["/opt/blinc", "/opt/blinc"]
COPY --from="blinc/void.opt.nvim"       ["/opt/blinc", "/opt/blinc"]
COPY --from="blinc/void.opt.heroku"     ["/opt/blinc", "/opt/blinc"]
COPY --from="blinc/void.opt.talon"      ["/opt/blinc", "/opt/blinc"]
COPY --from="blinc/void.opt.cadmus"     ["/opt/blinc", "/opt/blinc"]
COPY --from="blinc/void.opt.noisetorch" ["/opt/blinc", "/opt/blinc"]
#COPY --from="blinc/void.opt.sage"   ["/opt/blinc", "/opt/blinc"]
