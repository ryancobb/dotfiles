return {
  "bngarren/checkmate.nvim",
  ft = "markdown", -- Lazy loads for Markdown files matching patterns in 'files'
  config = function()
    require("checkmate").setup({
      files = { "tasks.md" },
      todo_states = {
        -- Built-in states (cannot change markdown or type)
        unchecked = { marker = "[ ]" },
        checked = { marker = "[x]" },

        -- Custom states
        in_progress = {
          marker = "[.]",
          markdown = ".", -- Saved as `- [.]`
          type = "incomplete", -- Counts as "not done"
          order = 50,
        },
        cancelled = {
          marker = "[c]",
          markdown = "c", -- Saved as `- [c]`
          type = "complete", -- Counts as "done"
          order = 2,
        },
        on_hold = {
          marker = "[/]",
          markdown = "/", -- Saved as `- [/]`
          type = "inactive", -- Ignored in counts
          order = 100,
        },
      },
      metadata = {
        started = {
          aliases = { "init" },
          style = { link = "Conditional" },
          get_value = function()
            return tostring(os.date("%m/%d/%y %H:%M"))
          end,
          key = "<leader>Ts",
          sort_order = 20,
        },
        done = {
          aliases = { "completed", "finished" },
          style = { link = "DiagnosticOk" },
          get_value = function()
            return tostring(os.date("%m/%d/%y %H:%M"))
          end,
          key = "<leader>Td",
          on_add = function(todo_item)
            require("checkmate").set_todo_item(todo_item, "checked")
          end,
          on_remove = function(todo_item)
            require("checkmate").set_todo_item(todo_item, "unchecked")
          end,
          sort_order = 30,
        },
      },
    })

    vim.schedule(function()
      vim.api.nvim_set_hl(0, "CheckmateUncheckedMainContent", {})
    end)
  end,
}
