-- Phase 8: Agentic AI — CodeCompanion with GitHub Models adapter
--
-- Uses the `github_models` adapter which authenticates via `gh` CLI.
-- No copilot.lua needed — works with your existing GitHub auth.
-- Provides access to GPT-4o, GPT-4.1, and other models via GitHub's API.

local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'olimorris/codecompanion.nvim',
  gh 'nvim-lua/plenary.nvim',
}

require('codecompanion').setup {
  strategies = {
    chat = { adapter = 'github_models' },
    inline = { adapter = 'github_models' },
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
