return {
  "folke/snacks.nvim",
  opts = {
    scratch = {
      win = {
        style = "scratch",
        relative = "editor",
        position = "right",
      },
    },
    dashboard = { enabled = false },
    picker = {
      matcher = {
        frecency = true,
      },
      formatters = {
        file = {
          truncate = 80,
        },
      },
      previewers = {
        git = {
          native = true,
        },
      },
    },
  },
}
