return {
  "MeanderingProgrammer/render-markdown.nvim",
  opts = {
    checkbox = {
      checked = { scope_highlight = "@markup.strikethrough" },
      custom = {
        important = { raw = "[!]", rendered = " ", highlight = "DiagnosticError" },
        doing = { raw = "[-]", rendered = " ", highlight = "DiagnosticInfo" },
        next = { raw = "[/]", rendered = "󱦟 ", highlight = "DiagnosticWarn" },
      },
    },
  },
}
