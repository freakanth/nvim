-- nvim-dap - Debug Adapter Protocol configuration for Python

local dap = require('dap')
local dapui = require('dapui')
local dap_python = require('dap-python')

-- ============================================================================
-- Python Debugger Setup
-- ============================================================================

-- Find Python interpreter (poetry, uv venv, or pyenv)
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

-- Setup Python debugger (uses debugpy)
-- Install with: pip install debugpy OR uv tool install debugpy
dap_python.setup(get_python_path())

-- Python debugging configurations
dap.configurations.python = {
  {
    type = 'python',
    request = 'launch',
    name = 'Launch file',
    program = '${file}',
    pythonPath = get_python_path,
  },
  {
    type = 'python',
    request = 'launch',
    name = 'Launch file with arguments',
    program = '${file}',
    args = function()
      local args_string = vim.fn.input('Arguments: ')
      return vim.split(args_string, " +")
    end,
    pythonPath = get_python_path,
  },
  {
    type = 'python',
    request = 'attach',
    name = 'Attach remote',
    connect = function()
      local host = vim.fn.input('Host [127.0.0.1]: ')
      host = host ~= '' and host or '127.0.0.1'
      local port = tonumber(vim.fn.input('Port [5678]: ')) or 5678
      return { host = host, port = port }
    end,
  },
}

-- ============================================================================
-- DAP UI Setup
-- ============================================================================

dapui.setup({
  icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
  mappings = {
    expand = { "<CR>", "<2-LeftMouse>" },
    open = "o",
    remove = "d",
    edit = "e",
    repl = "r",
    toggle = "t",
  },
  layouts = {
    {
      elements = {
        { id = "scopes", size = 0.25 },
        { id = "breakpoints", size = 0.25 },
        { id = "stacks", size = 0.25 },
        { id = "watches", size = 0.25 },
      },
      size = 40,
      position = "left",
    },
    {
      elements = {
        "repl",
        "console",
      },
      size = 0.25,
      position = "bottom",
    },
  },
  floating = {
    max_height = nil,
    max_width = nil,
    border = "single",
    mappings = {
      close = { "q", "<Esc>" },
    },
  },
})

-- ============================================================================
-- Virtual Text Setup
-- ============================================================================

require('nvim-dap-virtual-text').setup({
  enabled = true,
  enabled_commands = true,
  highlight_changed_variables = true,
  highlight_new_as_changed = false,
  show_stop_reason = true,
  commented = false,
  only_first_definition = true,
  all_references = false,
  filter_references_pattern = '<module',
  virt_text_pos = 'eol',
  all_frames = false,
  virt_lines = false,
  virt_text_win_col = nil
})

-- ============================================================================
-- Auto-open UI on debug start, auto-close on end
-- ============================================================================

dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

-- ============================================================================
-- Custom Signs (Breakpoint Icons)
-- ============================================================================

vim.fn.sign_define('DapBreakpoint', {
  text = '🔴',
  texthl = 'DapBreakpoint',
  linehl = '',
  numhl = ''
})
vim.fn.sign_define('DapBreakpointCondition', {
  text = '🟡',
  texthl = 'DapBreakpointCondition',
  linehl = '',
  numhl = ''
})
vim.fn.sign_define('DapLogPoint', {
  text = '📝',
  texthl = 'DapLogPoint',
  linehl = '',
  numhl = ''
})
vim.fn.sign_define('DapStopped', {
  text = '▶️',
  texthl = 'DapStopped',
  linehl = 'DapStopped',
  numhl = ''
})
vim.fn.sign_define('DapBreakpointRejected', {
  text = '❌',
  texthl = 'DapBreakpointRejected',
  linehl = '',
  numhl = ''
})

-- ============================================================================
-- PyDebug - Auto-attach Debug Function
-- ============================================================================

-- Track running debug job for cleanup
local debug_job_id = nil

-- Detect which Python package manager to use
local function get_python_runner()
  local poetry_lock = vim.fn.getcwd() .. '/poetry.lock'
  if vim.fn.filereadable(poetry_lock) == 1 then
    return 'poetry run python'
  end
  return 'uv run python'
end

