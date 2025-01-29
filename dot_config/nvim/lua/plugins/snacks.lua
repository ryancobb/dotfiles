return {
  "folke/snacks.nvim",
  keys = {
    {
      "<leader>fa",
      function()
        local file_name_no_ext, _ = vim.fn.expand("%:t:r"):gsub("_spec", "")
        local relative_path, _ = vim.fn.fnamemodify(vim.fn.expand("%"), ":~:.")

        Snacks.picker.files({ args = { file_name_no_ext }, exclude = { relative_path } })
      end,
      desc = "alternate",
    },
  },
  opts = function(_, opts)
    if LazyVim.has("trouble.nvim") then
      return vim.tbl_deep_extend("force", opts or {}, {
        dashboard = { enabled = false },
        picker = {
          actions = require("trouble.sources.snacks").actions,
          matcher = { frecency = true },
          formatters = { file = { truncate = 80 } },
          win = {
            input = {
              keys = {
                ["<c-t>"] = {
                  "trouble_open",
                  mode = { "n", "i" },
                },
              },
            },
          },
        },
      })
    end
  end,
}
