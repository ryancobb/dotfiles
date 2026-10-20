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
# The Quartz commit that this config and quartz.patch were tested on.
pin=97a2d05f80c4c50534959b1d0d41cc4b3895625e
# Local changes to upstream Quartz; each hunk says why. `daily` refuses to
# start a server without them.
patch="$here/quartz.patch"

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
patched=$(git apply --numstat "$patch" | cut -f3)
if [[ $(git rev-parse HEAD) != "$pin" ]]; then
  git cat-file -e "$pin^{commit}" 2>/dev/null || git fetch --quiet origin
  # Undo the edits that this script and `plugin install` make; both run again below.
  # shellcheck disable=SC2086 # one path per word
  git checkout --quiet -- package.json package-lock.json quartz/styles/custom.scss $patched
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
# custom.scss imports _cozycabin.scss, the palette tokens that cozycabin-apply
# renders from .chezmoidata/cozycabin.yaml; git does not hold the rendered file.
cozycabin-apply --render
# The config loads these local plugins as ./vault-keys, ./mr-diff, and
# ./graph-vendor.
ln -sfn "$here/vault-keys" vault-keys
ln -sfn "$here/mr-diff" mr-diff
ln -sfn "$here/graph-vendor" graph-vendor
npx quartz plugin install --from-config

# The graph loads d3 and pixi.js from jsdelivr, at floating versions, into the
# vault's origin. Point it at the pinned copies that graph-vendor serves.
graph=node_modules/@quartz-community/graph/dist
sed -i '' \
  -e 's#https://cdn\.jsdelivr\.net/npm/d3@7/dist/d3\.min\.js#/static/graph-vendor/d3.min.js#g' \
  -e 's#https://cdn\.jsdelivr\.net/npm/pixi\.js@8/dist/pixi\.js#/static/graph-vendor/pixi.min.js#g' \
  "$graph/index.js" "$graph/components/index.js"
if grep -q 'cdn\.jsdelivr\.net' "$graph/index.js" "$graph/components/index.js" ||
  ! grep -qF '/static/graph-vendor/pixi.min.js' "$graph/index.js"; then
  fail "the graph's script loader changed upstream; update the graph lines in setup.sh"
fi

# An older setup.sh patched these files with sed, so start from upstream.
if ! git apply --reverse --check "$patch" 2>/dev/null; then
  # shellcheck disable=SC2086 # one path per word
  git checkout --quiet -- $patched
  git apply "$patch" || fail "quartz.patch does not apply to Quartz $pin; update the patch"
fi

echo "Quartz is ready. Run: daily"
