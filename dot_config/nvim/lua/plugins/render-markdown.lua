return {
  "MeanderingProgrammer/render-markdown.nvim",
  opts = {
    preset = "lazy",
    anti_conceal = { enabled = false },
    code = {
      sign = false,
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
        deferred = {
          raw = "[>]",
          rendered = "⏭",
          highlight = "Comment",
        },
      },
    },
    indent = {
      enabled = true,
      skip_heading = true,
    },
    inline_highlight = {
      custom = {
        epic = { prefix = "e", highlight = "@text.strong" },
        issue = { prefix = "i", highlight = "NeoTreeRootName" },
        mr = { prefix = "m", highlight = "MatchParen" },
      }
    }
  },
}
