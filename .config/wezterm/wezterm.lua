local wezterm = require 'wezterm'
local act = wezterm.action

local function isViProcess(pane)
  -- get_foreground_process_name On Linux, macOS and Windows,
  -- the process can be queried to determine this path. Other operating systems
  -- (notably, FreeBSD and other unix systems) are not currently supported
  return pane:get_foreground_process_name():find('n?vim') ~= nil
  -- return pane:get_title():find("n?vim") ~= nil
end

local function conditionalActivatePane(window, pane, pane_direction, vim_direction)
  if isViProcess(pane) then
    window:perform_action(
      act.SendKey({ key = vim_direction, mods = 'CTRL' }),
      pane
    )
  else
    window:perform_action(act.ActivatePaneDirection(pane_direction), pane)
  end
end

wezterm.on('ActivatePaneDirection-right', function(window, pane)
  conditionalActivatePane(window, pane, 'Right', 'l')
end)
wezterm.on('ActivatePaneDirection-left', function(window, pane)
  conditionalActivatePane(window, pane, 'Left', 'h')
end)
wezterm.on('ActivatePaneDirection-up', function(window, pane)
  conditionalActivatePane(window, pane, 'Up', 'k')
end)
wezterm.on('ActivatePaneDirection-down', function(window, pane)
  conditionalActivatePane(window, pane, 'Down', 'j')
end)

return {
  color_scheme = 'nordfox',
  font = wezterm.font('JetBrainsMono Nerd Font', { weight = 'Medium' }),
  harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' },
  font_size = 13.0,

  window_decorations = 'RESIZE',
  window_padding = {
    left = '0.5cell',
    right = '0.5cell',
    top = '0.2cell',
    bottom = '0.1cell',
  },

  hyperlink_rules = {
    {
      regex = [[/Users/.*(?:\.png|\.html)]],
      format = '$0'
    },
    -- Linkify things that look like URLs and the host has a TLD name.
    {
      regex = '\\b\\w+://[\\w.-]+\\.[a-z]{2,15}\\S*\\b',
      format = '$0',
    },
    -- file:// URI
    {
      regex = [[\bfile://\S*\b]],
      format = '$0',
    },
    -- Linkify things that look like URLs with numeric addresses as hosts.
    -- E.g. http://127.0.0.1:8000 for a local development server,
    -- or http://192.168.1.1 for the web interface of many routers
    {
      regex = [[\b\w+://(?:[\d]{1,3}\.){3}[\d]{1,3}\S*\b]],
      format = '$0',
    },
  },

  inactive_pane_hsb = {
    saturation = 0.9,
    brightness = 0.75
  },
  keys = {
    { key = 'w', mods = 'CMD', action = act.CloseCurrentPane { confirm = true } },
    { key = 'h', mods = 'CTRL', action = act.EmitEvent('ActivatePaneDirection-left') },
    { key = 'l', mods = 'CTRL', action = act.EmitEvent('ActivatePaneDirection-right') },
    { key = 'k', mods = 'CTRL', action = act.EmitEvent('ActivatePaneDirection-up') },
    { key = 'j', mods = 'CTRL', action = act.EmitEvent('ActivatePaneDirection-down') },
    { key = 'LeftArrow', mods = 'CTRL|SHIFT', action = act.AdjustPaneSize { 'Left', 5 }, },
    { key = 'RightArrow', mods = 'CTRL|SHIFT', action = act.AdjustPaneSize { 'Right', 5 }, },
    { key = 'UpArrow', mods = 'CTRL|SHIFT', action = act.AdjustPaneSize { 'Up', 5 }, },
    { key = 'DownArrow', mods = 'CTRL|SHIFT', action = act.AdjustPaneSize { 'Down', 5 }, },
    { key = '0', mods = 'CTRL|SHIFT', action = act.PaneSelect { mode = 'SwapWithActive' } },
    { key = 'K', mods = 'CTRL|SHIFT', action = act.ClearScrollback 'ScrollbackAndViewport' },
    { key = 'Z', mods = 'CTRL|SHIFT', action = act.TogglePaneZoomState },
    { key = 'B', mods = 'CTRL|SHIFT', action = act.RotatePanes 'CounterClockwise' },
    { key = 'N', mods = 'CTRL|SHIFT', action = act.RotatePanes 'Clockwise' },
    { key = 'S', mods = 'CMD|SHIFT', action = act.SplitPane { direction = 'Down', size = { Percent = 20 } }, },
    { key = 'V', mods = 'CMD|SHIFT', action = act.SplitPane { direction = 'Right' }, }
  }
}
