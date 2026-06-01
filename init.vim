" ============================================================================
" Neovim Configuration
" Modernized for Neovim 0.11+ with native LSP
" ============================================================================
"
" PREREQUISITES:
" --------------
" Core:
"   - Neovim 0.11+
"   - Node.js (for Claude Code)
"   - tree-sitter CLI: npm install -g tree-sitter-cli (v0.26.1+)
"   - ripgrep: brew install ripgrep (for Telescope live_grep)
"   - fd: brew install fd (for Telescope find_files)
"
" Python Development:
"   - Python 3.12+
"   - pyenv or Poetry for virtual environments
"   - LSP servers: :MasonInstall pyright ruff (REQUIRED for gd, gr, K, etc.)
"   - Linters/Formatters: pip install black mypy ruff (in project venv)
"   - Debugger: pip install debugpy (in project venv)
"   - IMPORTANT: LSP servers via Mason (global), packages via venv (per-project)
"
" Git Integration:
"   - GitHub CLI: brew install gh
"   - Run: gh auth login (for Octo.nvim PR/issue management)
"
" AI Assistance:
"   - Avante: npm install -g @agentclientprotocol/claude-agent-acp
"             Requires Claude Pro subscription (uses ACP, not API credits)
"
" SETUP COMMANDS:
" ---------------
" 1. Install plugins: :PlugInstall
" 2. Install LSP servers (REQUIRED):
"    :MasonInstall pyright ruff          (Python - required for gd, gr, K)
"    Or use :Mason UI and press 'i' on server names
" 3. Install TreeSitter parsers: Auto-installed on first use
" 4. For Python: Run 'uv sync' or 'poetry install' in project (installs packages)
"

" ============================================================================
" Plugin Declarations
" ============================================================================

call plug#begin('~/.local/share/nvim/plugged')

" UI & Navigation
Plug 'nvim-lualine/lualine.nvim'           " Modern statusline (bottom bar)
Plug 'nvim-tree/nvim-web-devicons'         " File icons for UI plugins
Plug 'nvim-telescope/telescope.nvim'       " Fuzzy finder for files, grep, buffers
Plug 'nvim-lua/plenary.nvim'               " Lua utilities (required by telescope)
Plug 'williamboman/mason.nvim'             " Package manager for LSP/DAP/formatters
Plug 'williamboman/mason-lspconfig.nvim'   " Bridge between Mason and nvim-lspconfig

" Syntax & Parsing
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
" TreeSitter provides advanced syntax highlighting using tree-sitter parsers
" Configured for: Python, Lua, Vim, Markdown
" Note: Requires tree-sitter CLI v0.26.1+ (npm install -g tree-sitter-cli)

" LSP & Completion
Plug 'neovim/nvim-lspconfig'               " LSP configuration (intellisense, go-to-def)
Plug 'ray-x/lsp_signature.nvim'            " Auto signature help popup on '(' and ','
Plug 'hrsh7th/nvim-cmp'                    " Auto-completion engine
Plug 'hrsh7th/cmp-nvim-lsp'                " LSP completion source
Plug 'hrsh7th/cmp-buffer'                  " Buffer word completion source
Plug 'hrsh7th/cmp-path'                    " File path completion source
Plug 'L3MON4D3/LuaSnip'                    " Snippet engine
Plug 'saadparwaiz1/cmp_luasnip'            " Snippet completion source
" Active LSP servers:
"   - Python: Pyright (type checking) + Ruff (linting/formatting)

" Development Tools
Plug 'dense-analysis/ale'                  " Async linting & formatting
Plug 'preservim/nerdcommenter'             " Easy code commenting (<Space>cc)
Plug 'easymotion/vim-easymotion'           " Fast navigation jumps (<Space><Space>w)
Plug 'tpope/vim-fugitive'                  " Git integration (<Space>gs for status)
Plug 'pwntester/octo.nvim'                 " GitHub PR/issue management (requires: gh auth login)

" Debugging (nvim-dap)
Plug 'mfussenegger/nvim-dap'               " Debug Adapter Protocol client
Plug 'mfussenegger/nvim-dap-python'        " Python debugging adapter (uses debugpy)
Plug 'rcarriga/nvim-dap-ui'                " Visual debug UI (variables, stack, watches)
Plug 'nvim-neotest/nvim-nio'               " Async IO library (required by dap-ui)
Plug 'theHamsta/nvim-dap-virtual-text'     " Show variable values inline while debugging
" Python debugging: :PyDebug <script> - Auto-detects Poetry/uv projects
" Usage examples:
"   :PyDebug start          - Run poetry/uv script from pyproject.toml
"   :PyDebug script.py      - Debug a Python file directly
"   :PyDebug -m module.name - Debug a Python module

" Language Support
Plug 'lervag/vimtex'                       " LaTeX editing and compilation

" AI Assistance
Plug 'coder/claudecode.nvim'               " Claude Code terminal integration (uses Claude Pro)
" Claude Code Setup:
"   - Requires: claude CLI (npm install -g @anthropic-ai/claude-code)
"   - Auth: claude auth login (one-time)
"   - Toggle: <Space>ac



call plug#end()

" ============================================================================
" Core Vim Settings
" ============================================================================

let mapleader = " "
let maplocalleader = " "

filetype plugin indent on
set clipboard=unnamed

set showcmd
set cursorline
set wildmenu
set encoding=utf-8
set hlsearch
set incsearch
set splitbelow
set splitright
set number relativenumber

