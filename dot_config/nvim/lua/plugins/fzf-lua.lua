return {
  "ibhagwan/fzf-lua",
  opts = {
    defaults = {
      formatter = "path.filename_first",
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
      marks = "%a"
    },
    winopts = {
      preview = {
        flip_columns = 120,
      },
    },
  },
  keys = {
    -- { "<leader>sr", "<cmd>FzfLua resume<cr>", desc = "resume" },
    { "<leader>st", LazyVim.pick("live_grep"), desc = "text" },
    { "<leader>gc", "<cmd>FzfLua git_branches<cr>", desc = "checkout" },
  },
}
