# Shows kitty's per-pane title bar only on panes that run a Claude Code session.
#
# kitty decides title bars per tab: Layout.__call__ sets show_title_bar on
# every visible pane once a tab has window_title_bar_min_windows of them. This
# watcher turns Window.show_title_bar into a property that keeps that value
# only for a pane whose group (the pane and its overlays, such as the
# scrollback pager) runs a Claude session, or while its tab forces bars on.
# Claude Code titles its pane with the session title, so the bar shows that.
#
# A pane runs a session when its foreground job holds a `claude` process and
# the terminal is out of line mode (ICANON off), as Claude's interactive view
# keeps it. `claude -p` and commands such as `claude mcp list` stay in line
# mode, so they get no bar, and no list of subcommands needs upkeep.
#
# kitty forces bars only in tabs below the minimum (a window drag, the
# toggle_window_title_bars action). In a split tab a pane without Claude has
# no bar, so title-bar drag and drop works only on Claude panes there.
#
# The bar is decided each time kitty lays out a tab. Between layouts, the
# title and command start/stop events, and a check every few seconds, look at
# the pane again and lay the tab out when the answer changed. The property
# patches a kitty internal, checked on kitty 0.49.2. If deciding fails, the
# pane keeps kitty's own value; if the internal changed, the watcher logs that
# and stays off.
#
# Load it with `watcher claude_title_bars.py` in kitty.conf. kitty runs the
# file once per process, so an edit to it needs a kitty restart.

import os
import termios
import traceback
from contextlib import contextmanager
from time import monotonic

from kitty.child import abspath_of_exe, process_data_cache, processes_in_group
from kitty.fast_data_types import add_timer, get_boss
from kitty.utils import log_error
from kitty.window import Window

# An npm install runs as `node .../claude` (or under bun).
INTERPRETERS = frozenset({'node', 'bun'})
# How long a scan of the same foreground job is reused, in seconds.
SCAN_TTL = 2.0
# The shell reports a command before its job holds the terminal (`fg` too),
# so a started command is checked again after these delays, in seconds.
RECHECKS = (0.5, 2.0)
# Catches what no event reports, such as Claude ending inside a longer job
# or starting late, in seconds.
POLL_INTERVAL = 5.0

reported = False


def report() -> None:
    # One traceback per kitty process: a Claude pane changes its title often.
    global reported
    if not reported:
        reported = True
        log_error('claude_title_bars: a check failed; panes keep kitty\'s own title bars\n' + traceback.format_exc())


@contextmanager
def process_scan(refresh: bool):
    # Every pane checked inside shares one scan of the process table.
    prev = process_data_cache.start_caching(refresh=refresh)
    try:
        yield
    finally:
        process_data_cache.stop_caching(prev)


def is_claude_exe(path: str) -> bool:
    # A native install resolves to .../claude/versions/<version>.
    parent = os.path.dirname(path)
    return os.path.basename(path) == 'claude' or (
        os.path.basename(parent) == 'versions' and os.path.basename(os.path.dirname(parent)) == 'claude')


def is_claude(window: Window, pid: int) -> bool:
    cmdline = window.child.cmdline_of_pid(pid)
    if cmdline:
        name = os.path.basename(cmdline[0])
        if name == 'claude':
            return True
        if name in INTERPRETERS:
            script = next((arg for arg in cmdline[1:] if not arg.startswith('-')), '')
            return os.path.basename(script) == 'claude' or '/@anthropic-ai/claude-code/' in script
    try:
        return is_claude_exe(abspath_of_exe(pid))
    except Exception:
        # The process is gone, or the OS refuses its path.
        return False


def job_has_claude(window: Window, fresh: bool) -> bool:
    # Any process of the foreground job counts, not only its leader, so a
    # wrapper such as `caffeinate -i claude` still shows the bar.
    pgid = os.tcgetpgrp(window.child.child_fd)
    now = monotonic()
    if fresh or pgid != window._ctb_pgid or now - window._ctb_scanned_at >= SCAN_TTL:
        window._ctb_pgid, window._ctb_scanned_at = pgid, now
        window._ctb_claude = any(is_claude(window, pid) for pid in processes_in_group(pgid))
    return window._ctb_claude


