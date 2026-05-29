-- Go: test runner, coverage, alternate file switching

local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'ray-x/go.nvim' }
vim.pack.add { gh 'ray-x/guihua.lua' }

require('go').setup {
  gofmt = 'gofmt',
  max_line_len = 120,
  tag_transform = false,
  test_runner = 'go',
  verbose = false,
  lsp_inlay_hints = { enable = true },
}

-- Keymaps
vim.keymap.set('n', '<leader>gr', '<cmd>GoRun<CR>', { desc = '[G]o [R]un' })
vim.keymap.set('n', '<leader>gb', '<cmd>GoBuild<CR>', { desc = '[G]o [B]uild' })
vim.keymap.set('n', '<leader>gt', '<cmd>GoTestFunc<CR>', { desc = '[G]o [T]est — nearest function' })
vim.keymap.set('n', '<leader>ga', '<cmd>GoTestAll<CR>', { desc = '[G]o test [A]ll' })
vim.keymap.set('n', '<leader>gc', '<cmd>GoCoverage<CR>', { desc = '[G]o [C]overage' })
