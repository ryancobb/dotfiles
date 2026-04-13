return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown" },
  keys = {
    {
      "<leader>um",
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
  config = function(_, opts)
    require("render-markdown").setup(opts)
    local rm = require("render-markdown")
    local state = require("render-markdown.state")
    Snacks.toggle({
      name = "Render Markdown",
      get = rm.get,
      set = function(enabled)
        if not enabled then
          -- Reset anti-conceal before rm.set so the debounced update uses clean values
          state.config.anti_conceal.enabled = false
          state.config.win_options.concealcursor.rendered = "nvic"
          for _, config in pairs(state.cache) do
            config.anti_conceal.enabled = false
            config.win_options.concealcursor.rendered = "nvic"
          end
        end
        rm.set(enabled)
      end,
    }):map("<leader>uM")
  end,
  opts = {
    preset = "lazy",
    anti_conceal = { enabled = false },
    win_options = {
      conceallevel = { default = 0, rendered = 2 },
    },
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
          raw = "[/]",
          rendered = "◐",
          highlight = "Conditional",
        },
        deferred = {
          raw = "[>]",
          rendered = "⏭",
          highlight = "Comment",
        },
        needs_review = {
          raw = "[?]",
          rendered = "❓",
          highlight = "DiagnosticWarn",
        },
      },
    },
    bullet = {
      icons = { "●", "▸", "◆", "‣" },
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
