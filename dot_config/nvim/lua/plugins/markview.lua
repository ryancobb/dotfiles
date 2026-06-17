-- Private markview checkbox "state" key used to tag checkmate todo lines (see
-- markview.lua opts/config below). LuaJIT has no \u escape, so build the "§"
-- byte sequence directly; the exact glyph is irrelevant, it just has to be a
-- key that won't collide with a real `[x]`-style checkbox char.
local checkmate_state = string.char(0xC2, 0xA7) -- §

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
      -- Heading levels 1-3 render as colored bands (markview's "icon" style:
      -- markers concealed, leading icon, line-wide background) so upper-level
      -- sections separate clearly from body text. Levels 4-6 stay as rounded
      -- "pill" chips. The bands' left edge is inset to the section's staircase
      -- indent by the custom renderer below (markview's icon style would start
      -- the bg at column 0). Colors live in the MarkviewHeading*/
      -- MarkviewHeading*Corner groups, set by the config function below from
      -- the active colorscheme.
      local icons = { "󰼏 ", "󰎨 ", "󰼑 ", "󰎲 ", "󰼓 ", "󰎴 " }
      -- Top N heading levels rendered as bars instead of chips.
      local bar_levels = 3
      -- Indent step: spaces of section-content indent per heading level, and
      -- the matching heading staircase step (so headings and their content
      -- sit on the same staircase; markview's default would be 1).
      local shift_width = 2
      -- Rounded "pill" cap glyphs, built from codepoints (U+E0B6 / U+E0B4) so
      -- the private-use characters survive being written to disk.
      local cap_left = string.char(0xEE, 0x82, 0xB6) --
      local cap_right = string.char(0xEE, 0x82, 0xB4) --
      local headings = {
        -- Indent section content based on heading depth (org-mode style).
        -- Only content below the heading line is shifted (the heading itself
        -- is not), matching the old render-markdown skip_heading behavior.
        org_indent = true,
        org_shift_width = shift_width,
        shift_width = shift_width,
      }
      for i = 1, 6 do
        local hl = "MarkviewHeading" .. i
        if i <= bar_levels then
          -- Band style. The custom renderer below insets the bg to the
          -- staircase indent; this "icon" config is the fallback if that
          -- renderer is ever removed (full-width band from column 0).
          headings["heading_" .. i] = {
            style = "icon",
            hl = hl,
            icon = icons[i],
            icon_hl = hl,
          }
        else
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
      end

      -- Merge into the opts lazy.nvim hands us (don't replace, or markview
      -- options from LazyVim/other specs would be dropped).
      opts.markdown = vim.tbl_deep_extend("force", opts.markdown or {}, { headings = headings })
      -- checkmate.nvim owns todo glyph rendering. In its `*.md` buffers the
      -- `[ ]` brackets are already rewritten to glyphs, so markview's inline
      -- checkbox renderer never fires there and there's no double-render even
      -- with checkboxes enabled. We must NOT disable checkboxes: the list-item
      -- renderer's `conceal_on_checkboxes` (which hides the `- ` marker) reads
      -- the checkbox state via a spec lookup that returns nil when disabled, so
      -- disabling it would break the conceal we rely on below.
      --
      -- `checkmate_state` is a private checkbox state we tag checkmate todo
      -- lines with (see the parser wrap below). It carries no `scope_hl`, so
      -- markview won't tint the todo content (checkmate handles that), and an
      -- empty `text` means markview draws nothing for it (checkmate's glyph is
      -- the only marker shown).
      opts.markdown_inline = vim.tbl_deep_extend("force", opts.markdown_inline or {}, {
        checkboxes = {
          [checkmate_state] = { text = "" },
        },
      })

      -- Custom atx-heading renderer (markview's supported `renderers` hook,
      -- keyed by node class). markview's built-in "icon" style paints the band
      -- background across the whole screen line from column 0, which ignores
      -- the staircase indent. For the bar levels we re-render so the band
      -- begins at the indent (it nests under its section); chip levels are
      -- delegated to the built-in renderer untouched.
      opts.renderers = vim.tbl_deep_extend("force", opts.renderers or {}, {
        markdown_atx_heading = function(buffer, item)
          local md_render = require("markview.renderers.markdown")
          local level = #item.marker
          if level > bar_levels then
            return md_render.atx_heading(buffer, item)
          end

          local hl = "MarkviewHeading" .. level
          local range = item.range
          local text1 = item.text[1] or ""
          local indent = string.rep(" ", (level - 1) * shift_width)

          -- Conceal the "###" marker; draw the staircase indent (no highlight,
          -- so it stays outside the band), a rounded left cap (its fg is the
          -- band bg, matching the chips), then the colored icon.
          vim.api.nvim_buf_set_extmark(buffer, md_render.ns, range.row_start, range.col_start, {
            undo_restore = false,
            invalidate = true,
            end_col = range.col_start + #item.marker + (#text1 > #item.marker and 1 or 0),
            conceal = "",
            virt_text_pos = "inline",
            hl_mode = "combine",
            virt_text = {
              { indent },
              { cap_left, hl .. "Corner" },
              { icons[level] or "", hl },
            },
          })

          -- Band background. The range runs to the start of the next line so it
          -- covers this line's EOL; hl_eol then fills the band to the window
          -- edge (a full bar). Starting at the (concealed) marker means the
          -- visible band begins right at the inline icon above.
          vim.api.nvim_buf_set_extmark(buffer, md_render.ns, range.row_start, range.col_start, {
            undo_restore = false,
            invalidate = true,
            end_row = range.row_start + 1,
            end_col = 0,
            hl_group = hl,
            hl_eol = true,
          })
        end,
      })

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

      -- checkmate.nvim rewrites the buffer, turning `- [ ]` into `- ▢` (the
      -- bracketed checkbox is gone). markview then sees a plain list item and
      -- renders its bullet over the `-`, so a todo shows as "● ▢". Detect those
      -- lines (list marker followed by a checkmate marker glyph) and tag them
      -- with our private checkbox state. That trips markview's built-in
      -- `conceal_on_checkboxes`, which hides the `- ` marker, leaving just
      -- checkmate's glyph ("▢ task"). Bullets on non-todo lists are untouched.
      local checkmate_markers -- set of glyphs, resolved lazily once checkmate loads
      local function is_checkmate_todo(line)
        if not checkmate_markers then
          local ok, cfg = pcall(require, "checkmate.config")
          if not (ok and cfg.options and cfg.options.todo_states) then
            return false
          end
          checkmate_markers = {}
          for _, def in pairs(cfg.options.todo_states) do
            if def.marker then
              checkmate_markers[def.marker] = true
            end
          end
        end
        local content = line:match("^[%>%s]*[%-%+%*]%s+(.+)$") or line:match("^[%>%s]*%d+[%.%)]%s+(.+)$")
        if not content then
          return false
        end
        for marker in pairs(checkmate_markers) do
          local after = content:sub(#marker + 1, #marker + 1)
          if content:sub(1, #marker) == marker and (after == "" or after == " ") then
            return true
          end
        end
        return false
      end

      local orig_insert = md_parser.insert
      md_parser.insert = function(data)
        if
          type(data) == "table"
          and data.class == "markdown_list_item"
          and not data.checkbox
          and data.text
          and data.text[1]
          and is_checkmate_todo(data.text[1])
        then
          data.checkbox = checkmate_state
        end
        return orig_insert(data)
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
