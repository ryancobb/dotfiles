return {
  "MeanderingProgrammer/render-markdown.nvim",
  opts = {
    checkbox = {
      custom = {
        important = { raw = "[!]", rendered = " ", highlight = "DiagnosticError" },
        doing = { raw = "[-]", rendered = " ", highlight = "DiagnosticInfo" },
        next = { raw = "[/]", rendered = "󱦟 ", highlight = "DiagnosticWarn" },
      },
    },
  },
}
