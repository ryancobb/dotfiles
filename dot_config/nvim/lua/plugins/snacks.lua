return {
  "folke/snacks.nvim",
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
