-- Code Quality: async linters, structured diagnostics

local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'mfussenegger/nvim-lint',
  gh 'folke/trouble.nvim',
}

-- nvim-lint: async linters run on save
local lint = require 'lint'

lint.linters_by_ft = {
  cpp  = { 'clangtidy' },
  c    = { 'clangtidy' },
  rust = { 'clippy' },
  go   = { 'staticcheck' },
  javascript = { 'eslint_d' },
  typescript = { 'eslint_d' },
  typescriptreact = { 'eslint_d' },
  javascriptreact = { 'eslint_d' },
}

vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
  group = vim.api.nvim_create_augroup('nvim-lint', { clear = true }),
  callback = function() lint.try_lint() end,
})

-- trouble.nvim: structured, filterable diagnostics list
require('trouble').setup {
  position = 'bottom',
  height = 10,
  width = 50,
  icons = true,
  mode = 'workspace_diagnostics',
  fold_open = '▾',
  fold_closed = '▸',
  group = true,
  severity = vim.diagnostic.severity.WARN,
}

-- Keymaps
vim.keymap.set('n', '<leader>xx', function()
  require('trouble').toggle()
end, { desc = 'Trouble toggl[e]' })

vim.keymap.set('n', '<leader>xw', function()
  require('trouble').toggle 'workspace_diagnostics'
end, { desc = 'Trouble [w]orkspace diagnostics' })

vim.keymap.set('n', '<leader>xd', function()
  require('trouble').toggle 'document_diagnostics'
end, { desc = 'Trouble [d]ocument diagnostics' })

vim.keymap.set('n', '<leader>xl', function()
  require('trouble').toggle 'loclist'
end, { desc = 'Trouble [l]oclist' })

vim.keymap.set('n', '<leader>xq', function()
  require('trouble').toggle 'quickfix'
end, { desc = 'Trouble [q]uickfix' })
