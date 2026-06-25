return {
  "jakewvincent/mkdnflow.nvim",
  ft = "markdown",
  opts = {
    modules = {
      maps = false,
      to_do = false,
    },
    path_resolution = {
      primary = "current",
      fallback = "first",
    },
    links = {
      -- Don't create a link from the text under the cursor when `gf` finds no
      -- link to follow; just do nothing instead.
      auto_create = false,
    },
  },
  keys = {
    { "gf", "<Cmd>MkdnFollowLink<CR>", ft = "markdown", desc = "Follow markdown link" },
    { "<BS>", "<Cmd>MkdnGoBack<CR>", ft = "markdown", desc = "Go back" },
  },
}
