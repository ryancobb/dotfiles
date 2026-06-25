return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    keys = {
      {
        "<leader>E",
        function()
          local root = vim.fs.root(0, ".git") or vim.uv.cwd()
          require("neo-tree.command").execute({ toggle = true, dir = root })
        end,
        desc = "Explorer NeoTree (Git Root)",
      },
    },
  },
}
