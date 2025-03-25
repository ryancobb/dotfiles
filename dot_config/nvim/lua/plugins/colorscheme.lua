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
          all = {
            NeoTreeNormal = { link = "Normal" },
            NeoTreeNormalNC = { link = "NormalNC" },
          },
        },
      }
    end,
  },
  {
    "neanias/everforest-nvim",
    version = false,
    lazy = false,
    priority = 1000,
    config = function()
      require("everforest").setup({
        italics = true,
        dim_inactive_windows = true,
        on_highlights = function(hl, _)
          hl.TSFunctBuiltin = { link = "TSField" }
          hl.TSFunction = { link = "TSField" }
          hl.TSFunctionCall = { link = "TSField" }
          hl.TSMethod = { link = "TSField" }
          hl.TSSymbol = { link = "TSField" }
          hl["@string.special.symbol.ruby"] = { link = "Special" }
          hl.SnacksPicker = { link = "Normal" }
          hl.SnacksPickerBorder = { link = "Normal" }
          hl.SnacksPickerTitle = { link = "Todo" }
        end,
      })
    end,
  },
}
