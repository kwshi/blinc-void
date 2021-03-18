# vi: ft=dockerfile
FROM "blinc/void.base"

RUN ["xbps-install", "-y", "nodejs"]

WORKDIR "/opt/blinc/npm"
RUN ["chown", "npm:wheel", "."]
RUN ["chmod", "2775", "."]

USER "npm"
ENV "NPM_CONFIG_PREFIX"="/opt/blinc/npm"
ENV "NPM_CONFIG_GLOBAL"="1"

RUN ["npm", "i", "pnpm", "yarn"]
RUN ["npm", "i", "typescript", "ttypescript"]
RUN ["npm", "i", "prettier", "eslint", "typescript-language-server"]
RUN ["npm", "i", "webpack", "webpack-cli", "parcel@next"]
RUN ["npm", "i", "netlify-cli", "vercel"]
RUN ["npm", "i", "@elm-tooling/elm-language-server", "elm-format", "elm-test"]
RUN ["npm", "i", "svelte-language-server"]
