return {
  {
    "s1n7ax/nvim-window-picker",
    name = "window-picker",
    event = "VeryLazy",
    opts = {
      hint = "floating-big-letter",
      filter_rules = {
        include_current_win = true,
        autoselect_one = true,
        bo = {
          filetype = { "neo-tree", "notify", "snacks_notif" },
        },
      },
    },
  },
}
