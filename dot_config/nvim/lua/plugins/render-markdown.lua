return {
  "MeanderingProgrammer/render-markdown.nvim",
  opts = {
    checkbox = {
      checked = { scope_highlight = "@markup.strikethrough" },
      custom = {
        important = { raw = "[!]", rendered = " ", highlight = "DiagnosticError" },
        doing = { raw = "[-]", rendered = " ", highlight = "DiagnosticInfo" },
        waiting = { raw = "[w]", rendered = "󱦟 ", highlight = "DiagnosticWarn" },
        next = { raw = "[/]", rendered = "󰒭 ", highlight = "DiagnosticHint" },
        review = { raw = "[r]", rendered = " ", highlight = "DiagnosticHint" },
      },
    },
  },
}