" Hybrid line numbering - toggle relative in insert mode
augroup numbertoggle
    autocmd!
    autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
    autocmd BufLeave,FocusLost,InsertEnter * set norelativenumber
augroup END

" ============================================================================
" Appearance
" ============================================================================

let python_highlight_all=1
syntax on
colorscheme monokain

" ============================================================================
" Language-Specific Settings
" ============================================================================

set foldmethod=indent
set foldlevel=99

augroup filetype_settings
    autocmd!
    autocmd FileType python,text,c setlocal
        \ tabstop=4 softtabstop=4 shiftwidth=4 textwidth=99
        \ expandtab autoindent fileformat=unix
    autocmd FileType markdown if &modifiable |
        \ setlocal tabstop=4 softtabstop=4 shiftwidth=4 textwidth=99
        \ expandtab autoindent fileformat=unix | endif
    autocmd FileType javascript,typescript,javascriptreact,typescriptreact setlocal
        \ tabstop=2 softtabstop=2 shiftwidth=2 textwidth=99
        \ expandtab autoindent fileformat=unix
augroup END

" ============================================================================
" Load Lua Plugin Configurations
" ============================================================================

lua require('telescope-config')    -- Fuzzy finder configuration
lua require('mason-config')        -- LSP/DAP package manager setup
lua require('lsp-config')          -- Python (Pyright, Ruff) LSP
lua require('octo-config')         -- GitHub integration
lua require('dap-config')          -- Python debugging (Poetry/uv auto-detection)
lua require('claudecode-config')   -- Claude Code terminal integration
lua require('lualine-config')      -- Statusline
lua require('treesitter-config')   -- Syntax highlighting (Python, Lua, Vim, Markdown)

" ============================================================================
" Plugin Configurations
" ============================================================================

" ALE - Linting & Formatting
let g:ale_linters = {'python': ['mypy', 'ruff']}
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'python': ['black', 'autoimport', 'reorder-python-imports', 'ruff']
\}
let g:ale_python_black_options = '-l 100'
let g:ale_fix_on_save = 1

" VimTeX
let g:vimtex_view_general_viewer = 'open -a Preview'
let g:vimtex_compiler_method = 'latexmk'

" Python Provider
let g:python3_host_prog = expand('~/.pyenv/shims/python3')

" NERDCommenter
let g:NERDCreateDefaultMappings = 1
let g:NERDSpaceDelims = 1
let g:NERDCompactSexyComs = 1
let g:NERDDefaultAlign = 'left'
let g:NERDCommentEmptyLines = 1
let g:NERDTrimTrailingWhitespace = 1
let g:NERDToggleCheckAllLines = 1

" ============================================================================
" Keybindings
" ============================================================================

" Telescope
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap <leader>fr <cmd>Telescope oldfiles<cr>
nnoremap <leader>fw <cmd>Telescope grep_string<cr>

" ALE
nmap <silent> <leader>aj :ALENext<cr>
nmap <silent> <leader>ak :ALEPrevious<cr>
map <leader>b :ALEFix black<CR>
map <leader>r :ALEFix ruff<CR>

" Git (vim-fugitive)
nnoremap <leader>gs :Git<CR>
nnoremap <leader>gc :Git commit<CR>
nnoremap <leader>gp :Git push<CR>
nnoremap <leader>gl :Git log<CR>
nnoremap <leader>gd :Gdiffsplit<CR>
nnoremap <leader>gb :Git blame<CR>

" EasyMotion
map <leader><leader>w <Plug>(easymotion-w)
map <leader><leader>b <Plug>(easymotion-b)
map <leader><leader>f <Plug>(easymotion-f)
map <leader><leader>s <Plug>(easymotion-s)

" Debugging (nvim-dap)
nnoremap <leader>db :DapToggleBreakpoint<CR>
nnoremap <leader>dc :DapContinue<CR>
nnoremap <leader>di :DapStepInto<CR>
nnoremap <leader>do :DapStepOut<CR>
nnoremap <leader>dn :DapStepOver<CR>
nnoremap <leader>dt :DapTerminate<CR>
nnoremap <leader>du :lua require('dap').up()<CR>
nnoremap <leader>dd :lua require('dap').down()<CR>
nnoremap <leader>dr :lua require('dapui').toggle()<CR>
nnoremap <leader>de :lua require('dapui').eval()<CR>
nnoremap <leader>dB :lua require('dapui').float_element('breakpoints', { enter = true })<CR>
nnoremap <leader>dC :lua require('dap').clear_breakpoints()<CR>
nnoremap [b :lua require('dap').list_breakpoints(); vim.cmd('cprev')<CR>
nnoremap ]b :lua require('dap').list_breakpoints(); vim.cmd('cnext')<CR>

" Claude Code
nnoremap <leader>ac :ClaudeCode<CR>

" Window Navigation
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Terminal
command! Vt :vsplit | :term
command! Ht :split | :term
tnoremap <C-Q> <C-\><C-N>

" Editing
inoremap uu <esc>
nnoremap <silent> <C-C> :nohl<CR><C-C>

" Search & Replace
noremap ;; :%s:::g<Left><Left><Left>
noremap ;' :%s:::gc<Left><Left><Left><Left>

" Visual mode search - preserves register content
vnoremap <silent> * :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy/<C-R><C-R>=substitute(
  \escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gV:call setreg('"', old_reg, old_regtype)<CR>
vnoremap <silent> # :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy?<C-R><C-R>=substitute(
  \escape(@", '?\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gV:call setreg('"', old_reg, old_regtype)<CR>
