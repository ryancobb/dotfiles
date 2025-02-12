return {
  "vim-test/vim-test",
  config = function()
    vim.g["test#strategy"] = "kitty"
  end,
  keys = {
    { "<leader>tf", "<cmd>TestFile<cr>", desc = "Test file" },
    { "<leader>tn", "<cmd>TestNearest<cr>", desc = "Test nearest" },
    { "<leader>ts", "<cmd>TestSuite<cr>", desc = "Test suite" },
    { "<leader>tl", "<cmd>TestLast<cr>", desc = "Test last" },
    { "<leader>tv", "<cmd>TestVisit<cr>", desc = "Test visit" },
  }
}
