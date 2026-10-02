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
  -- Installed on startup if missing; mason-lspconfig v2 then auto-enables them
  ensure_installed = { 'pyright', 'ruff', 'bashls', 'marksman' },
})
