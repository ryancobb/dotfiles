return {
  "bngarren/checkmate.nvim",
  ft = "markdown", -- Lazy loads for Markdown files matching patterns in 'files'
  opts = function()
    -- local palette = require("nightfox.palette").load("nordfox")

    return {
      files = { "*.md" },
      todo_states = {
        unchecked = { marker = "[ ]" },
        checked = { marker = "[x]" },
      },
    }
  end,
  config = function(_, opts)
    require("checkmate").setup(opts)

    vim.schedule(function()
      vim.api.nvim_set_hl(0, "CheckmateUncheckedMainContent", {})
      vim.api.nvim_set_hl(0, "CheckmateUncheckedAdditionalContent", {})
    end)
  end,
}
