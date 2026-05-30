-- Phase 8: Agentic AI — CodeCompanion with Copilot adapter
--
-- Full agentic tool support: @agent, @files, @run_command, @insert_edit_into_file, etc.
-- Requires copilot.lua for Copilot authentication (inline suggestions disabled).

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

vim.keymap.set({ 'n', 'v' }, '<leader>ai', function()
  require('codecompanion').chat({})
end, { desc = 'Open CodeCompanion [A]I chat' })

vim.keymap.set({ 'n', 'v' }, '<leader>aA', function()
  require('codecompanion').chat({ layout = 'vertical' })
end, { desc = 'Open CodeCompanion AI chat vertical' })

vim.keymap.set('v', 'ga', function()
  require('codecompanion').inline()
end, { desc = 'Inline AI transformation' })

vim.keymap.set('n', '<leader>ce', function()
  require('codecompanion').action_palette {}
end, { desc = 'CodeCompanion action palette' })
