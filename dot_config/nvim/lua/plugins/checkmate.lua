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
        deferred = {
          marker = "[>]",
          markdown = ">",
          type = "complete",
        },
      },
      style = {
        CheckmateDeferredMainContent = { link = "CheckmateCheckedMainContent" },
        CheckmateDeferredAdditionalContent = { link = "CheckmateCheckedAdditionalContent" },
      },
    }
  end,
  config = function(_, opts)
    require("checkmate").setup(opts)

    vim.schedule(function()
      vim.api.nvim_set_hl(0, "CheckmateUncheckedMainContent", {})
      vim.api.nvim_set_hl(0, "CheckmateUncheckedAdditionalContent", {})
    end)

    vim.keymap.set("n", "<leader>t>", function()
      require("checkmate").toggle("deferred")
    end, { desc = "Toggle deferred" })
  end,
}
