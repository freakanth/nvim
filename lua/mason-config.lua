-- Mason setup for managing LSP servers, formatters, and linters

require('mason').setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗"
    }
  }
})

require('mason-lspconfig').setup({
  -- Ensure these servers are installed
  ensure_installed = {},
  automatic_installation = false,
})
