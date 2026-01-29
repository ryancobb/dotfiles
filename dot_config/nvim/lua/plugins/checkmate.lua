return {
  "bngarren/checkmate.nvim",
  ft = "markdown", -- Lazy loads for Markdown files matching patterns in 'files'
  opts = function()
    -- local palette = require("nightfox.palette").load("nordfox")

    return {
      files = { "*.md" },
      keys = {
        ["<leader>tt"] = { rhs = "<cmd>Checkmate toggle<CR>", desc = "Toggle todo item", modes = { "n", "v" } },
        ["<leader>tc"] = { rhs = "<cmd>Checkmate check<CR>", desc = "Set todo item as checked", modes = { "n", "v" } },
        ["<leader>tu"] = { rhs = "<cmd>Checkmate uncheck<CR>", desc = "Set todo item as unchecked", modes = { "n", "v" } },
        ["<leader>t="] = { rhs = "<cmd>Checkmate cycle_next<CR>", desc = "Cycle todo to next state", modes = { "n", "v" } },
        ["<leader>t-"] = { rhs = "<cmd>Checkmate cycle_previous<CR>", desc = "Cycle todo to previous state", modes = { "n", "v" } },
        ["<leader>tn"] = { rhs = "<cmd>Checkmate create<CR>", desc = "Create todo item", modes = { "n", "v" } },
        ["<leader>tr"] = { rhs = "<cmd>Checkmate remove<CR>", desc = "Remove todo marker", modes = { "n", "v" } },
        ["<leader>tR"] = { rhs = "<cmd>Checkmate remove_all_metadata<CR>", desc = "Remove all metadata", modes = { "n", "v" } },
        ["<leader>ta"] = { rhs = "<cmd>Checkmate archive<CR>", desc = "Archive completed todos", modes = { "n" } },
        ["<leader>tF"] = { rhs = "<cmd>Checkmate select_todo<CR>", desc = "Pick a todo", modes = { "n" } },
        ["<leader>tv"] = { rhs = "<cmd>Checkmate metadata select_value<CR>", desc = "Update metadata value", modes = { "n" } },
        ["<leader>t]"] = { rhs = "<cmd>Checkmate metadata jump_next<CR>", desc = "Next metadata tag", modes = { "n" } },
        ["<leader>t["] = { rhs = "<cmd>Checkmate metadata jump_previous<CR>", desc = "Previous metadata tag", modes = { "n" } },
      },
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
      metadata = {
        priority = { key = "<leader>tp" },
        started = { key = "<leader>ts" },
        done = { key = "<leader>td" },
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
