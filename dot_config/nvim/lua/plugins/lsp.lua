return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        virtual_text = false,
      },
      servers = {
        marksman = {
          on_attach = function(client, bufnr)
            vim.diagnostic.enable(false, { bufnr = bufnr })
          end,
        },
        solargraph = {
          mason = false,
        },
        ruby_lsp = {
          mason = false,
          init_options = {
            addonSettings = {
              ["Ruby LSP Rails"] = {
                enablePendingMigrationsPrompt = false,
              },
            },
          },
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
