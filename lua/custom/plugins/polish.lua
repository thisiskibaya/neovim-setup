-- Polish: cosmetic improvements — toggle on/off individually below
--
-- Usage: set any flag to false, restart nvim, and that feature is disabled.

local function gh(repo) return 'https://github.com/' .. repo end

-- ============================================================
-- Toggle Flags
-- ============================================================
local enable = {
  noice      = true,  -- modern cmdline, messages, popups
  dressing   = true,  -- prettier input/select dialogs
  colorizer  = true,  -- inline color previews (e.g. #ff6600)
  surround   = true,  -- alternate surround keybinds (ys/cs/ds)
  devicons   = true,  -- file/folder icons for which-key, telescope, trouble
}

-- ============================================================
-- noice.nvim: modern UI for cmdline, messages, notify
-- ============================================================
if enable.noice then
  vim.pack.add { gh 'folke/noice.nvim' }
  vim.pack.add { gh 'MunifTanjim/nui.nvim' }

  require('noice').setup {
    cmdline = { enabled = true, view = 'cmdline_popup' },
    messages = { enabled = true, view = 'notify' },
    popupmenu = { enabled = true },
    notify = { enabled = true },
    presets = {
      bottom_search = true,
      command_palette = true,
      long_message_to_split = true,
      lsp_doc_border = true,
    },
  }
end

-- ============================================================
-- dressing.nvim: better vim.ui.input / vim.ui.select
-- ============================================================
if enable.dressing then
  vim.pack.add { gh 'stevearc/dressing.nvim' }

  require('dressing').setup {
    input = {
      enabled = true,
      default_prompt = '➤ ',
      relative = 'cursor',
    },
    select = {
      enabled = true,
      backend = { 'telescope', 'fzf', 'builtin' },
      telescope = require('telescope.themes').get_dropdown {},
    },
  }
end

-- ============================================================
-- nvim-colorizer.lua: inline color highlights
-- ============================================================
if enable.colorizer then
  vim.pack.add { gh 'NvChad/nvim-colorizer.lua' }

  require('colorizer').setup {
    '*',
    css = { rgb_fn = true },
    html = { mode = 'foreground' },
  }
end

-- ============================================================
-- devicons: file/folder icons for which-key, telescope, trouble
-- ============================================================
if enable.devicons then
  vim.pack.add { gh 'nvim-tree/nvim-web-devicons' }

  require('nvim-web-devicons').setup {}
end

-- ============================================================
-- nvim-surround: alternate surround keybinds
-- ============================================================
if enable.surround then
  vim.pack.add { gh 'kylechui/nvim-surround' }

  require('nvim-surround').setup {}

  -- Note: mini.surround (from kickstart) is also active.
  -- nvim-surround uses different keybinds:
  --   ysiw)  →  surround word with )
  --   ds"    →  delete surrounding "
  --   cs'"   →  change ' to "
  --
  -- mini.surround uses:
  --   saiw)  →  surround word with )
  --   sd'    →  delete '
  --   sr)'   →  change ) to '
  --
  -- They coexist without conflict.
end
