-- TreeSitter configuration (new API for rewritten nvim-treesitter)

-- Register markdown parser for octo buffers (recommended by Octo.nvim)
vim.treesitter.language.register('markdown', 'octo')

-- Fix diff highlights to show TreeSitter syntax colors on added/changed lines
-- Without this, DiffAdd/DiffText force light gray text, hiding syntax colors
vim.api.nvim_set_hl(0, 'DiffAdd', { bg = '#13354a', fg = 'NONE' })
vim.api.nvim_set_hl(0, 'DiffText', { bg = '#4c4745', fg = 'NONE', bold = true, italic = true })
vim.api.nvim_set_hl(0, 'DiffChange', { bg = 'NONE', fg = 'NONE' })

-- Install parsers (async - only happens if not already installed)
require('nvim-treesitter').install({ 'python', 'lua', 'vim', 'markdown', 'csv' })

-- Enable highlighting for regular files
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'python', 'lua', 'vim', 'markdown' },
  callback = function()
    vim.treesitter.start()
  end,
})

-- Force TreeSitter for Octo review buffers (optional workaround)
-- NOTE: This is a workaround since Octo doesn't emit events when creating review buffers.
-- Without this, legacy Vim syntax highlighting works fine (due to the DiffAdd fix above),
-- but TreeSitter provides more accurate/sophisticated syntax highlighting.
-- This autocmd iterates all buffers on each BufEnter to activate TreeSitter on both
-- left/right diff buffers simultaneously for consistent colors.
vim.api.nvim_create_autocmd('BufEnter', {
  pattern = 'octo://*',
  callback = function()
    vim.defer_fn(function()
      -- Only activate on octo:// buffers that don't have TreeSitter active yet
      for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(bufnr) then
          local bufname = vim.api.nvim_buf_get_name(bufnr)
          local ft = vim.bo[bufnr].filetype

          -- Skip filetypes that don't have/need TreeSitter parsers
          local skip_filetypes = { 'text', 'plaintext', '' }
          local should_skip = vim.tbl_contains(skip_filetypes, ft)

          if bufname:match('^octo://') and ft ~= '' and not should_skip then
            -- Only start if not already active
            if not vim.treesitter.highlighter.active[bufnr] then
              local ok, err = pcall(vim.treesitter.start, bufnr)
              if not ok and err:match('Parser could not be created') then
                vim.notify(
                  string.format('TreeSitter parser missing for "%s". Install with :TSInstall %s', ft, ft),
                  vim.log.levels.WARN
                )
              end
            end
          end
        end
      end
    end, 100)
  end,
})
