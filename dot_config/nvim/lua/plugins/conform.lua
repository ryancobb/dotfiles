return {
  "stevearc/conform.nvim",
  opts = {
    formatters = {
      rubocop = {
        command = "bundle",
        args = {
          "exec",
          "rubocop",
          "--server",
          "-a",
          "-f",
          "quiet",
          "--stderr",
          "--stdin",
          "$FILENAME",
        },
      },
    },
    formatters_by_ft = {
      vue = { "prettier" },
    },
  },
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format({
          timeout_ms = 5000,
          lsp_fallback = true,
        })
      end,
      desc = "format",
    },
  },
}
