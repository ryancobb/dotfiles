return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown" },
  keys = {
    {
      "<leader>uM",
      function()
        local state = require("render-markdown.state")
        local new_val = not state.config.anti_conceal.enabled
        -- Update root config and all cached buffer configs
        state.config.anti_conceal.enabled = new_val
        -- Update concealcursor: '' allows anti-conceal to work, 'nvic' hides in all modes
        local cc = new_val and "" or "nvic"
        state.config.win_options.concealcursor.rendered = cc
        for _, config in pairs(state.cache) do
          config.anti_conceal.enabled = new_val
          config.win_options.concealcursor.rendered = cc
        end
        -- Re-render to apply
        vim.cmd("RenderMarkdown buf_disable")
        vim.cmd("RenderMarkdown buf_enable")
        vim.notify("Anti-conceal: " .. (new_val and "on" or "off"))
      end,
      desc = "Toggle render-markdown anti-conceal",
    },
  },
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
