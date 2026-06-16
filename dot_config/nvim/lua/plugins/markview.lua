return {
  -- In-editor markdown renderer (replaces render-markdown.nvim).
  {
    "OXY2DEV/markview.nvim",
    -- Do NOT lazy-load: markview is already lazy internally, and deferring it
    -- slows down preview load on startup. It should load after the colorscheme.
    lazy = false,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<leader>um", "<cmd>Markview Toggle<cr>", desc = "Toggle Markview (global)" },
      { "<leader>uM", "<cmd>Markview splitToggle<cr>", desc = "Toggle Markview splitview" },
    },
    opts = function(_, opts)
      -- Build a "label" (pill) config for every heading level. Colors live in
      -- the MarkviewHeading*/MarkviewHeading*Corner groups, set by the config
      -- function below from the active colorscheme.
      local icons = { "󰼏 ", "󰎨 ", "󰼑 ", "󰎲 ", "󰼓 ", "󰎴 " }
      -- Rounded "pill" cap glyphs, built from codepoints (U+E0B6 / U+E0B4) so
      -- the private-use characters survive being written to disk.
      local cap_left = string.char(0xEE, 0x82, 0xB6) --
      local cap_right = string.char(0xEE, 0x82, 0xB4) --
      local headings = {
        -- Indent section content based on heading depth (org-mode style).
        -- Only content below the heading line is shifted (the heading itself
        -- is not), matching the old render-markdown skip_heading behavior.
        org_indent = true,
        org_shift_width = 2, -- spaces of content indent per heading level
        -- Match the heading-badge indent step to org_shift_width so headings
        -- and their content sit on the same staircase (default would be 1).
        shift_width = 2,
      }
      for i = 1, 6 do
        local hl = "MarkviewHeading" .. i
        headings["heading_" .. i] = {
          style = "label",
          hl = hl,
          icon = icons[i],
          icon_hl = hl,
          padding_left = " ",
          padding_right = " ",
          -- Rounded "pill" caps; their fg is the badge bg (set below).
          corner_left = cap_left,
          corner_left_hl = hl .. "Corner",
          corner_right = cap_right,
          corner_right_hl = hl .. "Corner",
        }
      end

      -- Merge into the opts lazy.nvim hands us (don't replace, or markview
      -- options from LazyVim/other specs would be dropped).
      opts.markdown = vim.tbl_deep_extend("force", opts.markdown or {}, { headings = headings })
      -- Let checkmate.nvim own todo/checkbox rendering (avoid double-render).
      opts.markdown_inline =
        vim.tbl_deep_extend("force", opts.markdown_inline or {}, { checkboxes = { enable = false } })
      return opts
    end,
    config = function(_, opts)
      -- Fix a markview org_indent off-by-one: a section's indent range is
      -- derived from its trailing content node, whose tree-sitter range bleeds
      -- onto the *next* sibling heading's row. That wrongly indents the
      -- following heading (and compounds with nesting). Clamp org_end so it
      -- never reaches the next section's start row (row_end is exclusive).
      local md_parser = require("markview.parsers.markdown")
      local orig_section = md_parser.section
      md_parser.section = function(buffer, node, text, range)
        orig_section(buffer, node, text, range)
        if range.org_end and range.row_end and range.org_end >= range.row_end then
          range.org_end = range.row_end - 1
        end
      end

      require("markview").setup(opts)

      -- Source six distinct, vivid heading colors from the active nightfox
      -- palette (nordfox). markview ignores its own `highlight_groups` option
      -- in this version, so set the groups directly and re-apply on reload.
      local function set_heading_hls()
        local foxes = {
          carbonfox = true, dawnfox = true, dayfox = true, duskfox = true,
          nightfox = true, nordfox = true, terafox = true,
        }
        local fox = vim.g.colors_name
        local ok_p, palette = pcall(require, "nightfox.palette")
        local ok_c, Color = pcall(require, "nightfox.lib.color")

        if ok_p and ok_c and fox and foxes[fox] then
          local pal = palette.load(fox)
          local light = pal.meta and pal.meta.light
          local hues = { pal.red, pal.orange, pal.yellow, pal.green, pal.blue, pal.magenta }
          for i, hue in ipairs(hues) do
            -- ~35% hue over the editor bg: a clearly visible but tasteful tint.
            local tint = Color.from_hex(hue.base):blend(Color.from_hex(pal.bg1), 0.65):to_css()
            -- Dark hue on light themes, bright hue on dark themes, for contrast.
            local fg = light and hue.dim or hue.bright
            vim.api.nvim_set_hl(0, "MarkviewHeading" .. i, { fg = fg, bg = tint, bold = true })
            vim.api.nvim_set_hl(0, "MarkviewHeading" .. i .. "Corner", { fg = tint })
          end
        else
          -- Non-nightfox scheme: derive the pill caps from markview's own
          -- (colorscheme-derived) palette; leave the heading colors to markview.
          for i = 1, 6 do
            local pbg = vim.api.nvim_get_hl(0, { name = "MarkviewPalette" .. i, link = false }).bg
            if pbg then
              vim.api.nvim_set_hl(0, "MarkviewHeading" .. i .. "Corner", { fg = pbg })
            end
          end
        end
      end

      set_heading_hls()
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("markview_heading_hls", { clear = true }),
        callback = function()
          vim.schedule(set_heading_hls)
        end,
      })
    end,
  },

  -- Disable the renderer/preview that the LazyVim markdown extra pulls in.
  { "MeanderingProgrammer/render-markdown.nvim", enabled = false },
  { "iamcco/markdown-preview.nvim", enabled = false },

  -- Turn off markdownlint diagnostics for markdown buffers.
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.markdown = {}
      opts.linters_by_ft["markdown.mdx"] = {}
    end,
  },
}
