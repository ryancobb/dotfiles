return {
  "MeanderingProgrammer/render-markdown.nvim",
  opts = {
    preset = "lazy",
    code = {
      sign = true,
    },
    heading = {
      sign = false,
    },
    checkbox = {
      enabled = true,
      checked = { icon = "✔" },
      unchecked = { icon = "▢" },
      custom = {
        in_progress = {
          raw = "[.]",
          rendered = "◐",
          highlight = "Conditional",
        },
        cancelled = {
          raw = "[c]",
          rendered = "✗",
          highlight = "Error",
        },
        on_hold = {
          raw = "[/]",
          rendered = "⏸",
          highlight = "Type",
        },
      },
    },
    indent = {
      enabled = true,
      skip_heading = true,
    },
  },
}
