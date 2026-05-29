-- Git: magit porcelain, diff viewer, conflict resolution

local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'NeogitOrg/neogit',
  gh 'sindrets/diffview.nvim',
}

-- neogit: full magit porcelain
require('neogit').setup {
  disable_hint = false,
  disable_context_highlighting = false,
  disable_commit_confirmation = false,
  kind = 'tab',
  integrations = { diffview = true },
}

-- diffview.nvim: side-by-side diffs, file history, conflict resolution
require('diffview').setup {
  enhanced_diff_hl = true,
  show_help_hint = true,
}

-- Keymaps
vim.keymap.set('n', '<leader>gg', function()
  require('neogit').open { kind = 'tab' }
end, { desc = '[G]it [G]ui — neogit' })

vim.keymap.set('n', '<leader>gd', function()
  require('diffview').open()
end, { desc = '[G]it [D]iff — diffview' })

vim.keymap.set('n', '<leader>gh', function()
  require('diffview').file_history()
end, { desc = '[G]it [H]istory — diffview file history' })
