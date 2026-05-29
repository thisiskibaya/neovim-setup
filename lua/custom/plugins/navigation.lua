-- Navigation & Project Management: file tree, bookmarks, quick jump, project switcher

local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'nvim-neo-tree/neo-tree.nvim',
  gh 'folke/flash.nvim',
  gh 'ahmedkhalf/project.nvim',
}

-- neo-tree: file tree explorer
require('neo-tree').setup {
  close_if_last_window = true,
  enable_git_status = true,
  enable_diagnostics = true,
  window = {
    position = 'left',
    width = 30,
    mappings = {
      ['l'] = 'open',
      ['h'] = 'close_node',
      ['<space>'] = { 'toggle_node', nowait = false },
    },
  },
  default_component_configs = {
    indent = { with_markers = true, indent_size = 2 },
    icon = { folder_closed = '▸', folder_open = '▾' },
    git_status = { symbols = { unstaged = 'M', staged = 'S' } },
  },
  filesystem = {
    filtered_items = {
      visible = false,
      hide_dotfiles = false,
      hide_gitignored = false,
    },
  },
}

-- flash: jump anywhere on screen
require('flash').setup {
  modes = {
    char = { enabled = true },
    line = { enabled = false },
    search = { enabled = false },
    treesitter = { enabled = false },
    remote = { enabled = false },
  },
  jump = { autojump = false },
  highlight = { backdrop = false },
}

-- project.nvim: project root detection
require('project_nvim').setup {
  detection_methods = { 'lsp', 'pattern' },
  patterns = { '.git', 'Makefile', 'CMakeLists.txt', 'Cargo.toml', 'go.mod', 'package.json', 'composer.json' },
}

-- Keymaps

-- neo-tree
vim.keymap.set('n', '<leader>pv', function()
  local neo_tree = require 'neo-tree.command'
  neo_tree.execute { toggle = true, dir = vim.fn.getcwd() }
end, { desc = '[P]roject [V]iew — toggle neo-tree' })

-- flash: s to jump, S to jump backwards
vim.keymap.set({ 'n', 'x' }, 's', function()
  require('flash').jump()
end, { desc = '[F]lash jump forward' })
vim.keymap.set({ 'n', 'x' }, 'S', function()
  require('flash').jump { search = { mode = function(str) return str end } }
end, { desc = '[F]lash jump backward' })

-- project: telescope integration
vim.keymap.set('n', '<leader>fp', function()
  require('telescope').extensions.project.project {}
end, { desc = '[F]ind [P]rojects' })
