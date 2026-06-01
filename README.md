# Neovim Configuration

Neovim 0.11+ configuration aimed primarily at Python development, with GitHub integration, a full debugging stack, and Claude AI assistance.

A detailed writeup is available at [cherla.org](https://cherla.org/posts/my-neovim-configuration/).

## Features

- **LSP** — Pyright (type checking) + Ruff (linting/formatting) via Neovim 0.11's native `vim.lsp.config.*` API
- **Debugging** — nvim-dap with a custom `:PyDebug` command that auto-detects Poetry and uv projects
- **Completion** — nvim-cmp with LSP, buffer, and path sources; LuaSnip for snippets
- **Fuzzy finding** — Telescope for files, live grep, buffers, and help
- **GitHub** — Octo.nvim for PR and issue management without leaving the editor
- **AI** — claudecode.nvim integrating Claude Code CLI (Claude Pro subscription)
- **Syntax** — TreeSitter for Python, Lua, Vimscript, Markdown

## Prerequisites

**Core**
- Neovim 0.11+
- [ripgrep](https://github.com/BurntSushi/ripgrep) — for Telescope live grep
- [fd](https://github.com/sharkdp/fd) — for Telescope file finding
- Node.js — for Claude Code

**Python**
- Python 3.12+
- [pyenv](https://github.com/pyenv/pyenv), [Poetry](https://python-poetry.org/), or [uv](https://github.com/astral-sh/uv)
- `pip install debugpy` in your project virtualenv (for debugging)

**GitHub integration**
- [GitHub CLI](https://cli.github.com/) — `brew install gh && gh auth login`

**AI assistance**
- [Claude Code CLI](https://github.com/anthropics/claude-code) — `npm install -g @anthropic-ai/claude-code && claude auth login`
- Claude Pro subscription

**Fonts**
- A [Nerd Font](https://www.nerdfonts.com/) — recommended: `brew install --cask font-jetbrains-mono-nerd-font`

## Setup

```bash
# 1. Clone
git clone git@github.com:freakanth/nvim.git ~/.config/nvim

# 2. Install plugins
nvim +PlugInstall +qall

# 3. Install LSP servers (inside nvim)
:MasonInstall pyright ruff
```

## Structure

```
init.vim              # Entry point: plugins, settings, keybindings
lua/
  mason-config.lua    # LSP/DAP package manager
  lsp-config.lua      # Pyright + Ruff, Python path detection
  dap-config.lua      # Debugging, :PyDebug command
  telescope-config.lua
  octo-config.lua     # GitHub PR/issue integration
  claudecode-config.lua
  lualine-config.lua  # Statusline
  treesitter-config.lua
```

## License

MIT
