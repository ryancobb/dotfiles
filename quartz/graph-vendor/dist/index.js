// A Quartz plugin with no build step: it serves pinned copies of the two
// libraries that the graph draws with, d3 7.9.0 (ISC) and pixi.js 8.22.0 (MIT),
// from dist/vendor (taken from their npm tarballs). Upstream, the graph loads
// d3@7 and pixi.js@8 from jsdelivr at floating versions, into the same origin
// as the vault; setup.sh points the graph at static/graph-vendor/ instead.
// quartz.config.yaml loads the plugin as a local source (./graph-vendor), and
// setup.sh links that path into the Quartz clone.
import fs from "node:fs"
import path from "node:path"

const VENDOR = ["d3.min.js", "pixi.min.js"]

export const manifest = {
  name: "graph-vendor",
  displayName: "Graph vendor",
  description: "Serves pinned d3 and pixi.js for the graph",
  version: "1.0.0",
  category: "emitter",
}

export default function GraphVendor() {
  return {
    name: "GraphVendor",
    async *emit(ctx) {
      const dir = path.join(ctx.argv.output, "static", "graph-vendor")
      await fs.promises.mkdir(dir, { recursive: true })
      for (const name of VENDOR) {
        const dest = path.join(dir, name)
        await fs.promises.copyFile(new URL(`vendor/${name}`, import.meta.url), dest)
        yield dest
      }
    },
    // The vendored files do not change while the server runs.
    async *partialEmit() {},
  }
}
