return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      local blank = {
        sections = {
          lualine_a = {},
        },
        winbar = {
          lualine_c = {},
        },
        filetypes = { "neo-tree", "DiffviewFiles" },
      }

      opts.options = {
        component_separators = "|",
        section_separators = { left = "", right = "" },
      }

      opts.extensions = { blank }

      table.remove(opts.sections.lualine_c) -- remove navic
      table.remove(opts.sections.lualine_c) -- filename
      table.remove(opts.sections.lualine_c) -- icon

      opts.winbar = {
        lualine_c = {
          { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 }, color = "Normal" },
          { LazyVim.lualine.pretty_path({ modified_hl = 'Special', modified_sign = '[+]', length = 10 }), color = "Normal" },
        },
      }

      opts.inactive_winbar = {
        lualine_c = {
          { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 }, color = "NormalNC" },
          { LazyVim.lualine.pretty_path({ modified_hl = 'Special', modified_sign = '[+]', length = 10 }), color = "NormalNC" },
        },
      }
    end,
  },
}
