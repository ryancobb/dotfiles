# drawer.py — per-tab toggleable "drawers" for kitty.
#
# A drawer is a shell window pinned to an edge of the current tab that a
# keybinding toggles open and closed. Hiding does NOT kill the drawer: the
# window is parked in a hidden OS window so its process and scrollback survive,
# then pulled back to the same edge (and size) when toggled on again. Each tab
# gets its own independent drawer per edge.
#
# This file is wired up two ways in kitty.conf:
#   map cmd+r   kitten drawer.py right     # toggle the right drawer
#   map ctrl+`  kitten drawer.py bottom    # toggle the bottom drawer
#   watcher     drawer.py                  # on_close reaps a tab's stashed
#                                          # drawers the moment the tab closes
import json

from kittens.tui.handler import result_handler

VAR = "KITTY_DRAWER"  # tags a drawer window; value = "<home_tab_id>-<edge>"
SIZE_VAR = "KITTY_DRAWER_SIZE"  # remembers the drawer's last size (% of parent split)

# edge -> (launch split location, screen edge to pin to, default size % of parent)
EDGES = {
    "right": ("vsplit", "right", 35),
    "bottom": ("hsplit", "bottom", 30),
}


def main(args):
    pass


def _rc(boss, win, *cmd):
    """Run a remote-control command in-process; returns data for query commands."""
    return boss.call_remote_control(win, tuple(cmd))


def _ls(boss, win):
    data = _rc(boss, win, "ls")
    if isinstance(data, (bytes, bytearray)):
        data = data.decode("utf-8")
    if isinstance(data, str):
        data = json.loads(data)
    return data


def _windows(ls):
    for osw in ls:
        for tab in osw.get("tabs", []):
            for w in tab.get("windows", []):
                yield tab, w


def _home_tab(value):
    try:
        return int(value.split("-", 1)[0])
    except (ValueError, AttributeError):
        return None


def _as_bias(value, default):
    try:
        return min(90, max(10, int(value)))
    except (TypeError, ValueError):
        return default


def _drawer_fraction(layout_state, drawer_win_id):
    """The drawer's current size as a percent of its immediate parent split.

    splits layouts expose a binary tree in `pairs`, where `bias` is the
    fraction allotted to the `one` (first) child. We locate the drawer's window
    group in that tree and return its share, or None if it can't be determined.
    """
    if not isinstance(layout_state, dict):
        return None
    group_id = None
    for g in layout_state.get("all_windows", {}).get("window_groups", []):
        if drawer_win_id in g.get("window_ids", []):
            group_id = g["id"]
            break
    if group_id is None:
        return None

    found = []

    def walk(node):
        if found or not isinstance(node, dict):
            return
        bias, one, two = node.get("bias"), node.get("one"), node.get("two")
        if bias is not None and one == group_id:
            found.append(round(bias * 100))
        elif bias is not None and two == group_id:
            found.append(round((1 - bias) * 100))
        walk(one)
        walk(two)

    walk(layout_state.get("pairs"))
    return found[0] if found else None


def _ensure_splits(boss, win, layout):
    """Switch the active tab to splits if needed.

    _pin's move_to_screen_edge/bias are no-ops in the stack (zoom) layout, so a
    drawer summoned while a tab is zoomed would otherwise land unpinned and
    full-size. Only switch when necessary — calling goto-layout on a tab that is
    already splits resets its existing biases.
    """
    if layout != "splits":
        _rc(boss, win, "action", "goto_layout", "splits")


def _pin(boss, win, match, screen_edge, bias):
    """Focus the drawer, pin it to its screen edge, and size it (splits layout)."""
    _rc(boss, win, "focus-window", match)
    _rc(boss, win, "action", "layout_action", f"move_to_screen_edge {screen_edge}")
    _rc(boss, win, "action", "layout_action", f"bias {bias}")


def _reap_orphans(boss, win, ls):
    """Close drawer windows whose home tab no longer exists.

    A stashed drawer lives in a hidden OS window, so it outlives its home tab.
    The kitten calls this on each toggle; the on_close watcher calls it shortly
    after any tab closes.
    """
    existing = {t["id"] for osw in ls for t in osw.get("tabs", [])}
    for _tab, w in _windows(ls):
        value = (w.get("user_vars") or {}).get(VAR)
        home = _home_tab(value) if value else None
        if home is None:
            continue
        if home not in existing:
            _rc(boss, win, "close-window", f"--match=id:{w['id']}")


@result_handler(no_ui=True)
def handle_result(args, result, target_window_id, boss):
    edge = args[1] if len(args) > 1 else "right"
    if edge not in EDGES:
        return
    location, screen_edge, default_bias = EDGES[edge]

    tab = boss.active_tab
    if tab is None:
        return
    cur_tab_id = tab.id
    key = f"{cur_tab_id}-{edge}"
    match = f"--match=var:{VAR}=^{key}$"

    win = boss.window_id_map.get(target_window_id)
    ls = _ls(boss, win)
    _reap_orphans(boss, win, ls)

    # Find this tab's drawer (orphans, if any, were just closed above).
    drawer = None  # (containing_tab, window) for this tab+edge
    cur_layout = None
    for containing_tab, w in _windows(ls):
        if containing_tab.get("id") == cur_tab_id:
            cur_layout = containing_tab.get("layout")
        if (w.get("user_vars") or {}).get(VAR) == key:
            drawer = (containing_tab, w)

    if drawer is None:
        # No drawer for this tab+edge yet -> create one at the default size.
        _ensure_splits(boss, win, cur_layout)
        _rc(boss, win, "launch", f"--location={location}", "--cwd=current", f"--var={VAR}={key}")
        _pin(boss, win, match, screen_edge, default_bias)
        return

    containing_tab, w = drawer
    if containing_tab["id"] == cur_tab_id:
        # Visible here -> remember its current size, then stash it (keeps it running).
        pct = _drawer_fraction(containing_tab.get("layout_state"), w["id"])
        if pct is not None:
            _rc(boss, win, "set-user-vars", f"--match=id:{w['id']}", f"{SIZE_VAR}={pct}")
        _rc(boss, win, "detach-window", match, "--stay-in-tab")
        _rc(boss, win, "resize-os-window", match, "--action=hide")
    else:
        # Stashed elsewhere -> bring it back and restore its last size (or default).
        bias = _as_bias((w.get("user_vars") or {}).get(SIZE_VAR), default_bias)
        _ensure_splits(boss, win, cur_layout)
        _rc(boss, win, "detach-window", match, f"--target-tab=id:{cur_tab_id}")
        _pin(boss, win, match, screen_edge, bias)


def on_close(boss, window, data):
    """Global watcher: reap a tab's stashed drawers once that tab closes.

    Fires for every window close. The reap is deferred to the next event-loop
    tick: issuing remote-control commands while a window is mid-teardown raises
    (the closing window is briefly half-removed from kitty's state). By the next
    tick the closed tab is fully gone, so _reap_orphans closes any drawer still
    homed to it. Without this, a stashed drawer whose tab is closed would linger
    invisibly until the next drawer keypress.
    """
    from kitty.fast_data_types import add_timer

    def reap(_timer_id):
        try:
            _reap_orphans(boss, None, _ls(boss, None))
        except Exception:
            pass

    add_timer(reap, 0.1, False)
