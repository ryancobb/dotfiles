return {
  "ibhagwan/fzf-lua",
  opts = {
    defaults = {
      formatter = { "path.filename_first", 2 },
    },
    files = {
      fzf_opts = {
        ["--history"] = vim.fn.stdpath("data") .. "/fzf-lua-files-history",
      },
    },
    grep = {
      fzf_opts = {
        ["--history"] = vim.fn.stdpath("data") .. "/fzf-lua-grep-history",
      },
    },
    marks = {
      marks = "%a",
    },
    winopts = {
      preview = {
        flip_columns = 120,
      },
    },
  },
  keys = {
    { "<leader>st", LazyVim.pick("live_grep"), desc = "text" },
    { "<leader>gc", "<cmd>FzfLua git_branches<cr>", desc = "checkout" },
    { "<leader>fr", "<cmd>FzfLua oldfiles cwd_only=true<cr>", desc = "recent" },
    { "<leader>gs", "<cmd>FzfLua git_status winopts.fullscreen=true winopts.preview.horizontal='right:80%'<CR>", desc = "Status" },
    { "<leader>gl", "<cmd>FzfLua git_commits winopts.fullscreen=true winopts.preview.horizontal='right:80%'<CR>", desc = "Commits" },
  },
}
