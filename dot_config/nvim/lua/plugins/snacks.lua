return {
  "folke/snacks.nvim",
  keys = {
    {
      "<leader>se",
      function()
        local scratch = Snacks.scratch.get({})
        vim.cmd("edit " .. scratch.file)
      end,
      desc = "Open scratch as buffer",
    },
  },
  opts = {
    scratch = {
      win = {
        style = "scratch",
        relative = "editor",
        position = "right",
      },
    },
    dashboard = { enabled = false },
    -- Collapse the gutter to one sign slot on the right. The default splits
    -- marks/diagnostics left and fold/git right, but each slot is padded to two
    -- cells even when empty, and with a %! statuscolumn nvim sizes the column to
    -- the rendered content, so the idle left slot costs two columns everywhere.
    -- First match wins, so a fold or git sign masks a diagnostic on the same line.
    statuscolumn = {
      left = {},
      right = { "fold", "git", "sign", "mark" },
    },
    picker = {
      matcher = {
        frecency = true,
      },
      formatters = {
        file = {
          truncate = 80,
        },
      },
      previewers = {
        git = {
          native = true,
        },
      },
      sources = {
        explorer = {
          win = {
            list = {
              keys = {
                ["<c-h>"] = require("smart-splits").move_cursor_left,
                ["<c-j>"] = require("smart-splits").move_cursor_down,
                ["<c-k>"] = require("smart-splits").move_cursor_up,
                ["<c-l>"] = require("smart-splits").move_cursor_right,
              },
            },
          },
        },
      },
    },
    indent = {
      filter = function(buf)
        if vim.bo[buf].filetype == "markdown" then
          return false
        end

        return vim.g.snacks_indent ~= false and vim.b[buf].snacks_indent ~= false and vim.bo[buf].buftype == ""
      end,
    },
  },
}
