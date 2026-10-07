// A Quartz plugin with no build step: it draws each MR's diff under the MR's
// working doc. mr-diff (~/.local/bin) saves GitLab's merge-base diff as
// mr-diff.json in the MR folder, and Quartz copies that file like any other
// asset. client.js fetches it on each page load, so a new diff needs no page
// rebuild. diff2html (MIT, dist/vendor) draws it: this emitter copies it to
// static/mr-diff/, and client.js loads it only on an MR working doc.
// quartz.config.yaml loads the plugin as a local source (./mr-diff), and
// setup.sh links that path into the Quartz clone.
import fs from "node:fs"
import path from "node:path"

const read = (name) => fs.readFileSync(new URL(name, import.meta.url), "utf-8")
const VENDOR = ["diff2html-ui-slim.min.js", "diff2html.min.css"]

export const manifest = {
  name: "mr-diff",
  displayName: "MR diff",
  description: "Draws each MR's merge-base diff under its working doc",
  version: "1.0.0",
  category: "emitter",
}

export default function MrDiff() {
  return {
    name: "MrDiff",
    async *emit(ctx) {
      const dir = path.join(ctx.argv.output, "static", "mr-diff")
      await fs.promises.mkdir(dir, { recursive: true })
      for (const name of VENDOR) {
        const dest = path.join(dir, name)
        await fs.promises.copyFile(new URL(`vendor/${name}`, import.meta.url), dest)
        yield dest
      }
    },
    // The vendored files do not change while the server runs.
    async *partialEmit() {},
    externalResources() {
      return {
        css: [{ content: read("client.css"), inline: true }],
        // Before DOM ready, so the listener is there for the first nav event.
        js: [{ script: read("client.js"), loadTime: "beforeDOMReady", contentType: "inline", spaPreserve: true }],
      }
    },
  }
}
