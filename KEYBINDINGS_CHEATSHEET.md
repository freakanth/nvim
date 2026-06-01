# Neovim Keybindings Cheatsheet

**Your Leader Key:** `Space`

---

## 🔍 Telescope (Fuzzy Finder) - NEW!

**Prerequisites:** `ripgrep` and `fd` must be installed:
```bash
brew install ripgrep fd
```

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<Space>ff` | Find Files | Search files in current directory (respects .gitignore) |
| `<Space>fg` | Live Grep | Search text across all files (requires ripgrep) |
| `<Space>fb` | Find Buffers | List and switch between open buffers |
| `<Space>fh` | Find Help | Search Neovim help documentation |
| `<Space>fr` | Recent Files | List recently opened files |
| `<Space>fw` | Find Word | Grep for word under cursor |

**Inside Telescope Popup:**
- `<Ctrl-n>` or `<Down>` - Next item
- `<Ctrl-p>` or `<Up>` - Previous item
- `<Enter>` - Open file
- `<Ctrl-x>` - Open in horizontal split
- `<Ctrl-v>` - Open in vertical split
- `<Ctrl-t>` - Open in new tab
- `<Esc>` - Close Telescope
- `<Ctrl-c>` - Close Telescope

---

## 🧠 LSP (Language Server Protocol) - NEW!

**Prerequisites:** LSP servers must be installed via Mason:
```vim
:MasonInstall pyright ruff     " Python (REQUIRED for gd, gr, K)
```
**Common issue:** If `gd` takes you to import instead of definition, check:
1. LSP servers installed? Run `:LspInfo` to verify
2. Packages installed in venv? Run `uv sync` or `poetry install` in project

### Navigation

| Keybinding | Action | Description |
|------------|--------|-------------|
| `gd` | Go to Definition | Jump to where a function/class is defined |
| `gD` | Go to Declaration | Jump to declaration |
| `gV` | Definition in Vsplit | Open definition in vertical split |
| `gS` | Definition in Split | Open definition in horizontal split |
| `gr` | Find References | Show all places where symbol is used |
| `gi` | Go to Implementation | Jump to implementation |
| `K` | Hover Documentation | Show function signature and docstring |

### Code Actions

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<Space>rn` | Rename Symbol | Rename variable/function across entire project |
| `<Space>ca` | Code Action | Show available code actions (fixes, refactors) |

### Diagnostics

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<Space>e` | Show Diagnostic Detail | Open floating window with full error/warning message |
| `[d` | Previous Diagnostic | Jump to previous error/warning |
| `]d` | Next Diagnostic | Jump to next error/warning |
| `K` | Hover Docs | Show function signature and docstring (press twice to enter float) |

### Formatting

- **Auto-format on save:** Enabled by default
- **Manual format:** Happens automatically when you save (`:w`)

---

## ⌨️ Auto-Completion - NEW!

**Auto-completion appears as you type!**

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<Tab>` | Next Suggestion | Cycle to next completion item |
| `<Shift-Tab>` | Previous Suggestion | Cycle to previous completion item |
| `<Enter>` | Accept Completion | Insert selected completion |
| `<Ctrl-Space>` | Trigger Completion | Manually trigger completion menu |
| `<Ctrl-e>` | Abort Completion | Close completion menu |
| `<Ctrl-f>` | Scroll Docs Down | Scroll documentation window down |
| `<Ctrl-b>` | Scroll Docs Up | Scroll documentation window up |

**Completion Sources (in order of priority):**
1. LSP suggestions (functions, variables, imports)
2. Snippets
3. Buffer words (text from current file)
4. File paths

---

## 🐍 Python Development

### Environment Detection

**Auto-detects Poetry and uv projects:**
- Poetry projects (has `poetry.lock`) → uses Poetry virtual environment
- uv projects (has `.venv/`) → uses uv virtual environment
- LSP and debugging work automatically with detected environment

### Code Formatting (ALE)

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<Space>b` | Format with Black | Run black formatter on current file |
| `<Space>r` | Format with Ruff | Run ruff formatter on current file |
| Auto-format | On Save | Black + Ruff run automatically on `:w` |

### Linting (ALE + LSP)

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<Space>aj` | Next Error | Jump to next ALE error/warning |
| `<Space>ak` | Previous Error | Jump to previous ALE error/warning |
| `[d` | Previous LSP Diagnostic | Jump to previous LSP diagnostic |
| `]d` | Next LSP Diagnostic | Jump to next LSP diagnostic |

