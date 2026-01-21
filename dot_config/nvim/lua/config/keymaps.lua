-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

vim.keymap.del({ "n" }, "<S-h>")
vim.keymap.del({ "n" }, "<S-l>")

map({ "n", "x" }, "q", "<nop>")

map("n", "<leader>yf", function()
  local expr = "%:~:."
  vim.fn.setreg("+", vim.fn.expand(expr))
  vim.notify("Copied: " .. vim.fn.expand(expr))
end, { desc = "filename (relative path)" })

map("n", "<leader>yF", function()
  local expr = "%:p"
  vim.fn.setreg("+", vim.fn.expand(expr))
  vim.notify("Copied: " .. vim.fn.expand(expr))
end, { desc = "filename (full path)" })

vim.keymap.set("n", "<leader>dd", function()
  local date = os.date("%Y-%m-%d")
  local filepath = vim.fn.expand("~/Projects/vaults/work/dailies/" .. date .. "-daily-plan.md")
  vim.cmd("edit " .. filepath)
end, { desc = "Open today's daily plan" })

vim.keymap.set("n", "<leader>dy", function()
  local yesterday = os.time() - 86400 -- 86400 seconds = 1 day
  local date = os.date("%Y-%m-%d", yesterday)
  local filepath = vim.fn.expand("~/Projects/vaults/work/dailies/" .. date .. "-daily-plan.md")
  vim.cmd("edit " .. filepath)
end, { desc = "Open yesterday's daily plan" })
