-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Override LazyVim's wrap_spell autocmd to use persisted wrap state
-- Original forces wrap=true on text filetypes; we persist wrap independently
vim.api.nvim_create_augroup("lazyvim_wrap_spell", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = "lazyvim_wrap_spell",
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.spell = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("markdown_settings", { clear = true }),
  pattern = { "markdown" },
  callback = function()
    vim.b.miniindentscope_disable = true
    local wrap = require("lib.wrap")
    wrap.apply(wrap.read())
  end,
})

-- Snacks' statuscolumn draws the closed-fold chevron with the Folded highlight,
-- whose fg is usually the same grey as LineNr, so the marker vanishes next to
-- the line number. Borrow CursorLineNr's fg instead: themes reserve it for the
-- one gutter element meant to stand out. Reads from the active theme so this
-- survives a colorscheme switch.
local function highlight_fold_marker()
  local accent = vim.api.nvim_get_hl(0, { name = "CursorLineNr", link = false })
  if not accent.fg then
    return
  end
  local folded = vim.api.nvim_get_hl(0, { name = "Folded", link = false })
  folded.fg = accent.fg
  vim.api.nvim_set_hl(0, "Folded", folded)
end

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("fold_marker", { clear = true }),
  callback = highlight_fold_marker,
})

-- This file loads on VeryLazy, by which point the colorscheme has already applied
highlight_fold_marker()

-- Emptying snacks' statuscolumn `left` list isn't enough to reclaim its width;
-- the slot still pads to two cells. Only this buffer-local flag drops it, and
-- snacks reads it per buffer with no global fallback. Nvim caches the column
-- width per window and a buffer variable does not invalidate it, so the redraw
-- is load-bearing rather than cosmetic.
local function drop_statuscolumn_left(buf)
  vim.b[buf].snacks_statuscolumn_left = false
  pcall(vim.api.nvim__redraw, { buf = buf, statuscolumn = true })
end

vim.api.nvim_create_autocmd("BufWinEnter", {
  group = vim.api.nvim_create_augroup("statuscolumn_left", { clear = true }),
  callback = function(ev)
    drop_statuscolumn_left(ev.buf)
  end,
})

-- The startup buffer's BufWinEnter fires before VeryLazy loads this file, and
-- its window has already sized its column by now, so catch up on what exists.
for _, buf in ipairs(vim.api.nvim_list_bufs()) do
  drop_statuscolumn_left(buf)
end

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = { "*.envrc" },
  callback = function()
    vim.bo.filetype = "sh"
  end,
})
