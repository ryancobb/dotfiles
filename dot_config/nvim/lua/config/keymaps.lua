-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

vim.keymap.del({ "t" }, "<esc><esc>")

map({ "n", "x" }, "q:", "<nop>")

map("n", "<leader>yf", '<cmd>let @+ = expand("%:~:.")<cr>', { desc = "filename" })
map("n", "<leader>yg", "<cmd>GetCurrentBranchLink<cr>", { desc = "git repo link" })

map("n", "<leader>sr", "<cmd>FzfLua resume<cr>", { desc = "Resume" })

map("n", "<leader>cf", function()
  require("conform").format({
    timeout_ms = 5000,
    lsp_fallback = true,
  })
end, { desc = "format" })

local smartsplits = require("smart-splits")

map("n", "<c-h>", function()
  smartsplits.move_cursor_left()
end)

map("n", "<c-j>", function()
  smartsplits.move_cursor_down()
end)

map("n", "<c-k>", function()
  smartsplits.move_cursor_up()
end)

map("n", "<c-l>", function()
  smartsplits.move_cursor_right()
end)

map("n", "<c-left>", function()
  smartsplits.resize_left()
end)

map("n", "<c-down>", function()
  smartsplits.resize_down()
end)

map("n", "<c-up>", function()
  smartsplits.resize_up()
end)

map("n", "<c-right>", function()
  smartsplits.resize_right()
end)
