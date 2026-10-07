# Cmd+click in a window where a program has the mouse. kitty.conf runs this on
# the release of cmd+left in grabbed mode; the press reaches the program as is,
# and this passes the release on. A mouse_map cannot tell windows apart, so
# this does it.
#
# terminal-browser: it sees Cmd+click itself and opens the link in a new tab.
# It reads mouse positions in pixels, and kitty's Python API gives only the
# cell of the pointer, so the release takes its position from macOS. When that
# fails, the release goes to the middle of the cell, which can miss a small
# link.
#
# Any other program (Claude Code, nvim): it sees a plain click, and kitty then
# opens the link under the mouse, as Cmd+click does in a shell. Claude Code
# opens a link only on Ctrl+click, and kitty sends Cmd+click with no modifier.
import ctypes
import os

from kittens.tui.handler import result_handler
from kitty.fast_data_types import (
    RELEASE,
    cell_size_for_window,
    get_os_window_pos,
    get_os_window_size,
    send_mouse_event,
)


# send_mouse_event takes X11 button numbers (left is 1), not GLFW ones (left is 0).
LEFT_BUTTON = 1


class CGPoint(ctypes.Structure):
    _fields_ = [('x', ctypes.c_double), ('y', ctypes.c_double)]


def main(args):
    pass


def runs_terminal_browser(window):
    return any(
        p['cmdline'] and os.path.basename(p['cmdline'][0]) == 'terminal-browser'
        for p in window.child.foreground_processes
    )


def pointer_location():
    """The pointer in macOS global coordinates (points, origin at the top left)."""
    cg = ctypes.cdll.LoadLibrary('/System/Library/Frameworks/CoreGraphics.framework/CoreGraphics')
    cf = ctypes.cdll.LoadLibrary('/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation')
    cg.CGEventCreate.restype = ctypes.c_void_p
    cg.CGEventCreate.argtypes = [ctypes.c_void_p]
    cg.CGEventGetLocation.restype = CGPoint
    cg.CGEventGetLocation.argtypes = [ctypes.c_void_p]
    cf.CFRelease.argtypes = [ctypes.c_void_p]
    event = cg.CGEventCreate(None)
    if not event:
        # CFRelease(NULL) crashes the process, and here the process is kitty.
        raise OSError('CGEventCreate returned NULL')
    try:
        return cg.CGEventGetLocation(event)
    finally:
        cf.CFRelease(event)


def pointer_pixels(window, cell):
    """The pointer in pixels from the top left of the cell area, as kitty
    reports it in pixel mode. Falls back to the middle of the pointer's cell
    when the macOS position is in another cell."""
    cell_width, cell_height = cell_size_for_window(window.os_window_id)
    quarter = cell_width // 4 if cell['in_left_half_of_cell'] else 3 * cell_width // 4
    fallback = (cell['cell_x'] * cell_width + quarter, cell['cell_y'] * cell_height + cell_height // 2)
    try:
        point = pointer_location()
        left, top = get_os_window_pos(window.os_window_id)
        size = get_os_window_size(window.os_window_id)
        x = (point.x - left) * size['framebuffer_width'] / size['width'] - window.geometry.left
        y = (point.y - top) * size['framebuffer_height'] / size['height'] - window.geometry.top
    except Exception:
        return fallback
    if (int(x // cell_width), int(y // cell_height)) != (cell['cell_x'], cell['cell_y']):
        return fallback
    return round(x), round(y)


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    window = boss.window_id_map.get(target_window_id)
    cell = window.current_mouse_position() if window else None
    if cell is None:
        return
    try:
        x, y = pointer_pixels(window, cell)
    except Exception:
        # kitty has swallowed the real release, so one goes out anyway, or the
        # program keeps the button down.
        x = y = 0
    send_mouse_event(
        window.screen, cell['cell_x'], cell['cell_y'], LEFT_BUTTON, RELEASE, 0,
        pixel_x=x, pixel_y=y, in_left_half_of_cell=cell['in_left_half_of_cell'],
    )
    if not runs_terminal_browser(window):
        window.mouse_handle_click('link')