---

## 🐛 Python Debugging (nvim-dap)

**Prerequisites:** `debugpy` must be installed in your project's virtual environment:
```bash
# In your project directory:
uv add --dev debugpy        # For uv projects
poetry add --group dev debugpy  # For poetry projects
pip install debugpy         # For other projects
```
**Common issue:** If `:PyDebug` hangs at "Attaching debugger", check:
1. Is debugpy installed in venv? Run: `python -c "import debugpy"`
2. Is port 5678 in use? Kill zombie process: `lsof -ti:5678 | xargs kill`

### Debug Controls

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<Space>db` | Toggle Breakpoint | Set/remove breakpoint on current line |
| `<Space>dc` | Continue/Start | Start debugging or continue to next breakpoint |
| `<Space>dn` | Step Over | Execute current line, don't step into functions |
| `<Space>di` | Step Into | Step into function call |
| `<Space>do` | Step Out | Step out of current function (executes remainder) |
| `<Space>du` | Frame Up | Move up call stack to inspect outer scope (like ipdb `u`) |
| `<Space>dd` | Frame Down | Move down call stack (like ipdb `d`) |
| `<Space>dt` | Terminate | Stop debugging session |
| `<Space>dr` | Toggle UI | Show/hide debug UI (variables, stack, etc.) |
| `<Space>de` | Evaluate | Evaluate expression under cursor |
| `<Space>dB` | Show Breakpoints | Show all breakpoints in floating window |
| `<Space>dC` | Clear All Breakpoints | Remove all breakpoints |
| `[b` | Previous Breakpoint | Jump to previous breakpoint |
| `]b` | Next Breakpoint | Jump to next breakpoint |

### Debug Commands

**`:PyDebug <script|file|module>` - Auto-detects Poetry/uv and starts debugger**

| Command | Description |
|---------|-------------|
| `:PyDebug start` | Run script from `pyproject.toml` (e.g., `[tool.poetry.scripts]`) |
| `:PyDebug script.py` | Debug a Python file directly |
| `:PyDebug -m module.name` | Debug a Python module |

**Auto-detection:**
- Poetry projects (`poetry.lock` present) → uses `poetry run python`
- uv projects → uses `uv run python`

### Debug Workflows

**Option 1: PyDebug Command (Recommended for Poetry/uv projects)**
1. Open your Python project in Neovim
2. Set breakpoints: `<Space>db` on desired lines
3. Run: `:PyDebug start` (or your script name from pyproject.toml)
4. Debug server starts, debugger auto-attaches
5. Debug UI opens automatically with variables, stack trace, etc.
6. Code execution pauses at your breakpoints

**Option 2: Direct File Launch**
1. Open a Python file in Neovim
2. Set breakpoints: `<Space>db`
3. Start debugging: `<Space>dc`
4. Select `Launch file`
5. Debug UI opens automatically with variables, stack trace, etc.

**Option 3: Attach to Remote Process**
1. Start your app with debugpy listener on port 5678
2. In Neovim: Open source file, set breakpoints (`<Space>db`)
3. Start debugging: `<Space>dc`
4. Select: `Attach remote`
5. Accept defaults (127.0.0.1:5678)
6. Application runs and hits your breakpoints

**Debug UI Windows:**
- **Scopes** - Local/global variables and their values
- **Breakpoints** - List of all breakpoints
- **Stack** - Call stack / stack trace
- **Watches** - Watch expressions
- **REPL** - Interactive Python console at breakpoint
- **Console** - Debug output and logs

**Pro Tips:**
- Variable values show inline as virtual text
- Hover over variables to see their values
- Use REPL window to run Python code at breakpoint
- `<Space>de` evaluates any expression under cursor
- Debug UI automatically opens/closes with debug session

---

## 💬 Code Commenting (NERDCommenter)

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<Space>cc` | Comment Line(s) | Comment out selected lines |
| `<Space>cu` | Uncomment Line(s) | Uncomment selected lines |
| `<Space>c<Space>` | Toggle Comment | Toggle comment on/off |

---

