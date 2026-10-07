# Cmd shortcuts that kitty and terminal-browser both bind. kitty takes a key
# first, so kitty.conf sends each one here: the key goes to terminal-browser
# when the browser runs in the window, and kitty does its own action otherwise.
# A --when-focus-on map cannot tell the two apart: its cmdline field matches the
# process that started the window, which is the shell when `daily` runs the
# browser.
#
#   map cmd+r kitten browser_keys.py cmd+r start_resizing_window
#
# The first argument is the key to send, and the rest is kitty's action for it.
import os

from kittens.tui.handler import result_handler


def main(args):
    pass


def runs_terminal_browser(window):
    return any(
        p['cmdline'] and os.path.basename(p['cmdline'][0]) == 'terminal-browser'
        for p in window.child.foreground_processes
    )


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    key, action = args[1], ' '.join(args[2:])
    window = boss.window_id_map.get(target_window_id)
    if window is None:
        return
    if runs_terminal_browser(window):
        window.send_key(key)
    elif action == 'close_window':
        # What the close_window action does.
        boss.mark_window_for_close(window)
    else:
        boss.combine(action, window)
