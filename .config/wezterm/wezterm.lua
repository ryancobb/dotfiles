local wezterm = require 'wezterm'
local act = wezterm.action

return {
  use_fancy_tab_bar = false,
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
    { key = 's', mods = 'CMD|SHIFT', action = act.SplitPane { direction = 'Down', size = { Percent = 20 } }, },
    { key = 'v', mods = 'CMD|SHIFT', action = act.SplitPane { direction = 'Right' }, },
    { key = 'h', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Left', },
    { key = 'l', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Right', },
    { key = 'k', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Up', },
    { key = 'j', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Down', },
    { key = 'LeftArrow', mods = 'CTRL|SHIFT', action = act.AdjustPaneSize { 'Left', 5 }, },
    { key = 'RightArrow', mods = 'CTRL|SHIFT', action = act.AdjustPaneSize { 'Right', 5 }, },
    { key = 'UpArrow', mods = 'CTRL|SHIFT', action = act.AdjustPaneSize { 'Up', 5 }, },
    { key = 'DownArrow', mods = 'CTRL|SHIFT', action = act.AdjustPaneSize { 'Down', 5 }, },
    { key = '0', mods = 'CTRL', action = act.PaneSelect { mode = 'SwapWithActive' } },
    { key = 'PageUp', mods = 'SHIFT', action = act.ScrollByPage(-0.5) },
    { key = 'PageDown', mods = 'SHIFT', action = act.ScrollByPage(0.5) },
  }
}
