// A Quartz plugin with no build step: it ships client.js and client.css to
// every page, the serif fonts of the Claude themes (custom.scss), and a rehype
// step that marks each block with the depth of its section. quartz.config.yaml
// loads it as a local source (./vault-keys), and setup.sh links that path into
// the Quartz clone. The files sit in dist/ because `plugin install` runs npm
// install and a build for a plugin without one.
import fs from "node:fs"

const read = (name) => fs.readFileSync(new URL(name, import.meta.url), "utf-8")

export const manifest = {
  name: "vault-keys",
  displayName: "Vault keys",
  description:
    "Vim keys, zen (no sidebars) and wide toggles, a theme switch, section indents, and a jump to today's plan",
  version: "1.0.0",
  category: "transformer",
  // After the other transformers (80 to 92 in quartz.config.yaml), so the
  // section depths go on the blocks as they end up, wrappers included.
  defaultOrder: 100,
}

// Quartz renders a page's blocks as siblings, with no element per section, so
// each top-level block gets its depth as data-vault-depth; client.css indents
// by it. A heading of the page's top section level (its shallowest heading
// after the h1 title) is depth 0, each level below it one more, and a
// heading's own blocks sit one step in from it. The h1 title and the blocks
// under it stay flush. Depth 0 gets no attribute.
const HEADING = /^h([1-6])$/
const sectionDepths = () => (tree) => {
  const blocks = tree.children.filter((node) => node.type === "element")
  const levels = blocks.map((node) => Number(HEADING.exec(node.tagName)?.[1] ?? 0))
  const top = Math.min(7, ...levels.filter((level) => level > 1))
  let depth = 0
  blocks.forEach((node, i) => {
    const level = levels[i]
    if (level) {
      const own = Math.max(0, level - top)
      if (own) node.properties.dataVaultDepth = own
      depth = level >= top ? own + 1 : 0
    } else if (depth) {
      node.properties.dataVaultDepth = depth
    }
  })
}

export default function VaultKeys() {
  return {
    name: "VaultKeys",
    htmlPlugins: () => [sectionDepths],
    externalResources() {
      return {
        css: [
          { content: read("client.css"), inline: true },
          // The browser fetches the font files only when a rule uses the font.
          // Fraunces comes with its SOFT axis at 100, the rounded cuts.
          {
            content:
              "https://fonts.googleapis.com/css2?family=Source+Serif+4:wght@400;600;700&family=Fraunces:opsz,wght,SOFT@9..144,400..700,100&display=swap",
          },
        ],
        // Before DOM ready, so a page in zen mode never draws its sidebars.
        js: [{ script: read("client.js"), loadTime: "beforeDOMReady", contentType: "inline", spaPreserve: true }],
      }
    },
  }
}
