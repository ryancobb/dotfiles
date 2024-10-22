return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      javascript = { "prettier" },
      ruby = {
        command = "bundle",
        args = "exec rubocop",
      },
      vue = { "prettier" },
      markdown = { "markdownlint-cli2" }
    },
  },
}
