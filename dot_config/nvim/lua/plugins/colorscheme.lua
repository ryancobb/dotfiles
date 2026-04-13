return {
  {
    "EdenEast/nightfox.nvim",
    opts = function()
      return {
        options = {
          dim_inactive = true,
          styles = {
            comments = "italic",
          },
        },
        groups = {
          nordfox = {
            Folded = { bg = "palette.bg0" },
          },
        },
      }
    end,
  },
  {
    "ember-theme/nvim",
    name = "ember",
    priority = 1000,
    config = function()
      require("ember").setup({
        variant = "ember-soft",
      })
    end,
  },
}
