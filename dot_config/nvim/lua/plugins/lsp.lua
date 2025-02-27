return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        virtual_text = false,
      },
      servers = {
        solargraph = {
          mason = false,
        },
        ruby_lsp = {
          mason = false,
        },
        rubocop = {
          mason = false,
          -- See: https://docs.rubocop.org/rubocop/usage/lsp.html
          cmd = { "bundle", "exec", "rubocop", "--lsp" },
        },
      },
    },
  },
}
