return {
  "vim-test/vim-test",
  config = function()
    vim.g["test#strategy"] = "kitty"
  end,
  keys = {
    { "<leader>Tf", "<cmd>TestFile<cr>", desc = "Test file" },
    { "<leader>Tn", "<cmd>TestNearest<cr>", desc = "Test nearest" },
    { "<leader>Ts", "<cmd>TestSuite<cr>", desc = "Test suite" },
    { "<leader>Tl", "<cmd>TestLast<cr>", desc = "Test last" },
    { "<leader>Tv", "<cmd>TestVisit<cr>", desc = "Test visit" },
  }
}
