// The diff of an MR under its working doc. mr-diff (~/.local/bin) saves
// GitLab's merge-base diff of each MR as mr-diff.json beside working.md, and
// this script draws it at the end of the page in a fold, with diff2html.
;(() => {
  if (window.__mrDiff) return
  window.__mrDiff = true

  const PAGE = /\/mr\/[^/]+\/working$/
  const VENDOR = "/static/mr-diff/"
  const FORMAT_KEY = "mr-diff-format"
  const OPEN_KEY = "mr-diff-open:"
  // Meeting and planner times are Pacific everywhere in the vault.
  const ZONE = "America/Los_Angeles"

  const load = (key, storage = localStorage) => {
    try {
      return storage.getItem(key)
    } catch {
      return null
    }
  }
  const save = (key, value, storage = localStorage) => {
    try {
      if (value === null) storage.removeItem(key)
      else storage.setItem(key, value)
    } catch {}
  }

  // diff2html loads once, on the first MR page. An SPA navigation drops the
  // head elements that have no data-persist attribute (spa.inline.ts).
  let lib
  const loadLib = () =>
    (lib ??= new Promise((resolve, reject) => {
      const css = document.createElement("link")
      css.rel = "stylesheet"
      css.href = VENDOR + "diff2html.min.css"
      const js = document.createElement("script")
      js.src = VENDOR + "diff2html-ui-slim.min.js"
      js.onload = () => resolve(window.Diff2HtmlUI)
      js.onerror = () => {
        lib = undefined
        css.remove()
        js.remove()
        reject(new Error("cannot load diff2html"))
      }
      for (const node of [css, js]) node.dataset.persist = ""
      document.head.append(css, js)
    }))

  const el = (tag, props = {}, ...children) => {
    const node = Object.assign(document.createElement(tag), props)
    node.append(...children)
    return node
  }

  const stats = (diff) => {
    let files = 0
    let added = 0
    let removed = 0
    let inHunk = false
    for (const line of diff.split("\n")) {
      if (line.startsWith("diff --git ")) {
        files++
        inHunk = false
      } else if (line.startsWith("@@")) inHunk = true
      else if (inHunk && line[0] === "+") added++
      else if (inHunk && line[0] === "-") removed++
    }
    return { files, added, removed }
  }

  const when = (iso) => {
    const date = new Date(iso)
    if (Number.isNaN(date.getTime())) return ""
    const fmt = new Intl.DateTimeFormat("en-US", {
      timeZone: ZONE,
      month: "short",
      day: "numeric",
      hour: "numeric",
      minute: "2-digit",
    })
    return `${fmt.format(date)} PT`
  }

  const format = () => (load(FORMAT_KEY) === "side-by-side" ? "side-by-side" : "line-by-line")

  // Whether the diff drew. On false, the fold shows why, and the next open
  // tries again.
  const draw = async (body, data) => {
    const fail = (err) => {
      body.replaceChildren(el("p", { className: "mr-diff-note", textContent: `Cannot draw the diff: ${err.message}` }))
      return false
    }
    let Diff2HtmlUI
    try {
      Diff2HtmlUI = await loadLib()
    } catch (err) {
      return fail(err)
    }
    try {
      // diff2html escapes the diff text when it builds the HTML.
      new Diff2HtmlUI(body, data.diff, {
        outputFormat: format(),
        drawFileList: true,
        fileListToggle: true,
        fileListStartVisible: true,
        fileContentToggle: true,
        matching: "lines",
        diffStyle: "word",
        highlight: true,
        synchronisedScroll: true,
        stickyFileHeaders: true,
        colorScheme: "dark",
        diffMaxChanges: 2000,
        diffMaxLineLength: 4000,
      }).draw()
    } catch (err) {
      return fail(err)
    }
    return true
  }

  const build = (data, path) => {
    const { files, added, removed } = stats(data.diff)
    const gitlab = /^https:\/\/gitlab\.com\//.test(data.url) ? `${data.url}/diffs` : null
    const summary = el(
      "summary",
      {},
      el("span", { className: "mr-diff-title", textContent: "🔀 Changes" }),
      el(
        "span",
        { className: "mr-diff-stats" },
        `${files} ${files === 1 ? "file" : "files"} `,
        el("span", { className: "mr-diff-ins", textContent: `+${added}` }),
        " ",
        el("span", { className: "mr-diff-del", textContent: `−${removed}` }),
      ),
      el(
        "span",
        { className: "mr-diff-meta" },
        "head ",
        el("code", { textContent: (data.head_sha || "").slice(0, 8) }),
        ` · fetched ${when(data.fetched_at)}`,
      ),
    )
    if (data.state && data.state !== "opened") {
      summary.append(el("span", { className: `mr-diff-state mr-diff-${data.state}`, textContent: data.state }))
    }

    const body = el("div", { className: "mr-diff-body" })
    const buttons = [
      ["line-by-line", "Inline"],
      ["side-by-side", "Side by side"],
    ].map(([value, label]) => {
      const button = el("button", { type: "button", textContent: label })
      button.dataset.format = value
      button.addEventListener("click", () => {
        save(FORMAT_KEY, value)
        for (const b of buttons) b.classList.toggle("is-active", b.dataset.format === value)
        draw(body, data)
      })
      button.classList.toggle("is-active", value === format())
      return button
    })
    const bar = el("div", { className: "mr-diff-bar" }, el("span", { className: "mr-diff-formats" }, ...buttons))
    if (gitlab) bar.append(el("a", { className: "external", href: gitlab, textContent: "Open in GitLab" }))

    const details = el("details", { className: "mr-diff", id: "mr-diff" }, summary)
    if (!data.diff.trim()) {
      details.append(el("p", { className: "mr-diff-note", textContent: "This MR has no changes." }))
      return { details, show: async () => {} }
    }
    details.append(bar, body)
    details.open = load(OPEN_KEY + path) === "1"
    let drawn = false
    const show = async () => {
      if (!details.open || drawn) return
      // Set before the await, so a second toggle does not draw twice. A failed
      // draw clears it, so the next open tries again.
      drawn = true
      drawn = await draw(body, data)
    }
    details.addEventListener("toggle", () => {
      save(OPEN_KEY + path, details.open ? "1" : null)
      show()
    })
    return { details, show }
  }

  // The diff draws after the page loads, so the browser cannot restore a
  // scroll position inside it: it restores before the diff exists. An MR page
  // keeps the reader's place in its history entry instead (Quartz never reads
  // history.state): the offset into the fold when the reader is in it, else
  // the page offset. A reload (the Quartz watcher reloads on every vault
  // write), Back, or Forward to the entry scrolls there once the fold draws,
  // and the fold offset still holds after an edit above the fold.
  const SPOT = "mrDiffSpot"
  // The MR page whose scroll is kept, once its fold is in place.
  let tracked = null
  let timer
  const foldTop = () => {
    const fold = document.getElementById("mr-diff")
    return fold ? fold.getBoundingClientRect().top + window.scrollY : null
  }
  const keepSpot = () => {
    // After Back or Forward, the current entry already belongs to the next page.
    if (tracked === null || location.pathname !== tracked) return
    const top = foldTop()
    const spot = top !== null && window.scrollY >= top ? { fold: window.scrollY - top } : { page: window.scrollY }
    try {
      history.replaceState({ ...history.state, [SPOT]: spot }, "")
    } catch {}
  }
  // Debounced: Chrome throttles a page that calls replaceState too often.
  window.addEventListener(
    "scroll",
    () => {
      clearTimeout(timer)
      timer = setTimeout(keepSpot, 250)
    },
    { passive: true },
  )
  window.addEventListener("pagehide", () => {
    clearTimeout(timer)
    keepSpot()
  })
  const restoreScroll = (spot) => {
    const top = foldTop()
    const y = spot.fold !== undefined && top !== null ? top + spot.fold : spot.page
    if (y > 0) window.scrollTo({ top: y, behavior: "instant" })
  }
  // Quartz's Explorer saves its own scroll only before an SPA navigation.
  // Without a saved value, a full load calls scrollIntoView on the active
  // entry, which scrolls the window too, so each watcher reload moved the page.
  // This fixes every page, not only MR pages; it can move to vault-keys.
  window.addEventListener("pagehide", () => {
    const list = document.querySelector(".explorer-ul")
    if (list) save("explorerScrollTop", String(list.scrollTop), sessionStorage)
  })
  let navId = 0
  document.addEventListener("nav", async () => {
    const id = ++navId
    tracked = null
    clearTimeout(timer)
    document.getElementById("mr-diff")?.remove()
    const path = location.pathname
    const mrPage = PAGE.test(path)
    // The setting belongs to the current history entry. Quartz's router
    // leaves the scroll of a Back or Forward to the browser.
    history.scrollRestoration = mrPage ? "manual" : "auto"
    if (!mrPage) return
    const spot = history.state?.[SPOT]
    let data = null
    try {
      const res = await fetch(path.replace(/\/working$/, "/mr-diff.json"), { cache: "no-store" })
      if (res.ok) data = await res.json()
    } catch {}
    if (id !== navId) return
    const article = document.querySelector(".center > article")
    if (article && typeof data?.diff === "string") {
      const { details, show } = build(data, path)
      article.after(details)
      await show()
      if (id !== navId) return
    }
    if (spot) restoreScroll(spot)
    tracked = path
  })
})()
