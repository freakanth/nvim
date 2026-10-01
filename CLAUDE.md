# CLAUDE.md

Neovim 0.11+ configuration with native LSP for Python (Poetry/uv). See `init.vim` for prerequisites and setup.

## Architecture

- **`init.vim`**: Entry point - plugin declarations, settings, keybindings
- **`lua/`**: Modular configs (mason, lsp, dap, telescope, octo, claudecode, lualine, treesitter)
- **Load order matters**: mason before lsp

## Python Development

### Python Path Detection (Poetry + uv support)

IMPORTANT: `get_python_path()` in both `lsp-config.lua` and `dap-config.lua` auto-detects:
1. Poetry projects (`poetry.lock`) → `poetry env info --path`
2. uv projects → `.venv/bin/python`
3. Fallback → pyenv → system python3

### Debugging

**Command**: `:PyDebug <script|file|module>`
- Auto-detects Poetry (`poetry run`) vs uv (`uv run`)
- Looks up scripts in `[tool.poetry.scripts]` or `[project.scripts]`
- Examples: `:PyDebug start`, `:PyDebug script.py`, `:PyDebug -m module.name`
- Key: `<Space>dt` to terminate

### LSP

- Uses **Neovim 0.11+ native API** (`vim.lsp.config.*` not lspconfig)
- Servers: Pyright + Ruff (format on save enabled)
- ALE runs parallel for mypy/black (fix on save)

## TreeSitter Quirks

**Diff syntax fix**: DiffAdd/DiffText use `fg = 'NONE'` so syntax colors show in Octo PR reviews (not gray text)

**Octo buffers**: BufEnter autocmd forces TreeSitter on `octo://` buffers since Octo doesn't emit FileType events

## External Dependencies

- **Nerd Font**: Required for icons in Octo, nvim-web-devicons, etc. Install: `brew install --cask font-jetbrains-mono-nerd-font` and set in Terminal.app preferences
- **tree-sitter CLI**: `npm install -g tree-sitter-cli` (v0.26.1+)
- **GitHub CLI**: `gh auth login` for Octo
- **Claude Code CLI**: `npm install -g @anthropic-ai/claude-code` + `claude auth login` for claudecode.nvim

## Common Commands

- `:PlugInstall` / `:PlugUpdate` - Manage plugins
- `:Mason` - Install LSP servers (press `i` on server name)
- `:LspInfo` - Check LSP status
- `:PyDebug <script>` - Debug Python (Poetry/uv aware)
- `<Space>ac` - Toggle Claude Code terminal panel
- `<Space>dt` - Terminate debugger

## Style Guidelines

- Python: 100 char lines, 4-space indent
- NEVER use deprecated lspconfig patterns - always use `vim.lsp.config.*` API
