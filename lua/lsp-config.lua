-- LSP Configuration for Python (Neovim 0.11+ API)

-- Setup completion capabilities
local cmp = require('cmp')
local cmp_nvim_lsp = require('cmp_nvim_lsp')
local capabilities = cmp_nvim_lsp.default_capabilities()

-- Configure nvim-cmp for autocompletion
cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
    { name = 'path' },
  })
})

-- LSP keybindings and settings
local on_attach = function(client, bufnr)
  local opts = { buffer = bufnr, noremap = true, silent = true }

  -- Keybindings
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
  vim.keymap.set('n', 'gV', '<cmd>vsplit | lua vim.lsp.buf.definition()<CR>', opts)  -- definition in vertical split
  vim.keymap.set('n', 'gS', '<cmd>split | lua vim.lsp.buf.definition()<CR>', opts)   -- definition in horizontal split
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
  vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)

  -- Signature help auto-popup on '(' and ','
  require('lsp_signature').on_attach({
    bind = true,
    handler_opts = { border = 'rounded' },
    hint_enable = false,  -- no inline hint, just the float
  }, bufnr)

  -- Format on save (optional - can disable if you prefer manual formatting)
  if client.server_capabilities.documentFormattingProvider then
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ async = false })
      end,
    })
  end
end

-- Function to find Python interpreter (poetry, uv venv, or pyenv)
local function get_python_path()
  -- Check for Poetry project (poetry.lock exists)
  local poetry_lock = vim.fn.getcwd() .. '/poetry.lock'
  if vim.fn.filereadable(poetry_lock) == 1 then
    -- Get Poetry venv path
    local poetry_venv = vim.fn.system('poetry env info --path 2>/dev/null'):gsub('\n', '')
    if vim.v.shell_error == 0 and poetry_venv ~= '' then
      local poetry_python = poetry_venv .. '/bin/python'
      if vim.fn.executable(poetry_python) == 1 then
        return poetry_python
      end
    end
  end

  -- Check for uv venv in current directory
  local venv_path = vim.fn.getcwd() .. '/.venv/bin/python'
  if vim.fn.executable(venv_path) == 1 then
    return venv_path
  end

  -- Fall back to pyenv python
  local pyenv_python = vim.fn.exepath('python3')
  if pyenv_python ~= '' then
    return pyenv_python
  end

  -- Last resort: system python
  return 'python3'
end

-- Configure Pyright using modern Neovim 0.11+ API
vim.lsp.config.pyright = {
  cmd = { 'pyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile', '.git' },
  settings = {
    python = {
      pythonPath = get_python_path(),
      analysis = {
        typeCheckingMode = "basic",
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
      }
    }
  },
  capabilities = capabilities,
  on_attach = on_attach,
}

-- Configure Ruff using modern Neovim 0.11+ API (note: 'ruff' not 'ruff_lsp')
vim.lsp.config.ruff = {
  cmd = { 'ruff', 'server' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'ruff.toml', '.ruff.toml', '.git' },
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    -- Disable hover in favor of Pyright
    client.server_capabilities.hoverProvider = false
    on_attach(client, bufnr)
  end,
}

-- Enable LSP servers for Python files
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'python',
  callback = function(args)
    vim.lsp.enable('pyright')
    vim.lsp.enable('ruff')
  end,
})
