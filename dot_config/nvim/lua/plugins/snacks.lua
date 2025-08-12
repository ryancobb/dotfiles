return {
  "folke/snacks.nvim",
  opts = {
    scratch = {
      win = {
        style = "scratch",
        relative = "editor",
        position = "right",
      },
    },
    dashboard = { enabled = false },
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
