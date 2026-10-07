const { Plugin } = require("obsidian");

// Ctrl+h/j/k/l moves to the pane in that direction, sidebars included. With no pane there, the key goes on to the
// view, as `performable:` does in Ghostty. In a note, the nmaps in vimrc run the same commands, so insert
// mode keeps these keys.
const DIRECTIONS = { KeyH: "left", KeyJ: "bottom", KeyK: "top", KeyL: "right" };
const NAMES = { left: "on the left", bottom: "below", top: "above", right: "on the right" };

module.exports = class PaneNav extends Plugin {
  onload() {
    for (const dir of Object.values(DIRECTIONS)) {
      this.addCommand({
        id: `focus-${dir}`,
        name: `Focus the pane ${NAMES[dir]}`,
        checkCallback: (checking) => {
          const go = this.way(dir);
          if (go && !checking) go();
          return !!go;
        },
      });
    }

    // capture on window runs before the terminal's own key handlers
    this.registerDomEvent(
      window,
      "keydown",
      (evt) => {
        if (!evt.ctrlKey || evt.metaKey || evt.altKey || evt.shiftKey) return;
        const dir = DIRECTIONS[evt.code];
        if (!dir || evt.target?.closest?.(".cm-editor")) return;
        const go = this.way(dir);
        if (!go) return;
        evt.preventDefault();
        evt.stopPropagation();
        go();
      },
      { capture: true },
    );

    // the Ghostty view ignores the focus Obsidian gives a pane it moves to, so the keys stayed with the note
    this.registerEvent(
      this.app.workspace.on("active-leaf-change", (leaf) => {
        if (leaf?.view?.getViewType() === "ghostty-terminal") leaf.view.terminal?.focus?.();
      }),
    );
  }

  // How to reach the pane in `dir`, or null when there is none: Obsidian's focus command, else from the main area
  // the open sidebar on that side, which that command never picks.
  way(dir) {
    const id = `editor:focus-${dir}`;
    if (this.app.commands.findCommand(id)?.checkCallback?.(true)) {
      return () => this.app.commands.executeCommandById(id);
    }
    const leaf = this.sidebarLeaf(dir);
    return leaf ? () => this.app.workspace.setActiveLeaf(leaf, { focus: true }) : null;
  }

  // The shown tab of the open sidebar on `dir`'s side that was active last, when the active pane is in the main area.
  sidebarLeaf(dir) {
    const ws = this.app.workspace;
    const side = { left: ws.leftSplit, right: ws.rightSplit }[dir];
    if (!side || side.collapsed || ws.activeLeaf?.getRoot() !== ws.rootSplit) return null;
    let best = null;
    ws.iterateAllLeaves((leaf) => {
      if (leaf.getRoot() !== side || !leaf.view?.containerEl?.isShown()) return;
      if (!best || (leaf.activeTime ?? 0) > (best.activeTime ?? 0)) best = leaf;
    });
    return best;
  }
};
