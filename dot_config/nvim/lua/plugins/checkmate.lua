return {
  "bngarren/checkmate.nvim",
  ft = "markdown", -- Lazy loads for Markdown files matching patterns in 'files'
  opts = {
    files = { "tasks.md" },
    todo_states = {
      unchecked = { marker = "[ ]" },
      checked = { marker = "[x]" },
    },
  },
}
