return {
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local cmp = require("cmp")

      opts.formatting = {
        format = function(_entry, item)
          local icons = require("lazyvim.config").icons.kinds
          local content = item.abbr
          local menu = item.menu
          local win_width = vim.api.nvim_win_get_width(0)
          local max_content_width = math.floor(win_width * 0.3)
          local max_menu_width = math.floor(win_width * 0.2)

          if icons[item.kind] then
            item.kind = icons[item.kind] .. item.kind
          end

          if #content > max_content_width then
            item.abbr = vim.fn.strcharpart(content, 0, max_content_width - 3) .. "..."
          end

          if (menu ~= nil and #menu > max_menu_width) then
            item.menu = vim.fn.strcharpart(menu, 0, max_menu_width - 3) .. "..."
          end

          return item
        end,
      }

      opts.mapping = vim.tbl_deep_extend("force", opts.mapping, {
        ["<CR>"] = cmp.mapping.confirm({ select = false }),
        ["<Right>"] = cmp.mapping.confirm({ select = false }),
      })
      opts.preselect = cmp.PreselectMode.None
      opts.completion = {
        completeopt = "menu,menuone,noinsert,noselect",
      }
      opts.window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      }
    end,
  },
}
