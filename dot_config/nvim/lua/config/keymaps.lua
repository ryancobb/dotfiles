-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

vim.keymap.del({ "n" }, "<S-h>")
vim.keymap.del({ "n" }, "<S-l>")

map({ "n", "x" }, "q:", "<nop>")

map("n", "<leader>yf", '<cmd>let @+ = expand("%:~:.")<cr>', { desc = "filename" })
