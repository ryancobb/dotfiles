return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        virtual_text = false,
      },
      servers = {
        solargraph = {
          enabled = false,
          mason = false,
        },
        ruby_lsp = {
          enabled = true,
          mason = false,
        },
      },
    },
  },
}
