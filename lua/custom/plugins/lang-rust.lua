-- Rust: crate version management in Cargo.toml

local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'saecki/crates.nvim' }

require('crates').setup {
  smart_insert = true,
  autoload = true,
  autoupdate = true,
  popup = { border = 'rounded' },
}

-- Keymaps (work in Cargo.toml files)
vim.keymap.set('n', '<leader>rc', function()
  require('crates').show()
end, { desc = '[R]ust [C]rates — show updates' })

vim.keymap.set('n', '<leader>ru', function()
  require('crates').update_crate()
end, { desc = '[R]ust crates [U]pdate' })

vim.keymap.set('n', '<leader>rU', function()
  require('crates').upgrade_all_crates()
end, { desc = '[R]ust crates [U]pgrade all' })
