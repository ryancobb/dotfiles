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

      -- opts.options = {
      --   component_separators = "|",
      --   section_separators = { left = "", right = "" },
      -- }

      opts.options.globalstatus = false

      opts.sections.lualine_z = {
        function()
          return " " .. os.date("%I:%M %p")
        end,
      }

      opts.extensions = { blank }

      table.remove(opts.sections.lualine_c) -- remove navic
      -- replace pretty_path to use a subtler filename highlight
      opts.sections.lualine_c[#opts.sections.lualine_c] = { LazyVim.lualine.pretty_path({ filename_hl = "Comment", directory_hl = "Comment" }) }

      opts.inactive_sections = {
        lualine_c = { { LazyVim.lualine.pretty_path({ filename_hl = "Comment", directory_hl = "Comment" }) } },
      }

      -- local winbar = {
      --   lualine_c = {
      --     {
      --       "diff",
      --       colored = true,
      --       symbols = { added = "+", modified = "~", removed = "-" },
      --       source = function()
      --         local gitsigns = vim.b.gitsigns_status_dict
      --         if gitsigns then
      --           return {
      --             added = gitsigns.added,
      --             modified = gitsigns.changed,
      --             removed = gitsigns.removed,
      --           }
      --         end
      --       end,
      --     },
      --   },
      --   lualine_b = {
      --     {
      --       "filename",
      --       file_status = true, -- shows modified/readonly status
      --       path = 1, -- relative path
      --       symbols = {
      --         modified = " ●",
      --         readonly = " ",
      --         unnamed = "[No Name]",
      --       },
      --     },
      --   },
      -- }

      -- opts.winbar = winbar
      -- opts.inactive_winbar = winbar
    end,
  },
}
