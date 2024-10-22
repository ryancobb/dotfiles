return {
  {
    "EdenEast/nightfox.nvim",
    opts = function()
      local spec = require("nightfox.spec").load("nordfox")
      local palette = require("nightfox.palette").load("nightfox")
      local C = require("nightfox.lib.color")

      -- vim.api.nvim_create_autocmd({ "FocusLost" }, {
      --   pattern = { "*" },
      --   callback = function()
      --     vim.cmd("hi clear Normal")
      --     vim.cmd("hi Normal guibg=" .. palette.bg0)
      --   end,
      -- })
      --
      -- vim.api.nvim_create_autocmd({ "FocusGained" }, {
      --   pattern = { "*" },
      --   callback = function()
      --     vim.cmd("hi clear Normal")
      --     vim.cmd("hi Normal guibg=" .. palette.bg1)
      --   end,
      -- })

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
            WindowPickerStatusLine = { link = "@text.warning" },
            WindowPickerStatusLineNC = { link = "@text.warning" },
            ["@comment.todo"] = { link = "@comment" },
            ["@lsp.type.namespace.ruby"] = { link = "@type.ruby" },
            ["@lsp.type.parameter.ruby"] = { link = "@variable.ruby" },
            DiffAdd = { bg = C(spec.bg1):blend(C(palette.green.dim), 0.25):to_css() },
            DiffChange = { bg = C(spec.bg1):blend(C(palette.yellow.dim), 0.15):to_css() },
            DiffDelete = { bg = C(spec.bg1):blend(C(palette.red.dim), 0.25):to_css() },
            DiffText = { bg = C(spec.bg1):blend(C(palette.yellow.dim), 0.3):to_css() },
            Folded = { bg = "none" },
            RainbowDelimiterRed = { link = "TSRainbowRed" },
            RainbowDelimiterBlue = { link = "TSRainbowBlue" },
            RainbowDelimiterCyan = { link = "TSRainbowCyan" },
            RainbowDelimiterGreen = { link = "TSRainbowGreen" },
            RainbowDelimiterOrange = { link = "TSRainbowOrange" },
            RainbowDelimiterViolet = { link = "TSRainbowViolet" },
            RainbowDelimiterYellow = { link = "TSRainbowYellow" },
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
        background = "soft",
        italics = true,
        dim_inactive_windows = true,
        on_highlights = function(hl, _)
          hl.TSFunctBuiltin = { link = "TSField" }
          hl.TSFunction = { link = "TSField" }
          hl.TSFunctionCall = { link = "TSField" }
          hl.TSMethod = { link = "TSField" }
          hl.TSSymbol = { link = "TSField" }
          hl["@string.special.symbol.ruby"] = { link = "Special" }
        end,
      })
    end,
  }
}
