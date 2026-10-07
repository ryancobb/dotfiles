// A Quartz plugin with no build step: it only ships client.js and client.css
// to every page. quartz.config.yaml loads it as a local source (./vault-keys),
// and setup.sh links that path into the Quartz clone. The files sit in dist/
// because `plugin install` runs npm install and a build for a plugin without one.
import fs from "node:fs"

const read = (name) => fs.readFileSync(new URL(name, import.meta.url), "utf-8")

export const manifest = {
  name: "vault-keys",
  displayName: "Vault keys",
  description: "Vim keys and a zen (no sidebars) toggle",
  version: "1.0.0",
  category: "transformer",
}

export default function VaultKeys() {
  return {
    name: "VaultKeys",
    // The loader skips a transformer with no transform hook.
    htmlPlugins: () => [],
    externalResources() {
      return {
        css: [{ content: read("client.css"), inline: true }],
        // Before DOM ready, so a page in zen mode never draws its sidebars.
        js: [{ script: read("client.js"), loadTime: "beforeDOMReady", contentType: "inline", spaPreserve: true }],
      }
    },
  }
}
