local wezterm = require 'wezterm'

return {
  font = wezterm.font('JetBrainsMono Nerd Font', { weight = 'Medium' }),
  font_size = 13.0,

  window_decorations = 'RESIZE',
  window_padding = {
    left = '0.5cell',
    right = '0.5cell',
    top = '0.2cell',
    bottom = '0.2cell',
  },

  hyperlink_rules = {
    {
      regex = [[/Users/.*(?:\.png|\.html)]],
      format = '$0'
    }
  },

  inactive_pane_hsb = {
    saturation = 0.9,
    brightness = 0.75
  },
  color_scheme = 'Catppuccin Frappe',
  window_frame = {
    active_titlebar_bg = '#232634',
  },
  colors = {
    tab_bar = {
      inactive_tab_edge = '#575757',
      active_tab = {
        bg_color = '#626880',
        fg_color = '#c6d0f5',
      },
      inactive_tab = {
        bg_color = '#292c3c',
        fg_color = '#c6d0f5'
      },
      new_tab = {
        bg_color = '#303446',
        fg_color = '#c6d0f5'
      }
    }
  },

  keys = {
    {
      key = 'w',
      mods = 'CMD',
      action = wezterm.action.CloseCurrentPane { confirm = true }
    },
    {
      key = 'h',
      mods = 'CMD|SHIFT',
      action = wezterm.action.SplitPane {
        direction = 'Down',
        size = { Percent = 20 }
      },
    },
    {
      key = 'v',
      mods = 'CMD|SHIFT',
      action = wezterm.action.SplitPane {
        direction = 'Right'
      },
    },
    {
      key = 'h',
      mods = 'CTRL|SHIFT',
      action = wezterm.action.ActivatePaneDirection 'Left',
    },
    {
      key = 'l',
      mods = 'CTRL|SHIFT',
      action = wezterm.action.ActivatePaneDirection 'Right',
    },
    {
      key = 'k',
      mods = 'CTRL|SHIFT',
      action = wezterm.action.ActivatePaneDirection 'Up',
    },
    {
      key = 'j',
      mods = 'CTRL|SHIFT',
      action = wezterm.action.ActivatePaneDirection 'Down',
    },
    {
      key = 'LeftArrow',
      mods = 'CTRL|SHIFT',
      action = wezterm.action.AdjustPaneSize { 'Left', 5 },
    },
    {
      key = 'RightArrow',
      mods = 'CTRL|SHIFT',
      action = wezterm.action.AdjustPaneSize { 'Right', 5 },
    },
    {
      key = 'UpArrow',
      mods = 'CTRL|SHIFT',
      action = wezterm.action.AdjustPaneSize { 'Up', 5 },
    },
    {
      key = 'DownArrow',
      mods = 'CTRL|SHIFT',
      action = wezterm.action.AdjustPaneSize { 'Down', 5 },
    },
    {
      key = '0',
      mods = 'CTRL',
      action = wezterm.action.PaneSelect {
        mode = 'SwapWithActive'
      }
    }
  }
}
