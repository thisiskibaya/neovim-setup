-- Phase 8: Agentic AI — CodeCompanion with Copilot adapter
--
-- Requires copilot.lua for Copilot authentication.
-- Inline suggestions are disabled — chat only.

local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'olimorris/codecompanion.nvim',
  gh 'zbirenbaum/copilot.lua',
  gh 'nvim-lua/plenary.nvim',
}

vim.cmd.packadd 'copilot.lua'
require('copilot').setup {
  suggestion = { enabled = false },
  panel = { enabled = false },
}

require('codecompanion').setup {
  strategies = {
    chat = { adapter = 'copilot' },
    inline = { adapter = 'copilot' },
  },
  display = {
    chat = {
      window = {
        layout = 'vertical',
        width = 0.4,
      },
    },
  },
  opts = {
    log_level = 'INFO',
  },
}

vim.keymap.set({ 'n', 'v' }, '<leader>cc', function()
  require('codecompanion').chat({})
end, { desc = 'Open CodeCompanion [C]hat' })

vim.keymap.set({ 'n', 'v' }, '<leader>cC', function()
  require('codecompanion').chat({ layout = 'vertical' })
end, { desc = 'Open CodeCompanion chat in vertical split' })

vim.keymap.set('v', 'ga', function()
  require('codecompanion').inline()
end, { desc = 'Inline AI transformation' })

vim.keymap.set('n', '<leader>ce', function()
  require('codecompanion').action_palette {}
end, { desc = 'CodeCompanion action palette' })
