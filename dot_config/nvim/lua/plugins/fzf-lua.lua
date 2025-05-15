return {
  "ibhagwan/fzf-lua",
  opts = {
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
  },
  keys = {
    { "<leader>sr", "<cmd>FzfLua resume<cr>", desc = "resume" },
    { "<leader>st", LazyVim.pick("live_grep"), desc = "text" },
  },
}