def runs_session(window: Window, fresh: bool = False) -> bool:
    try:
        if not job_has_claude(window, fresh):
            return False
        return not termios.tcgetattr(window.child.child_fd)[3] & termios.ICANON
    except (OSError, TypeError, termios.error):
        # The pane's terminal is closed or not open yet.
        return False


def decide(window: Window, wanted: bool, fresh: bool = False) -> bool:
    if not wanted:
        return False
    tab = window.tabref()
    if tab is None:
        return wanted
    if tab.force_show_title_bars:
        return True
    group = tab.windows.group_for_window(window) or (window,)
    return any(runs_session(w, fresh) for w in group)


def get_show_title_bar(self: Window) -> bool:
    return self._ctb_shown


def set_show_title_bar(self: Window, value: bool) -> None:
    # kitty sets this on each visible pane right before it lays out the tab.
    self._ctb_wanted = bool(value)
    try:
        with process_scan(refresh=False):
            self._ctb_shown = decide(self, self._ctb_wanted)
    except Exception:
        report()
        self._ctb_shown = self._ctb_wanted


def check(window: Window, fresh: bool = False) -> None:
    # A tab that shows no bars, or a pane its layout hides (a zoomed tab),
    # gets decided by the layout that shows it.
    if window.destroyed or not window._ctb_wanted:
        return
    try:
        tab = window.tabref()
        group = tab.windows.group_for_window(window) if tab is not None else None
        if group is None or not group.is_visible_in_layout:
            return
        with process_scan(refresh=fresh):
            changed = decide(window, True, fresh) != window._ctb_shown
        if changed:
            tab.relayout()
    except Exception:
        report()


def recheck_later(window: Window) -> None:
    window_id = window.id

    def recheck(timer_id: int | None) -> None:
        try:
            window = get_boss().window_id_map.get(window_id)
        except Exception:
            return
        if window is not None:
            check(window, fresh=True)

    for delay in RECHECKS:
        add_timer(recheck, delay, False)


def poll(timer_id: int | None) -> None:
    try:
        with process_scan(refresh=True):
            for window in list(get_boss().all_windows):
                check(window)
    except Exception:
        report()


def on_title_change(boss, window: Window, data) -> None:
    # kitty sends this for each title from the pane, a title set by hand or not.
    if ACTIVE:
        check(window)


def on_cmd_startstop(boss, window: Window, data) -> None:
    # Sent by kitty's shell integration as a command starts and ends.
    if not ACTIVE:
        return
    if data['is_start']:
        recheck_later(window)
    else:
        check(window, fresh=True)


def on_load(boss, data) -> None:
    if not ACTIVE:
        return
    # kitty gives global watchers only to panes it creates after loading
    # them, so add the hooks to the panes already open, then lay them out.
    for window in boss.all_windows:
        for name, hook in (('on_title_change', on_title_change), ('on_cmd_startstop', on_cmd_startstop)):
            hooks = getattr(window.watchers, name)
            if hook not in hooks:
                hooks.append(hook)
    for tab in boss.all_tabs:
        tab.relayout()
    add_timer(poll, POLL_INTERVAL, True)


def patch() -> bool:
    if getattr(Window, '_ctb_patched', False):
        return True
    if not isinstance(Window.__dict__.get('show_title_bar'), bool):
        log_error('claude_title_bars: Window.show_title_bar is not a plain flag in this kitty, so the watcher stays off')
        return False
    Window._ctb_wanted = False
    Window._ctb_shown = False
    Window._ctb_pgid = -1
    Window._ctb_scanned_at = 0.0
    Window._ctb_claude = False
    Window.show_title_bar = property(get_show_title_bar, set_show_title_bar)
    Window._ctb_patched = True
    return True


ACTIVE = patch()
