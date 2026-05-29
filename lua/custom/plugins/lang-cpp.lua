-- C++: CMake integration, clangd enhancements

local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'Civitasv/cmake-tools.nvim',
  gh 'p00f/clangd_extensions.nvim',
}
vim.pack.add { gh 'akinsho/toggleterm.nvim' }
vim.pack.add { gh 'stevearc/overseer.nvim' }

-- cmake-tools.nvim: configure, build, test, run
require('cmake-tools').setup {
  cmake_generate_options = { '-DCMAKE_EXPORT_COMPILE_COMMANDS=1' },
  cmake_build_directory = 'build',
  cmake_use_preset = true,
  cmake_regenerate_on_save = true,
  cmake_compile_commands_options = {
    action = 'soft_link',
    target = vim.loop.cwd,
  },
  cmake_dap_configuration = {
    name = 'cpp',
    type = 'codelldb',
    request = 'launch',
    stopOnEntry = false,
  },
  cmake_executor = { name = 'quickfix' },
  cmake_runner = { name = 'terminal' },
}

-- clangd_extensions.nvim: inlay hints, type hierarchy, memory usage
require('clangd_extensions').setup {
  auto_set_hover = true,
  inlay_hints = {
    inline = true,
    only_current_line = false,
    show_parameter_hints = true,
    show_variable_name = false,
  },
  ast = { role_icons = { type = '🄣', ['function'] = '🄕', variable = '🄯' } },
  memory_usage = { border = 'rounded' },
  symbol_info = { border = 'rounded' },
}

-- Keymaps
vim.keymap.set('n', '<leader>cc', function()
  require('cmake-tools').cmake_generate()
end, { desc = 'CMake [C]onfigure' })

vim.keymap.set('n', '<leader>cb', function()
  require('cmake-tools').cmake_build()
end, { desc = 'CMake [B]uild' })

vim.keymap.set('n', '<leader>ct', function()
  require('cmake-tools').cmake_test()
end, { desc = 'CMake [T]est' })

vim.keymap.set('n', '<leader>cr', function()
  require('cmake-tools').cmake_run()
end, { desc = 'CMake [R]un' })

vim.keymap.set('n', '<leader>cT', function()
  require('cmake-tools').cmake_select_target()
end, { desc = 'CMake select [T]arget' })
