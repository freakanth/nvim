-- Telescope configuration
require('telescope').setup({
  defaults = {
    file_ignore_patterns = { "node_modules", ".git/", "__pycache__", "%.pyc" },
    layout_config = {
      horizontal = { preview_width = 0.55 },
    },
  },
  pickers = {
    find_files = {
      hidden = true,  -- Show hidden files but respect .gitignore
    },
  },
})

-- Helper: Live Grep with file type filter
-- Usage: <Space>fT then input file extension (e.g., "py", "lua", "js")
vim.keymap.set('n', '<leader>fT', function()
  local ext = vim.fn.input('File extension (py/lua/js/etc): ')
  if ext ~= '' then
    require('telescope.builtin').live_grep({
      type_filter = ext,
      glob_pattern = '*.' .. ext,
      prompt_title = 'Live Grep (*.' .. ext .. ')'
    })
  end
end, { desc = 'Live grep filtered by file type' })

-- Helper: Live Grep in Python files only
vim.keymap.set('n', '<leader>fP', function()
  require('telescope.builtin').live_grep({
    glob_pattern = '*.py',
    prompt_title = 'Live Grep (Python)'
  })
end, { desc = 'Live grep in Python files' })

-- Helper: Live Grep in Markdown files only
vim.keymap.set('n', '<leader>fM', function()
  require('telescope.builtin').live_grep({
    glob_pattern = '*.md',
    prompt_title = 'Live Grep (Markdown)'
  })
end, { desc = 'Live grep in Markdown files' })
