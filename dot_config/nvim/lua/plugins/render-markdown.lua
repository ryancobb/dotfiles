return {
  "MeanderingProgrammer/render-markdown.nvim",
  opts = {
    checkbox = {
      custom = {
        important = { raw = "[!]", rendered = " ", highlight = "DiagnosticError" },
        doing = { raw = "[-]", rendered = " " },
        next = { raw = "[/]", rendered = "󱦟 " },
      },
    },
  },
}
