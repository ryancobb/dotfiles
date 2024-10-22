return {
  { "RRethy/nvim-treesitter-endwise" },
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "RRethy/nvim-treesitter-endwise",
      "hiphish/rainbow-delimiters.nvim",
    },
    opts = function(_, opts)
      opts.indent = { enable = false }
      opts.endwise = { enable = true }
      opts.matchup = { enable = true }
      opts.textobjects = {
        move = {
          enable = false,
        },
      }
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    opts = {
      max_lines = 0,
    },
    keys = {
      {
        "[c",
        function()
          require("treesitter-context").go_to_context(vim.v.count1)
        end,
        "jump to context",
      },
    },
  },
}
