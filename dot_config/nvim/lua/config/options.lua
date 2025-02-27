-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt

vim.g.autoformat = false
vim.g.editorconfig = false

vim.g.lazyvim_ruby_lsp = "ruby_lsp"
vim.g.lazyvim_ruby_formatter = "rubocop"

opt.cursorline = false
opt.fillchars:append({ diff = "╱" })
opt.laststatus = 3
opt.lcs = { space = "·" }
opt.list = true
opt.relativenumber = false
opt.title = true
opt.titlestring = '%{substitute(getcwd(), $HOME, "~", "g")} - nvim'
opt.wrap = false
