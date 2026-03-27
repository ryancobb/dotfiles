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
  group = vim.api.nvim_create_augroup("disable_indent_scope", { clear = true }),
  pattern = { "markdown" },
  callback = function()
    vim.b.miniindentscope_disable = true
  end,
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = { "*.hurl" },
  callback = function()
    vim.cmd("set filetype=hurl")
  end,
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = { "*.envrc" },
  callback = function()
    vim.cmd("set filetype=sh")
  end,
})

