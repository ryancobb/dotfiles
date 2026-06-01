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

      opts.options.globalstatus = false
      opts.options.component_separators = ""
      opts.options.section_separators = { left = "\u{e0b4}", right = "\u{e0b6}" }

      opts.sections.lualine_z = {
        function()
          return " " .. os.date("%I:%M %p")
        end,
      }

      opts.extensions = { blank }

      -- pretty_path and filetype now live in the winbar
      opts.sections.lualine_c = vim.tbl_filter(function(c)
        if c[1] == "filetype" then
          return false
        end
        -- pretty_path is the only entry that's a bare function (no cond/color);
        -- root_dir is also function-based but is wrapped in a table with cond/color.
        if type(c[1]) == "function" and c.cond == nil and c.color == nil then
          return false
        end
        return true
      end, opts.sections.lualine_c)

      opts.inactive_sections = {
        lualine_c = {},
      }

      local winbar = {
        lualine_c = {
          {
            "diff",
            colored = true,
            symbols = { added = "+", modified = "~", removed = "-" },
            source = function()
              local gitsigns = vim.b.gitsigns_status_dict
              if gitsigns then
                return {
                  added = gitsigns.added,
                  modified = gitsigns.changed,
                  removed = gitsigns.removed,
                }
              end
            end,
          },
        },
        lualine_b = {
          { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
          {
            "filename",
            file_status = true, -- shows modified/readonly status
            path = 1, -- relative path
            symbols = {
              modified = " ●",
              readonly = " ",
              unnamed = "[No Name]",
            },
          },
        },
      }

      opts.winbar = winbar
      opts.inactive_winbar = winbar
    end,
  },
}
