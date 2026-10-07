#!/usr/bin/env bash
# Set up the local Quartz site that renders the work vault (see the `daily`
# command). Run it once on a new machine, and again after a change to the pin
# below. It is safe to run again.
#
# Needs Node 22 or later. It downloads Quartz and its npm packages.
set -euo pipefail

# The folder of this script: ~/.config/quartz-vault, or the chezmoi source
# before `chezmoi apply` has made that link.
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
quartz="$HOME/.local/share/quartz"
vault="${PLANNER_VAULT:-$HOME/Projects/vaults/work}"
# The Quartz commit that this config and the patch below were tested on.
pin=97a2d05f80c4c50534959b1d0d41cc4b3895625e

fail() {
  echo "setup.sh: $*" >&2
  exit 1
}

# A running server would use files that change below. A server that started
# before the localhost patch also listens on all interfaces.
if pkill -f "quartz build --serve"; then
  echo "setup.sh: stopped the running Quartz server" >&2
fi

if [[ ! -d $quartz/.git ]]; then
  git clone --quiet https://github.com/jackyzha0/quartz.git "$quartz"
fi
cd "$quartz"
if [[ $(git rev-parse HEAD) != "$pin" ]]; then
  git cat-file -e "$pin^{commit}" 2>/dev/null || git fetch --quiet origin
  # Undo the edits that this script and `plugin install` make; both run again below.
  git checkout --quiet -- package.json package-lock.json quartz/cli/handlers.js quartz/styles/custom.scss
  git checkout --quiet "$pin"
fi
# npm ci deletes node_modules, so it runs only for a new pin.
if [[ $(cat node_modules/.setup-pin 2>/dev/null) != "$pin" ]]; then
  npm ci --no-audit --no-fund
  echo "$pin" >node_modules/.setup-pin
fi

# Quartz reads the vault through content/, and the config and styles from here.
if [[ ! -L content ]]; then
  rm -rf content
  ln -s "$vault" content
fi
ln -sf "$here/quartz.config.yaml" quartz.config.yaml
ln -sf "$here/custom.scss" quartz/styles/custom.scss
# The config loads this local plugin as ./vault-keys.
ln -sfn "$here/vault-keys" vault-keys
npx quartz plugin install --from-config

# Upstream listens on all interfaces, which shares the vault with the network.
listen='server.listen(argv.port, "127.0.0.1")'
ws='new WebSocketServer({ port: argv.wsPort, host: "127.0.0.1" })'
sed -i '' \
  -e "s/server\.listen(argv\.port)\$/$listen/" \
  -e "s/new WebSocketServer({ port: argv\.wsPort })/$ws/" \
  quartz/cli/handlers.js
grep -qF "$listen" quartz/cli/handlers.js ||
  fail "could not bind the server to 127.0.0.1; the listen line in quartz/cli/handlers.js changed upstream"
grep -qF "$ws" quartz/cli/handlers.js ||
  fail "could not bind the WebSocket server to 127.0.0.1; its line in quartz/cli/handlers.js changed upstream"

echo "Quartz is ready. Run: daily"
