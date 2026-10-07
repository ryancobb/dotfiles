# Cmd+W closes the active terminal-browser tab when the browser runs in the
# window, and closes the window otherwise. terminal-browser binds cmd+w to close
# its tab, but kitty takes the key first. A --when-focus-on map cannot tell the
# two apart: its cmdline field matches the process that started the window,
# which is the shell when `daily` runs the browser.
import os

from kittens.tui.handler import result_handler


def main(args):
    pass


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    window = boss.window_id_map.get(target_window_id)
    if window is None:
        return
    if any(
        p['cmdline'] and os.path.basename(p['cmdline'][0]) == 'terminal-browser'
        for p in window.child.foreground_processes
    ):
        window.send_key('cmd+w')
    else:
        # What the close_window action does.
        boss.mark_window_for_close(window)
