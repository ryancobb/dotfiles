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
    opts = {
      markdown = {
        headings = {
          -- Indent section content based on heading depth (org-mode style).
          -- Only content below the heading line is shifted (the heading itself
          -- is not), matching the old render-markdown skip_heading behavior.
          org_indent = true,
          org_shift_width = 2, -- spaces of indent per heading level
        },
      },
      -- Let checkmate.nvim own todo/checkbox rendering to avoid double-rendering.
      markdown_inline = {
        checkboxes = { enable = false },
      },
    },
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
