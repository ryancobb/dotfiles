// Vim keys and a zen toggle for the vault site. Press ? on a page for the list.
;(() => {
  if (window.__vaultKeys) return
  window.__vaultKeys = true

  const root = document.documentElement
  const ZEN_KEY = "vault-zen"
  const HINT_CHARS = "asdfjklghweio"
  const LINE = 80

  // Zen hides both sidebars. localStorage keeps it across reloads; the Quartz
  // watcher reloads the page on every vault write.
  let zen = false
  try {
    zen = localStorage.getItem(ZEN_KEY) === "on"
  } catch {}
  const applyZen = () => root.toggleAttribute("data-zen", zen)
  const toggleZen = () => {
    zen = !zen
    applyZen()
    try {
      localStorage.setItem(ZEN_KEY, zen ? "on" : "off")
    } catch {}
  }
  applyZen()
  window.addEventListener("storage", (e) => {
    if (e.key !== ZEN_KEY) return
    zen = e.newValue === "on"
    applyZen()
  })

  // The SPA router replaces the body on each navigation, so the button goes
  // back in on every "nav" event.
  const ensureButton = () => {
    if (document.getElementById("zen-toggle")) return
    const button = document.createElement("button")
    button.id = "zen-toggle"
    button.type = "button"
    button.title = "Toggle sidebars (z)"
    button.setAttribute("aria-label", "Toggle sidebars")
    button.innerHTML =
      '<svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="16" rx="2"/><line x1="9" y1="4" x2="9" y2="20"/><line x1="15" y1="4" x2="15" y2="20"/></svg>'
    button.addEventListener("click", () => {
      toggleZen()
      button.blur()
    })
    document.body.appendChild(button)
  }

  // Link hints, as in Vimium: f labels every visible link, typing a label
  // clicks it. Labels all have the same length, so none is a prefix of another.
  let hints = null
  const MODIFIER_KEYS = new Set(["Shift", "Control", "Alt", "Meta", "CapsLock"])
  // A link counts when a click in the middle of one of its visible lines lands
  // on the link itself. That skips links in folded callouts and in the zen
  // sidebars, which keep a size but are clipped or hidden. Returns the index of
  // that line in getClientRects(), or -1.
  const hintLine = (el) => {
    if (el.id === "zen-toggle" || el.closest(".search-container")) return -1
    if (getComputedStyle(el).opacity === "0") return -1
    const rects = el.getClientRects()
    for (let i = 0; i < rects.length; i++) {
      const r = rects[i]
      if (r.width === 0 || r.height === 0) continue
      if (r.bottom < 0 || r.top > innerHeight || r.right < 0 || r.left > innerWidth) continue
      const x = Math.min(Math.max(r.left + r.width / 2, 0), innerWidth - 1)
      const y = Math.min(Math.max(r.top + r.height / 2, 0), innerHeight - 1)
      const hit = document.elementFromPoint(x, y)
      if (hit && el.contains(hit)) return i
    }
    return -1
  }
  const hintTargets = () =>
    [
      ...document.querySelectorAll(
        "a[href], button, summary, [role=button], .callout.is-collapsible > .callout-title",
      ),
    ]
      .map((el) => ({ el, line: hintLine(el) }))
      .filter((target) => target.line >= 0)
  const makeLabels = (n) => {
    const base = HINT_CHARS.length
    let len = 1
    while (base ** len < n) len++
    return Array.from({ length: n }, (_, i) => {
      let label = ""
      for (let j = 0, x = i; j < len; j++, x = Math.floor(x / base)) label = HINT_CHARS[x % base] + label
      return label
    })
  }
  const closeHints = () => {
    hints?.layer.remove()
    hints = null
  }
  // Labels follow their links when the page scrolls, because a smooth scroll
  // from j or d can still run when f is pressed.
  const placeHints = () => {
    for (const { el, line, tag } of hints?.items ?? []) {
      const r = el.getClientRects()[line]
      if (!r) continue
      tag.style.left = `${Math.max(0, r.left)}px`
      tag.style.top = `${Math.max(0, r.top)}px`
    }
  }
  const showHints = () => {
    const targets = hintTargets()
    if (!targets.length) return
    const layer = document.createElement("div")
    layer.id = "vault-hints"
    const labels = makeLabels(targets.length)
    const items = targets.map(({ el, line }, i) => {
      const tag = document.createElement("span")
      tag.className = "vault-hint"
      tag.textContent = labels[i]
      layer.appendChild(tag)
      return { el, line, label: labels[i], tag }
    })
    document.body.appendChild(layer)
    hints = { layer, items, typed: "" }
    placeHints()
  }
  const hintKey = (e) => {
    // Shift alone must not close the hints: the labels show in uppercase.
    if (MODIFIER_KEYS.has(e.key)) return
    // A shortcut such as Cmd+R closes the hints and still runs.
    if (e.ctrlKey || e.metaKey || e.altKey) return closeHints()
    e.preventDefault()
    e.stopPropagation()
    if (e.key === "Escape") return closeHints()
    if (e.key === "Backspace") hints.typed = hints.typed.slice(0, -1)
    else if (e.key.length === 1 && HINT_CHARS.includes(e.key.toLowerCase())) hints.typed += e.key.toLowerCase()
    else return closeHints()
    const left = hints.items.filter((item) => item.label.startsWith(hints.typed))
    if (!left.length) return closeHints()
    if (left.length === 1 && left[0].label === hints.typed) {
      const { el } = left[0]
      closeHints()
      el.focus({ preventScroll: true })
      return el.click()
    }
    for (const item of hints.items) {
      const match = item.label.startsWith(hints.typed)
      item.tag.hidden = !match
      if (match) item.tag.innerHTML = `<b>${hints.typed}</b>${item.label.slice(hints.typed.length)}`
    }
  }

  const HELP = [
    ["j / k", "scroll down / up"],
    ["d / u", "half page down / up"],
    ["gg / G", "top / bottom"],
    ["H / L", "back / forward"],
    ["f", "link hints"],
    ["/", "search"],
    ["z", "toggle sidebars (zen)"],
    ["?", "this help"],
    ["Esc", "close"],
  ]
  const toggleHelp = () => {
    const open = document.getElementById("vault-keys-help")
    if (open) return open.remove()
    const panel = document.createElement("div")
    panel.id = "vault-keys-help"
    panel.innerHTML =
      "<table>" + HELP.map(([key, what]) => `<tr><td><kbd>${key}</kbd></td><td>${what}</td></tr>`).join("") + "</table>"
    panel.addEventListener("click", () => panel.remove())
    document.body.appendChild(panel)
  }

  const scroll = (top, e) => window.scrollBy({ top, behavior: e.repeat ? "instant" : "smooth" })
  const typing = (el) =>
    el instanceof HTMLElement && (el.isContentEditable || /^(INPUT|TEXTAREA|SELECT)$/.test(el.tagName))
  let pendingG = 0

  document.addEventListener(
    "keydown",
    (e) => {
      if (hints) return hintKey(e)
      if (e.ctrlKey || e.metaKey || e.altKey || e.isComposing) return
      if (typing(e.target) || document.querySelector(".search-container.active")) return

      if (e.key === "Escape") {
        document.getElementById("vault-keys-help")?.remove()
        return
      }
      const g = pendingG && Date.now() - pendingG < 800
      pendingG = 0
      const actions = {
        j: () => scroll(LINE, e),
        k: () => scroll(-LINE, e),
        d: () => scroll(innerHeight / 2, e),
        u: () => scroll(-innerHeight / 2, e),
        G: () => window.scrollTo({ top: document.documentElement.scrollHeight, behavior: "smooth" }),
        g: () => (g ? window.scrollTo({ top: 0, behavior: "smooth" }) : (pendingG = Date.now())),
        H: () => history.back(),
        L: () => history.forward(),
        f: showHints,
        "/": () => document.querySelector(".search-button")?.click(),
        z: toggleZen,
        "?": toggleHelp,
      }
      const action = actions[e.key]
      if (!action) return
      e.preventDefault()
      action()
    },
    true,
  )

  document.addEventListener("nav", () => {
    closeHints()
    document.getElementById("vault-keys-help")?.remove()
    applyZen()
    ensureButton()
  })
  window.addEventListener("scroll", placeHints, { passive: true })
  window.addEventListener("resize", closeHints)
})()
