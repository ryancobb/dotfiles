const { Plugin } = require("obsidian");

// A two-finger swipe on the trackpad goes back or forward in the pane under the pointer, as in Safari. The trackpad
// sends a stream of wheel events for each swipe, and the momentum continues the stream after the fingers lift. A
// pause in the stream ends a swipe, and each swipe navigates at most once. With natural scrolling, fingers that move
// right scroll to the left (deltaX < 0), which goes back.
const DISTANCE = 120; // px of horizontal scroll before a swipe navigates
const DOMINANCE = 2; // the horizontal scroll must be this many times the vertical scroll
const MIN_EVENTS = 5; // a trackpad sends many small events; one or two notches of a sideways mouse wheel do not count
const SLACK = 8; // px of sideways overflow that do not count as a scroll, such as a callout a bit too wide
// A pause is GAP_MS with no wheel event, and at least QUIET_FRAMES animation frames. Frames, because event timestamps
// show a pause while a new note renders: no frame runs then, and Chromium holds the wheel events and sends them merged.
const GAP_MS = 150;
const QUIET_FRAMES = 3;
// In these views a sideways swipe pans, so it never navigates.
const PANNING_VIEWS = new Set(["canvas", "graph", "localgraph"]);

module.exports = class SwipeNav extends Plugin {
  onload() {
    this.swipe = null;
    // bubble phase, so a view or plugin that takes the wheel itself calls preventDefault before this runs
    this.registerDomEvent(window, "wheel", (evt) => this.onWheel(evt), { passive: true });
    this.register(() => cancelAnimationFrame(this.frame));
  }

  onWheel(evt) {
    const swipe = this.swipe ?? this.startSwipe();
    swipe.wheel = true;
    if (swipe.done) return;
    // a pinch zoom sends ctrl, and a mouse wheel scrolls sideways with shift
    if (evt.defaultPrevented || evt.ctrlKey || evt.metaKey || evt.altKey || evt.shiftKey) {
      swipe.done = true;
      return;
    }
    swipe.events++;
    swipe.x += evt.deltaX;
    swipe.y += Math.abs(evt.deltaY);
    const x = Math.abs(swipe.x);
    if (swipe.events < MIN_EVENTS || x < DISTANCE || x < DOMINANCE * swipe.y) return;
    const leaf = this.leafAt(evt.target);
    // the pane still opens the note from the last swipe, and history.go() would only say "tab busy": try again on the
    // next event of this swipe
    if (leaf?.working) return;
    swipe.done = true;
    if (leaf) (swipe.x < 0 ? leaf.history.back() : leaf.history.forward()).catch(console.error);
  }

  // A swipe that ends after a pause, measured in animation frames.
  startSwipe() {
    const swipe = (this.swipe = { x: 0, y: 0, events: 0, done: false, wheel: false });
    let quiet = 0;
    let since = 0;
    const frame = (t) => {
      if (swipe.wheel) {
        swipe.wheel = false;
        quiet = 0;
        since = t;
      } else if (++quiet >= QUIET_FRAMES && t - since >= GAP_MS) {
        this.swipe = null;
        return;
      }
      this.frame = requestAnimationFrame(frame);
    };
    this.frame = requestAnimationFrame(frame);
    return swipe;
  }

  // The main-area pane under `el` that goes back and forward (app:go-back checks the same), or null. Null also when
  // `el` is in something that scrolls sideways, such as a wide table or a row of stacked tabs, because the swipe
  // scrolls it.
  leafAt(el) {
    let leaf = null;
    this.app.workspace.iterateRootLeaves((l) => {
      if (!l.containerEl.contains(el)) return false;
      leaf = l;
      return true; // stops the walk
    });
    if (!leaf?.view?.navigation || PANNING_VIEWS.has(leaf.view.getViewType())) return null;
    for (let node = el; node; node = node.parentElement) {
      if (node.scrollWidth - node.clientWidth > SLACK && /auto|scroll/.test(getComputedStyle(node).overflowX)) {
        return null;
      }
    }
    return leaf;
  }
};
