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
      javascript = { "prettier" },
      ruby = { "rubocop" },
      vue = { "prettier" },
      markdown = { "markdownlint-cli2" },
    },
  },
}
