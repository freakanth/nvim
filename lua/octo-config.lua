-- Octo.nvim - GitHub integration

-- Custom wrapper for open_in_browser that works during reviews
local function safe_open_in_browser()
  -- Try to get current review first (for review diff/thread contexts)
  local ok, reviews = pcall(require, 'octo.reviews')
  if ok then
    local current_review = reviews.get_current_review()
    if current_review and current_review.pull_request then
      local pr = current_review.pull_request
      local nav = require('octo.navigation')
      nav.open_in_browser('pull_request', pr.repo, pr.number)
      return
    end
  end

  -- Fall back to default behavior for PR/issue buffers
  require('octo.navigation').open_in_browser()
end

-- Custom wrapper for copy_url that works during reviews
local function safe_copy_url()
  -- Try to get current review first
  local ok, reviews = pcall(require, 'octo.reviews')
  if ok then
    local current_review = reviews.get_current_review()
    if current_review and current_review.pull_request then
      local pr = current_review.pull_request
      local utils = require('octo.utils')
      local remote = utils.get_remote_host()
      if remote then
        local url = string.format("https://%s/%s/pull/%d", remote, pr.repo, pr.number)
        vim.fn.setreg('+', url)
        vim.notify("Copied PR URL to clipboard: " .. url, vim.log.levels.INFO)
        return
      end
    end
  end

  -- Fall back to default behavior
  require('octo.commands').copy_url()
end

require('octo').setup({
  default_remote = {"upstream", "origin"},
  mappings = {
    issue = {
      close_issue = { lhs = "<space>ic", desc = "close issue" },
      reopen_issue = { lhs = "<space>io", desc = "reopen issue" },
      list_issues = { lhs = "<space>il", desc = "list open issues" },
      reload = { lhs = "<C-r>", desc = "reload issue" },
      open_in_browser = { lhs = "gx", desc = "open issue in browser" },
      copy_url = { lhs = "<space>oy", desc = "copy url to clipboard" },
      add_assignee = { lhs = "<space>aa", desc = "add assignee" },
      remove_assignee = { lhs = "<space>ad", desc = "remove assignee" },
      add_label = { lhs = "<space>la", desc = "add label" },
      remove_label = { lhs = "<space>ld", desc = "remove label" },
    },
    pull_request = {
      checkout_pr = { lhs = "<space>po", desc = "checkout PR" },
      merge_pr = { lhs = "<space>pm", desc = "merge PR" },
      list_commits = { lhs = "<space>pc", desc = "list PR commits" },
      list_changed_files = { lhs = "<space>pf", desc = "list PR changed files" },
      show_pr_diff = { lhs = "<space>pd", desc = "show PR diff" },
      add_reviewer = { lhs = "<space>va", desc = "add reviewer" },
      remove_reviewer = { lhs = "<space>vd", desc = "remove reviewer" },
      close_issue = { lhs = "<space>ic", desc = "close PR" },
      reopen_issue = { lhs = "<space>io", desc = "reopen PR" },
      reload = { lhs = "<C-r>", desc = "reload PR" },
      open_in_browser = { lhs = "gx", desc = "open PR in browser" },
      copy_url = { lhs = "<space>oy", desc = "copy url to clipboard" },
      add_assignee = { lhs = "<space>aa", desc = "add assignee" },
      remove_assignee = { lhs = "<space>ad", desc = "remove assignee" },
      add_label = { lhs = "<space>la", desc = "add label" },
      remove_label = { lhs = "<space>ld", desc = "remove label" },
      add_comment = { lhs = "<space>ca", desc = "add comment" },
      delete_comment = { lhs = "<space>cd", desc = "delete comment" },
      next_comment = { lhs = "]c", desc = "next comment" },
      prev_comment = { lhs = "[c", desc = "previous comment" },
      review_start = { lhs = "<space>vs", desc = "start review" },
      review_resume = { lhs = "<space>vr", desc = "resume review" },
    },
    review_thread = {
      resolve_thread = { lhs = "<space>tr", desc = "resolve thread" },
      unresolve_thread = { lhs = "<space>tu", desc = "unresolve thread" },
    },
    review_diff = {},
    file_panel = {},
  }
})

-- Override keybindings after Octo loads to use our safe wrappers
-- These will work in all Octo buffers including review contexts
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'octo', 'octo_panel', 'octo_issue', 'octo_pull_request' },
  callback = function(args)
    local bufnr = args.buf
    vim.keymap.set('n', 'gx', safe_open_in_browser, { buffer = bufnr, noremap = true, silent = true, desc = "Open PR in browser" })
    vim.keymap.set('n', '<space>oy', safe_copy_url, { buffer = bufnr, noremap = true, silent = true, desc = "Copy URL to clipboard" })
  end,
})
