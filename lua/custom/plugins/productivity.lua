-- Productivity: autopairs, word highlighting, markdown preview

local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'windwp/nvim-autopairs',
  gh 'RRethy/vim-illuminate',
}
vim.pack.add { gh 'iamcco/markdown-preview.nvim' }

-- nvim-autopairs: auto-close brackets, quotes, parens
require('nvim-autopairs').setup {
  check_ts = true,
  ts_config = {
    lua = { 'string' },
    javascript = { 'template_string' },
  },
  enable_check_bracket_line = false,
  map_cr = true,
}

-- vim-illuminate: auto-highlight word under cursor
-- Uses defaults — no setup required

-- markdown-preview.nvim: live HTML preview
vim.keymap.set('n', '<leader>mp', '<cmd>MarkdownPreview<CR>', { desc = '[M]arkdown [P]review toggle' })
