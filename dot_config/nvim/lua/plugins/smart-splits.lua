return {
  {
    "mrjones2014/smart-splits.nvim",
    lazy = false,
    opts = {
      at_edge = "stop",
    },
    keys = {
      {
        "<c-h>",
        function()
          require("smart-splits").move_cursor_left()
        end,
      },
      {
        "<c-j>",
        function()
          require("smart-splits").move_cursor_down()
        end,
      },
      {
        "<c-k>",
        function()
          require("smart-splits").move_cursor_up()
        end,
      },
      {
        "<c-l>",
        function()
          require("smart-splits").move_cursor_right()
        end,
      },
      {
        "<C-S-h>",
        function()
          require("smart-splits").resize_left()
        end,
      },
      {
        "<C-S-j>",
        function()
          require("smart-splits").resize_down()
        end,
      },
      {
        "<C-S-k>",
        function()
          require("smart-splits").resize_up()
        end,
      },
      {
        "<C-S-l>",
        function()
          require("smart-splits").resize_right()
        end,
      },
      {
        "<C-M-S-h>",
        function()
          require("smart-splits").swap_buf_left()
        end,
        desc = "Swap window left",
      },
      {
        "<C-M-S-j>",
        function()
          require("smart-splits").swap_buf_down()
        end,
        desc = "Swap window down",
      },
      {
        "<C-M-S-k>",
        function()
          require("smart-splits").swap_buf_up()
        end,
        desc = "Swap window up",
      },
      {
        "<C-M-S-l>",
        function()
          require("smart-splits").swap_buf_right()
        end,
        desc = "Swap window right",
      },
    },
  },
}
