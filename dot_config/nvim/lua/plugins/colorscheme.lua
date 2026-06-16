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
    "sainnhe/everforest",
    priority = 1000,
    init = function()
      vim.g.everforest_background = "medium"
      vim.g.everforest_better_performance = 1
    end,
  },
}
