return {
  "obsidian-nvim/obsidian.nvim",
  version = "*", -- recommended, use latest release instead of latest commit
  lazy = true,
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = {
    workspaces = {
      {
        name = "work",
        path = "~/Projects/vaults/work",
      },
    },
    daily_notes = {
      folder = "notes/dailies",
    },
    completion = {
      nvim_cmp = false,
      blink = true,
    },
    picker = {
      name = "fzf-lua",
    },
    ui = {
      enable = false
    }
  },
}
