-- DAP: Debug Adapter Protocol for C++, Rust, Go, JavaScript/TypeScript

local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'mfussenegger/nvim-dap',
  gh 'nvim-neotest/nvim-nio',
  gh 'rcarriga/nvim-dap-ui',
  gh 'theHamsta/nvim-dap-virtual-text',
  gh 'jay-babu/mason-nvim-dap.nvim',
}

require('mason-nvim-dap').setup {
  ensure_installed = {
    'codelldb',
    'js-debug-adapter',
    'debugpy',
  },
  handlers = {},
}

local dap = require 'dap'
local dapui = require 'dapui'

dapui.setup {
  icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
  controls = {
    icons = {
      pause = '⏸',
      play = '▶',
      step_into = '⏎',
      step_over = '⏭',
      step_out = '⏮',
      step_back = 'b',
      run_last = '▶▶',
      terminate = '⏹',
    },
  },
}

require('nvim-dap-virtual-text').setup {}

-- Auto-open/close DAP UI on debug events
dap.listeners.after.event_initialized['dapui_config'] = dapui.open
dap.listeners.after.event_terminated['dapui_config'] = dapui.close
dap.listeners.after.event_exited['dapui_config'] = dapui.close

-- C++ / Rust: codelldb via Mason
dap.adapters.lldb = {
  type = 'server',
  port = '${port}',
  executable = {
    command = vim.fn.stdpath 'data' .. '/mason/bin/codelldb',
    args = { '--port', '${port}' },
  },
}

dap.configurations.cpp = {
  {
    name = 'Launch',
    type = 'lldb',
    request = 'launch',
    program = function() return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file') end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    args = {},
  },
}

dap.configurations.c = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp

-- Go: delve
dap.adapters.dlv = {
  type = 'server',
  port = '${port}',
  executable = {
    command = vim.fn.expand '~/go/bin/dlv',
    args = { 'dap', '-l', '127.0.0.1:${port}' },
  },
}

dap.configurations.go = {
  {
    name = 'Launch',
    type = 'dlv',
    request = 'launch',
    program = vim.fn.getcwd(),
    dlvToolPath = vim.fn.exepath 'dlv',
  },
}

-- JavaScript / TypeScript: js-debug-adapter via Mason
dap.adapters['pwa-node'] = {
  type = 'server',
  host = '127.0.0.1',
  port = '${port}',
  executable = {
    command = vim.fn.stdpath 'data' .. '/mason/bin/js-debug-adapter',
    args = { '${port}' },
  },
}

dap.configurations.javascript = {
  {
    name = 'Launch',
    type = 'pwa-node',
    request = 'launch',
    program = '${file}',
    cwd = '${workspaceFolder}',
  },
}

dap.configurations.typescript = dap.configurations.javascript
dap.configurations.javascriptreact = dap.configurations.javascript
dap.configurations.typescriptreact = dap.configurations.javascript

-- Keymaps
vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = '[D]AP [B]reakpoint' })
vim.keymap.set('n', '<leader>dB', function()
  dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
end, { desc = '[D]AP conditional [B]reakpoint' })
vim.keymap.set('n', '<leader>dc', dap.continue, { desc = '[D]AP [C]ontinue' })
vim.keymap.set('n', '<leader>do', dap.step_over, { desc = '[D]AP step [O]ver' })
vim.keymap.set('n', '<leader>di', dap.step_into, { desc = '[D]AP step [I]nto' })
vim.keymap.set('n', '<leader>dO', dap.step_out, { desc = '[D]AP step [O]ut' })
vim.keymap.set('n', '<leader>dr', dap.restart, { desc = '[D]AP [R]estart' })
vim.keymap.set('n', '<leader>dq', dap.terminate, { desc = '[D]AP [Q]uit' })
vim.keymap.set('n', '<leader>du', dapui.toggle, { desc = '[D]AP [U]I toggle' })
