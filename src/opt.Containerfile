# vi: ft=dockerfile
FROM "blinc/void.pkgs-desk"

ADD ["https://flathub.org/repo/flathub.flatpakrepo", "etc/flatpak/remotes.d/flathub.conf"]
RUN ["flatpak", "install", "flathub", "us.zoom.Zoom"]

COPY --from="blinc/void.opt.opam"    ["/opt/blinc", "/opt/blinc"]
COPY --from="blinc/void.pip.opam"    ["/opt/blinc", "/opt/blinc"]
COPY --from="blinc/void.npm.opam"    ["/opt/blinc", "/opt/blinc"]
COPY --from="blinc/void.poetry.opam" ["/opt/blinc", "/opt/blinc"]
COPY --from="blinc/void.deno.opam"   ["/opt/blinc", "/opt/blinc"]
COPY --from="blinc/void.elm.opam"    ["/opt/blinc", "/opt/blinc"]
COPY --from="blinc/void.nvim.opam"   ["/opt/blinc", "/opt/blinc"]
