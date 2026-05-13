-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

vim.keymap.del({ "n" }, "<S-h>")
vim.keymap.del({ "n" }, "<S-l>")

map({ "n", "x" }, "q", "<nop>")

map("n", "<leader>uw", function() require("lib.wrap").toggle() end, { desc = "Toggle Word Wrap (persistent)" })

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

local function monday_of(time)
  local wday = os.date("*t", time).wday -- 1=Sun..7=Sat
  local offset = (wday - 2 + 7) % 7
  return time - offset * 86400
end

map("n", "<leader>fd", function()
  local now = os.time()
  local date = os.date("%Y-%m-%d", now)
  local monday = os.date("%Y-%m-%d", monday_of(now))
  local filepath = vim.fn.expand("~/Projects/vaults/work/weeklies/" .. monday .. "/" .. date .. "-daily-plan.md")
  vim.cmd("edit " .. filepath)
end, { desc = "Open today's daily plan" })