-- Enhanced auto-attach debug function
function PyDebug(opts)
  local args = opts.args

  if args == '' then
    print("Usage: :PyDebug <script> [args...]")
    print("Example: :PyDebug datagent-chat -a config.yaml")
    return
  end

  -- Kill previous debug job if still running (issue #1)
  if debug_job_id and vim.fn.jobwait({debug_job_id}, 0)[1] == -1 then
    print("Terminating previous debug session...")
    vim.fn.jobstop(debug_job_id)
    vim.wait(500) -- Give it time to clean up
  end

  -- Parse arguments
  local parts = vim.split(args, ' ')
  local script_name = parts[1]
  local remaining_args = table.concat(vim.list_slice(parts, 2), ' ')

  -- Check if it's a .py file
  if script_name:match('%.py$') then
    -- Run as file directly
    local command = string.format(
      '%s -Xfrozen_modules=off -m debugpy --listen 5678 --wait-for-client %s %s',
      get_python_runner(), script_name, remaining_args
    )

    debug_job_id = vim.fn.jobstart(command, {
      cwd = vim.fn.getcwd(),
      on_exit = function() debug_job_id = nil end
    })

  elseif script_name == '-m' then
    -- Run as module
    local module_name = parts[2]
    remaining_args = table.concat(vim.list_slice(parts, 3), ' ')
    local command = string.format(
      '%s -Xfrozen_modules=off -m debugpy --listen 5678 --wait-for-client -m %s %s',
      get_python_runner(), module_name, remaining_args
    )

    debug_job_id = vim.fn.jobstart(command, {
      cwd = vim.fn.getcwd(),
      on_exit = function() debug_job_id = nil end
    })

  else
    -- Look up in pyproject.toml (issue #4 - better error handling)
    local pyproject_path = vim.fn.getcwd() .. '/pyproject.toml'
    if vim.fn.filereadable(pyproject_path) == 0 then
      print("Error: pyproject.toml not found in current directory")
      print("Make sure you're in your project root, or use: :PyDebug script.py")
      return
    end

    local module_path = vim.fn.system(string.format([[
python -c "
import sys
try:
    import tomllib
except ImportError:
    import tomli as tomllib

try:
    with open('pyproject.toml', 'rb') as f:
        data = tomllib.load(f)

    # Check both PEP 621 and Poetry script locations
    scripts = data.get('project', {}).get('scripts', {})
    if not scripts:
        scripts = data.get('tool', {}).get('poetry', {}).get('scripts', {})

    entry = scripts.get('%s')
    if not entry:
        print('ERROR: Script not found', file=sys.stderr)
        sys.exit(1)
    module = entry.split(':')[0]
    print(module)
except Exception as e:
    print(f'ERROR: {e}', file=sys.stderr)
    sys.exit(1)
"
    ]], script_name))

    if vim.v.shell_error ~= 0 then
      print(string.format("Error: Script '%s' not found in [project.scripts]", script_name))
      print("Available options:")
      print("  - Add script to pyproject.toml")
      print("  - Run file directly: :PyDebug script.py")
      print("  - Run module: :PyDebug -m module.name")
      return
    end

    module_path = module_path:gsub('\n', '')

    local command = string.format(
      '%s -Xfrozen_modules=off -m debugpy --listen 5678 --wait-for-client -m %s %s',
      get_python_runner(), module_path, remaining_args
    )

    debug_job_id = vim.fn.jobstart(command, {
      cwd = vim.fn.getcwd(),
      on_exit = function() debug_job_id = nil end
    })
  end

  if debug_job_id == 0 then
    print("Error: Invalid command")
    return
  elseif debug_job_id == -1 then
    print("Error: Command not executable. Is poetry/uv installed?")
    return
  end

  print("Starting debug server on port 5678...")

  -- Smart port checking with timeout (issue #3)
  local max_attempts = 25 -- 25 * 200ms = 5 seconds max
  local attempt = 0

  local function try_attach()
    attempt = attempt + 1
    local result = vim.fn.system('lsof -i:5678 2>/dev/null')

    if result:match('LISTEN') then
      -- Port is ready, attach now
      print("Attaching debugger...")
      require('dap').run({
        type = 'python',
        request = 'attach',
        name = 'PyDebug Attach',
        connect = { host = '127.0.0.1', port = 5678 }
      })
    elseif attempt >= max_attempts then
      print("Error: Debug server failed to start (timeout after 5s)")
      print("Check Console window for errors")
      if debug_job_id then
        vim.fn.jobstop(debug_job_id)
        debug_job_id = nil
      end
    else
      -- Try again
      vim.defer_fn(try_attach, 200)
    end
  end

  -- Start checking after 500ms (give process time to start)
  vim.defer_fn(try_attach, 500)
end

-- Auto-cleanup on debug termination (issue #1)
dap.listeners.before.event_terminated["cleanup_job"] = function()
  if debug_job_id then
    vim.fn.jobstop(debug_job_id)
    debug_job_id = nil
  end
end
dap.listeners.before.event_exited["cleanup_job"] = function()
  if debug_job_id then
    vim.fn.jobstop(debug_job_id)
    debug_job_id = nil
  end
end

vim.api.nvim_create_user_command('PyDebug', PyDebug, { nargs = '+' })