## 🔀 Git (vim-fugitive)

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<Space>gs` | Git Status | Open Git status window (most used!) |
| `<Space>gc` | Git Commit | Open commit window |
| `<Space>gp` | Git Push | Push to remote |
| `<Space>gl` | Git Log | View commit history |
| `<Space>gd` | Git Diff | Split view of changes |
| `<Space>gb` | Git Blame | See who changed each line |

**In Git Status window:**
- `s` - Stage file under cursor
- `u` - Unstage file under cursor
- `-` - Toggle stage/unstage
- `cc` - Create commit
- `=` - Toggle inline diff
- `dv` - Vertical diff of file under cursor

---

## ⚡ EasyMotion (Fast Navigation)

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<Space><Space>w` | Jump to Word Forward | Highlights all words, type letter to jump |
| `<Space><Space>b` | Jump to Word Backward | Jump to any word behind cursor |
| `<Space><Space>f{char}` | Find Character Forward | Find & jump to character |
| `<Space><Space>s{char}` | Search Character | Search character in both directions |

**How it works:** After pressing the combo, EasyMotion highlights all matches with letters. Type the highlighted letter to jump instantly!

---

## 📄 VimTeX (LaTeX Editing)

### Compilation & Viewing

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<Space>ll` | Compile | Start continuous compilation (watches for changes) |
| `<Space>lk` | Stop | Stop compilation |
| `<Space>lv` | View PDF | Open PDF in Preview.app |
| `<Space>le` | Errors | Show compilation errors/warnings |
| `<Space>lc` | Clean | Remove auxiliary files (.aux, .log, etc.) |
| `<Space>lC` | Full Clean | Remove auxiliary files AND output PDF |
| `<Space>lt` | TOC | Open table of contents |
| `<Space>lg` | Status | Show compilation status |

### Text Objects (use with d, c, y, v)

| Text Object | Description |
|-------------|-------------|
| `ie` / `ae` | Inside/around environment (`\begin{...}...\end{...}`) |
| `i$` / `a$` | Inside/around inline math (`$...$`) |
| `iP` / `aP` | Inside/around section |
| `im` / `am` | Inside/around item in list |

### Surrounding Commands

| Keybinding | Action | Description |
|------------|--------|-------------|
| `dse` | Delete Surrounding Env | Delete `\begin{}`/`\end{}` keeping content |
| `cse` | Change Surrounding Env | Change environment name |
| `tse` | Toggle Star | Toggle starred version (e.g., `equation` ↔ `equation*`) |
| `dsc` | Delete Surrounding Cmd | Delete command keeping argument |
| `csc` | Change Surrounding Cmd | Change command name |

### Insert Mode

| Keybinding | Action |
|------------|--------|
| `]]` | Close current environment (`\end{...}`) |

**Your config:** Compiler is `latexmk`, viewer is Preview.app

---

## 🐙 Octo (GitHub Integration)

**Prerequisites:** GitHub CLI must be installed and authenticated:
```bash
brew install gh
gh auth login
```
**Common issue:** If Octo commands fail, run `gh auth status` to verify authentication.

### Commands (use these to get started)

```vim
:Octo pr list              " List pull requests
:Octo pr checkout 123      " Checkout PR #123
:Octo pr create            " Create PR from current branch
:Octo issue list           " List issues
:Octo issue create         " Create new issue
:Octo review start         " Start reviewing current PR
```

### Keybindings (work in PR/Issue buffers only)

**Issues:**
| Keybinding | Action | Description |
|------------|--------|-------------|
| `<Space>il` | List Issues | List open issues |
| `<Space>ic` | Close Issue | Close current issue |
| `<Space>io` | Reopen Issue | Reopen issue |
| `<Space>ca` | Add Comment | Add comment to issue |
| `<Space>cd` | Delete Comment | Delete comment |
| `<Space>aa` | Add Assignee | Assign someone to issue |
| `<Space>la` | Add Label | Add label to issue |
| `gx` | Open in Browser | Open issue in GitHub (tmux-safe) |
| `<Space>oy` | Copy URL | Copy GitHub URL to clipboard |

**Pull Requests:**
| Keybinding | Action | Description |
|------------|--------|-------------|
| `<Space>po` | Checkout PR | Checkout PR locally |
| `<Space>pm` | Merge PR | Merge pull request |
| `<Space>pc` | List Commits | Show PR commits |
| `<Space>pf` | Changed Files | List files changed in PR |
| `<Space>pd` | Show Diff | View PR diff |
| `<Space>vs` | Start Review | Begin code review |
| `<Space>vr` | Resume Review | Resume pending review |
| `<Space>va` | Add Reviewer | Request review from someone |
| `gx` | Open in Browser | Open PR in browser (tmux-safe) |
| `<Space>oy` | Copy URL | Copy URL to clipboard |
| `]c` | Next Comment | Jump to next comment (in PR buffer) |
| `[c` | Previous Comment | Jump to previous comment (in PR buffer) |

**Code Review (during `:Octo review start/resume`):**

*File Panel Columns:*
- **Left column**: Number + bars showing file changes (green = additions, red = deletions)
- **Status icons**: M (modified), A (added), R (renamed), D (deleted)
- **Viewed state**: Blue (unviewed), Green (viewed), Red (dismissed)
- **Right column**: Thread counts - active (blue), pending (yellow), resolved (green), outdated (red)

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<Space><Space>` | Toggle File Viewed | Mark file as viewed/unviewed (in file panel) |
| `]t` | Next Thread | Jump to next comment thread (in diff) |
| `[t` | Previous Thread | Jump to previous comment thread (in diff) |
| `]q` | Next File | Move to next changed file |
| `[q` | Previous File | Move to previous changed file |
| `]u` | Next Unviewed File | Jump to next unviewed file |
| `[u` | Previous Unviewed File | Jump to previous unviewed file |
| `<Space>ca` | Add Comment | Add review comment |
| `<Space>sa` | Add Suggestion | Add code suggestion |
| `<Space>vs` | Submit Review | Submit review (approve/comment/request changes) |
| `<Space>vd` | Discard Review | Discard pending review |
| `<Space>tr` | Resolve Thread | Mark comment thread as resolved |
| `<Space>tu` | Unresolve Thread | Mark thread as unresolved |
| `<Space>e` | Focus Files Panel | Move cursor to file panel |
| `<Space>b` | Toggle Files Panel | Show/hide file panel |
| `gx` | Open in Browser | Open PR in browser (works in all review contexts) |
| `<Space>oy` | Copy URL | Copy URL to clipboard (works in all review contexts) |
| `<Ctrl-c>` | Close Review | Close review tab |

**Reactions (on comments):**
| Keybinding | Reaction |
|------------|----------|
| `<Space>r+` | 👍 Thumbs up |
| `<Space>r-` | 👎 Thumbs down |
| `<Space>rh` | ❤️ Heart |
| `<Space>rr` | 🚀 Rocket |
| `<Space>rp` | 🎉 Hooray |
| `<Space>re` | 👀 Eyes |
| `<Space>rl` | 😄 Laugh |
| `<Space>rc` | 😕 Confused |

**Review Threads (in comment/thread buffers):**
| Keybinding | Action | Description |
|------------|--------|-------------|
| `<Space>tr` | Resolve Thread | Mark comment thread as resolved |
| `<Space>tu` | Unresolve Thread | Mark thread as unresolved |

---

## 📂 Window/Split Management

### Navigation

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<Ctrl-h>` | Move Left | Focus window to the left |
| `<Ctrl-j>` | Move Down | Focus window below |
| `<Ctrl-k>` | Move Up | Focus window above |
| `<Ctrl-l>` | Move Right | Focus window to the right |

### Creating Splits

| Command | Action | Description |
|---------|--------|-------------|
| `:Vt` | Vertical Terminal | Open terminal in vertical split |
| `:Ht` | Horizontal Terminal | Open terminal in horizontal split |

### Terminal Mode

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<Ctrl-Q>` | Exit Terminal Mode | Return to normal mode from terminal |

---

## 🔎 Search & Replace

| Keybinding | Action | Description |
|------------|--------|-------------|
| `;;` | Search & Replace | Opens `:%s:::g` (fill in pattern and replacement) |
| `;'` | Search & Replace (Confirm) | Opens `:%s:::gc` (confirm each replacement) |
| `<Ctrl-C>` | Clear Highlights | Remove search highlighting |

### Visual Mode Search

| Keybinding | Action | Description |
|------------|--------|-------------|
| `*` (in visual) | Search Forward | Search for selected text forward |
| `#` (in visual) | Search Backward | Search for selected text backward |

---

## 📝 Editing Shortcuts

| Keybinding | Action | Description |
|------------|--------|-------------|
| `uu` | Exit Insert Mode | Alternative to `<Esc>` |
| `za` | Toggle Fold | Open/close code fold under cursor |
| `zo` | Open Fold | Open fold under cursor |
| `zc` | Close Fold | Close fold under cursor |
| `zR` | Open All Folds | Open all folds in file |
| `zM` | Close All Folds | Close all folds in file |

---

## 📊 Information Commands

| Command | Description |
|---------|-------------|
| `:LspInfo` | Show LSP server status and attached buffers |
| `:LspLog` | View LSP log file |
| `:LspRestart` | Restart LSP server for current buffer |
| `:Mason` | Open Mason package manager UI |
| `:MasonInstall <server>` | Install LSP server (e.g., `:MasonInstall omnisharp`) |
| `:MasonUpdate` | Update all Mason packages |
| `:checkhealth` | Check Neovim health (diagnostics) |
| `:messages` | Show recent messages/errors |
| `:PlugStatus` | Show plugin status |
| `:PlugUpdate` | Update all plugins |

---

## 🎯 Quick Workflow Examples

### Starting a New Python File

1. Open Neovim: `nvim myfile.py`
2. Start typing - auto-completion will appear
3. Press `K` on any function to see its documentation
4. Save with `:w` - auto-formatting happens
5. Any errors appear inline automatically

### Finding and Editing a Function

1. `<Space>fg` - Open live grep
2. Type function name
3. `<Enter>` to open file
4. `gd` on a function call to jump to definition
5. `gr` to see all references
6. `<Space>rn` to rename across project

### Fixing Errors

1. Errors appear inline with squiggly underlines
2. `]d` to jump to next error
3. `<Space>e` to see full error message
4. `<Space>ca` to see suggested fixes
5. Select fix and press `<Enter>`

### Working with Multiple Files

1. `<Space>ff` to open file finder
2. `<Ctrl-v>` to open in vertical split
3. `<Ctrl-h>/<Ctrl-l>` to switch between files
4. `<Space>fb` to see all open buffers
5. `:bd` to close current buffer

### Searching Across Project

1. `<Space>fg` - Live grep
2. Type your search term
3. See real-time results with context
4. `<Enter>` to jump to result
5. `<Ctrl-q>` to send results to quickfix list

---

## 🔥 Pro Tips

### LSP Features

- **Hover chains:** Press `K` twice to jump into hover documentation
- **Symbol search:** Use `<Space>fh` then search for language features
- **Auto-imports:** Many LSP servers suggest imports automatically
- **Format selection:** Visual select code, then `:lua vim.lsp.buf.format()`

### Telescope Tips

- **Hidden files:** Telescope shows hidden files by default (respects .gitignore)
- **Multiple selections:** `<Tab>` to select multiple files, `<Enter>` to open all
- **Resume last search:** `:Telescope resume`
- **Case-insensitive:** Searches are smart-case (lowercase = insensitive)

### Completion Tips

- **Trigger manually:** If completion doesn't appear, press `<Ctrl-Space>`
- **Accept with Tab:** `<Tab>` selects and inserts completion
- **Partial matches:** Type any part of word, not just prefix (e.g., "dpath" matches "docker_path")
- **Documentation:** Completion shows type hints and docs automatically

### Python Development

- **Virtual environments:** LSP auto-detects Poetry (`poetry.lock`) and uv (`.venv/`) projects
- **Debugging:** `:PyDebug` command auto-detects Poetry/uv and runs appropriately
- **Type hints:** Pyright shows type errors as you type
- **Imports:** Ruff suggests and organizes imports
- **Format on save:** Code auto-formats with black + ruff on save

---

## 🆘 Troubleshooting

### LSP Not Working

1. Check LSP status: `:LspInfo`
2. Verify servers installed: `which pyright ruff-lsp`
3. Check logs: `:LspLog`
4. Restart LSP: `:LspRestart`

### Completion Not Appearing

1. Verify you're in Insert mode
2. Try manual trigger: `<Ctrl-Space>`
3. Check completion sources: `:lua print(vim.inspect(require('cmp').get_config()))`

### Telescope Not Finding Files

1. Verify ripgrep installed: `which rg` (for live grep)
2. Check if in right directory: `:pwd`
3. Reload config: `:source ~/.config/nvim/init.vim`

### Formatting Issues

1. Check ALE status: `:ALEInfo`
2. Verify formatters installed: `which black ruff`
3. Check for errors: `:messages`

### Debugging Issues

1. **Breakpoints not hit:**
   - Verify debugpy installed: `uv tool list` or `pip list | grep debugpy`
   - Check you're setting breakpoints in code that actually runs
   - Verify file path matches (use absolute paths if needed)
   - Check debug logs: `:DapShowLog`

2. **Can't attach to remote:**
   - Ensure app is running with debugpy listener
   - Verify port 5678 is available: `lsof -i :5678`
   - Check firewall settings
   - Confirm `uv run debug` script is set up correctly

3. **Debug UI not showing:**
   - Manually toggle: `<Space>dr`
   - Check DAP status: `:lua require('dap').status()`
   - Restart Neovim and try again

---

## 📚 Learning Resources

**Neovim LSP:**
- `:help lsp`
- `:help vim.lsp.buf`

**Completion:**
- `:help nvim-cmp`
- `:help ins-completion`

**Telescope:**
- `:help telescope`
- `:Telescope help_tags` (search Telescope commands)

**Debugging:**
- `:help dap`
- `:help dap-python`
- `:PyDebug` for Poetry/uv project debugging

**General Vim:**
- `:Tutor` - Interactive Vim tutorial
- `:help` - Comprehensive help system

---

## 🔄 Quick Reference Card

**Most Used Keybindings:**

```
┌─────────────────────────────────────────┐
│  Navigation & Search                    │
├─────────────────────────────────────────┤
│  <Space>ff  Find files                  │
│  <Space>fg  Search in files (grep)      │
│  gd         Go to definition            │
│  K          Show documentation          │
│  <Space>fb  List buffers                │
├─────────────────────────────────────────┤
│  Editing                                │
├─────────────────────────────────────────┤
│  <Tab>      Next completion             │
│  uu         Exit insert mode            │
│  <Space>rn  Rename symbol               │
│  <Space>ca  Code actions                │
├─────────────────────────────────────────┤
│  Diagnostics                            │
├─────────────────────────────────────────┤
│  ]d         Next error                  │
│  [d         Previous error              │
│  <Space>e   Show error details          │
├─────────────────────────────────────────┤
│  Python Debugging                       │
├─────────────────────────────────────────┤
│  :PyDebug   Start debugger (auto-detect)│
│  <Space>db  Toggle breakpoint           │
│  <Space>dc  Start/continue debugging    │
│  <Space>dn  Step over                   │
│  <Space>di  Step into                   │
│  <Space>dt  Terminate debugger          │
│  <Space>dr  Toggle debug UI             │
├─────────────────────────────────────────┤
│  Package Management                     │
├─────────────────────────────────────────┤
│  :Mason     Open Mason (LSP installer)  │
└─────────────────────────────────────────┘
```

---

## 🤖 AI Assistance


### claudecode.nvim (Claude Code Terminal Integration)

**Prerequisites:** Claude Code CLI and Claude Pro subscription:
```bash
npm install -g @anthropic-ai/claude-code
claude auth login
```

**What it does:** Opens the Claude Code CLI as a terminal panel inside Neovim. Full agentic Claude experience — can read files, make edits, run commands — using your existing Claude Pro subscription.

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<Space>ac` | Toggle Claude Code | Show/hide Claude Code terminal panel |

**How it works:**
1. Press `<Space>ac` to open Claude Code in a right-side panel (38% width)
2. Chat normally — Claude Code can see your project files
3. It can read, edit, and create files directly
4. Press `<Space>ac` again to hide the panel

**Uses:** Complex refactoring, multi-file changes, architectural questions, anything you'd use Claude Code for in the terminal

**Cost:** Uses your Claude Pro subscription
- Tool permissions require confirmation even in Agentic mode

---

**Remember:** Your configuration supports Python (Poetry/uv) development with auto-detection, format-on-save, inline errors, and smart completions. Just start typing and the magic happens! ✨
