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

    -- Invert root/cwd: lowercase = cwd, uppercase = root
    { "<leader><space>", LazyVim.pick("files", { root = false }), desc = "Find Files (cwd)" },
    { "<leader>/", LazyVim.pick("live_grep", { root = false }), desc = "Grep (cwd)" },
    { "<leader>ff", LazyVim.pick("files", { root = false }), desc = "Find Files (cwd)" },
    { "<leader>fF", LazyVim.pick("files"), desc = "Find Files (Root Dir)" },
    { "<leader>sg", LazyVim.pick("live_grep", { root = false }), desc = "Grep (cwd)" },
    { "<leader>sG", LazyVim.pick("live_grep"), desc = "Grep (Root Dir)" },
    { "<leader>sw", LazyVim.pick("grep_cword", { root = false }), desc = "Word (cwd)" },
    { "<leader>sW", LazyVim.pick("grep_cword"), desc = "Word (Root Dir)" },
    { "<leader>sw", LazyVim.pick("grep_visual", { root = false }), mode = "x", desc = "Selection (cwd)" },
    { "<leader>sW", LazyVim.pick("grep_visual"), mode = "x", desc = "Selection (Root Dir)" },
  },
}
