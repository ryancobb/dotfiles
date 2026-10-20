return {
  {
    "EdenEast/nightfox.nvim",
    opts = function()
      -- Cozy cabin (lua/nightfox/palette/cozycabin.lua, which chezmoi renders
      -- from the palette data file .chezmoidata/cozycabin.yaml) is the shared
      -- cabin palette as a nightfox palette. Requiring it registers the
      -- name, and setup compiles every registered fox. Nightfox keys its
      -- compile cache by a hash of these options, so the palette file's mtime
      -- rides along: an edit there recompiles instead of showing the stale
      -- cache (nightfox ignores the key otherwise).
      require("nightfox.palette.cozycabin")
      local palette_file = vim.fn.stdpath("config") .. "/lua/nightfox/palette/cozycabin.lua"
      return {
        cozycabin_mtime = vim.fn.getftime(palette_file),
        options = {
          dim_inactive = true,
          styles = {
            comments = "italic",
          },
        },
        groups = {
          all = {
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
