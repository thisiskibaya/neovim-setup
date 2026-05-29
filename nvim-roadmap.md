# Neovim Development Roadmap

**Base**: kickstart.nvim on Neovim v0.12.2  
**Plugin Manager**: `vim.pack` (built-in)  
**Theme**: tokyonight-night  
**Config**: `~/.config/nvim/init.lua`

---

## Current State

### Mason — LSP Servers & Tools

| Tool | Purpose | Language | Install Method |
|---|---|---|---|
| `clangd` | LSP server | C, C++ | Mason |
| `clang-format` | Formatter | C, C++ | Mason |
| `rust-analyzer` | LSP server | Rust | Mason |
| `typescript-language-server` | LSP server | JavaScript, TypeScript | Mason |
| `prettier` | Formatter | JS, TS, TSX, JSON, HTML, CSS | Mason |
| `stylua` | Formatter | Lua | Mason |
| `gopls` (v0.22.0) | LSP server | Go | `go install` |
| `rustfmt` | Formatter | Rust | rustup component |

### Treesitter Parsers (18 installed)

```
bash, c, cpp, diff, go, html, javascript, json,
lua, luadoc, markdown, markdown_inline, query,
rust, tsx, typescript, vim, vimdoc
```

### Conform — Formatter Mapping (manual via `<leader>f`)

| Filetype(s) | Formatter |
|---|---|
| `c`, `cpp` | `clang-format` |
| `rust` | `rustfmt` |
| `go` | `gofmt` |
| `javascript`, `typescript`, `typescriptreact`, `javascriptreact` | `prettier` |
| `json`, `html`, `css` | `prettier` |

### Core Keymaps

| Shortcut | Action |
|---|---|
| `<leader>f` | Format buffer |
| `<space>sh` | Search help |
| `<space>sf` | Find files |
| `<space>sg` | Live grep |
| `grr` | LSP references |
| `grd` | LSP definition |
| `grn` | LSP rename |
| `gra` | LSP code action |
| `<leader>q` | Open diagnostics list |
| `<C-h/j/k/l>` | Window navigation |

---

## Phase 1 — Debugging (DAP)

**Status**: ✅ Implemented

**Goal**: Step-through debugging for C++, Rust, Go, and JavaScript/TypeScript with a visual debugger UI.

### Implementation

Created `~/.config/nvim/lua/custom/plugins/dap.lua` which handles everything below.  
Auto-loaded via `~/.config/nvim/lua/custom/plugins/init.lua` (the kickstart module loader).

### Plugins Installed

| Plugin | Purpose | vim.pack Add |
|---|---|---|
| `mfussenegger/nvim-dap` | Core DAP client | ✅ |
| `nvim-neotest/nvim-nio` | Async IO library (dependency of dap-ui) | ✅ |
| `rcarriga/nvim-dap-ui` | Floating panels: breakpoints, stack frames, variables, watches | ✅ |
| `theHamsta/nvim-dap-virtual-text` | Show variable values inline as virtual text | ✅ |
| `jay-babu/mason-nvim-dap.nvim` | Mason bridge — auto-install debug adapters | ✅ |

### Debug Adapters

| Adapter | Language | Installed Via | Binary Location |
|---|---|---|---|
| `codelldb` | C, C++, Rust | Mason | `~/.local/share/nvim/mason/bin/codelldb` |
| `js-debug-adapter` | JavaScript, TypeScript | Mason | `~/.local/share/nvim/mason/bin/js-debug-adapter` |
| `debugpy` | Python | Mason | (available for future use) |
| `dlv` (delve) | Go | `go install` | `~/go/bin/dlv` |

### Adapter Configurations

**C++ / Rust** — codelldb via Mason:
```lua
dap.adapters.lldb = {
  type = 'server',
  port = '${port}',
  executable = {
    command = vim.fn.stdpath 'data' .. '/mason/bin/codelldb',
    args = { '--port', '${port}' },
  },
}
```
Prompts for the executable path on first launch.

**Go** — delve:
```lua
dap.adapters.dlv = {
  type = 'server',
  port = '${port}',
  executable = {
    command = vim.fn.expand '~/go/bin/dlv',
    args = { 'dap', '-l', '127.0.0.1:${port}' },
  },
}
```
Launches from the current working directory.

**JavaScript / TypeScript** — js-debug-adapter via Mason:
```lua
dap.adapters['pwa-node'] = {
  type = 'server',
  host = '127.0.0.1',
  port = '${port}',
  executable = {
    command = vim.fn.stdpath 'data' .. '/mason/bin/js-debug-adapter',
    args = { '${port}' },
  },
}
```
Launches the current file as a Node.js process.

### Keymaps

| Shortcut | Action | Mode |
|---|---|---|
| `<leader>db` | Toggle breakpoint | Normal |
| `<leader>dB` | Conditional breakpoint | Normal |
| `<leader>dc` | Continue | Normal |
| `<leader>do` | Step over | Normal |
| `<leader>di` | Step into | Normal |
| `<leader>dO` | Step out | Normal |
| `<leader>dr` | Restart | Normal |
| `<leader>dq` | Quit (terminate) | Normal |
| `<leader>du` | Toggle DAP UI panels | Normal |

### Auto-UI Behavior

DAP UI opens automatically when a debug session starts and closes when the session ends:
```lua
dap.listeners.after.event_initialized['dapui_config'] = dapui.open
dap.listeners.after.event_terminated['dapui_config'] = dapui.close
dap.listeners.after.event_exited['dapui_config'] = dapui.close
```

### How to Debug

1. Open a `.cpp`, `.rs`, `.go`, or `.ts/.tsx` file
2. Set a breakpoint: `<leader>db`
3. Start debugging: `<leader>dc`
4. For C++/Rust: type the path to your compiled executable
5. Use step controls: `<leader>do` (over), `<leader>di` (into), `<leader>dO` (out)
6. Inspect variables: virtual text shows inline; DAP UI shows structured data
7. End session: `<leader>dq`

---

## Phase 2 — Navigation & Project Management

**Status**: ✅ Implemented

**Goal**: Fast file switching, project awareness, file tree, and quick motion.

### Implementation

Created `~/.config/nvim/lua/custom/plugins/navigation.lua`.

### Plugins Installed

| Plugin | Purpose | vim.pack Add |
|---|---|---|
| `nvim-neo-tree/neo-tree.nvim` | File tree explorer with git status, diagnostics | ✅ |
| `folke/flash.nvim` | Jump anywhere on screen with 1-2 keystrokes | ✅ |
| `ahmedkhalf/project.nvim` | Project root detection for Telescope | ✅ |

### Tools

| Plugin | Key Feature |
|---|---|
| **neo-tree** | Left sidebar file tree; `l` to open, `h` to collapse; git status icons; dotfiles visible |
| **flash** | Overrides `s`/`S` for on-screen label jump (replaces `f`/`t`/`F`/`T` workflow) |
| **project.nvim** | Detects project root via `.git`, `Makefile`, `Cargo.toml`, `go.mod`, `package.json`, `CMakeLists.txt` |
| **Telescope** (existing) | `<leader>sf` find files, `<leader><leader>` buffers, `<leader>s.` recent files — covers the harpoon use case |

### Keymaps

| Shortcut | Action | Plugin |
|---|---|---|
| `<leader>pv` | Toggle neo-tree file explorer | neo-tree |
| `s` | Flash jump forward | flash |
| `S` | Flash jump backward | flash |
| `<leader>fp` | List projects (Telescope) | project.nvim |

### Notes

- **Harpoon was dropped** due to a JSON serialization bug in the installed version. Telescope buffers (`<leader><leader>`), recent files (`<leader>s.`), and flash jumps cover the same workflow with zero bugs.
- Flash overrides the built-in `s`/`S` keys (which normally move to the next/previous character). If you need `s` back, disable flash's char mode in the config.

---

## Phase 3 — Git

**Status**: ✅ Implemented

**Goal**: Magit-like staged/unstaged workflow, better diff viewing, conflict resolution.

### Implementation

Created `~/.config/nvim/lua/custom/plugins/git.lua`.  
Enabled gitsigns keymaps in `init.lua` via `require 'kickstart.plugins.gitsigns'`.

### Plugins Installed

| Plugin | Purpose | vim.pack Add |
|---|---|---|
| `NeogitOrg/neogit` | Full magit porcelain (stage, commit, branch, push, pull, log) | ✅ |
| `sindrets/diffview.nvim` | Side-by-side diffs, file history, merge conflict resolution | ✅ |
| `lewis6991/gitsigns.nvim` | Git signs in the gutter (was already installed, now hunk keymaps enabled) | ✅ (enable extra) |

### How to Use

**Neogit** — `<leader>gg` opens the neogit status screen in a new tab:
- `s` / `S` — stage/unstage file or hunk
- `c` — commit
- `P` — push
- `F` — pull
- `l` — log
- `$` — rebase
- `?` — show keymap help
- `q` — close

**Diffview** — `<leader>gd` opens the diff panel:
- Shows unstaged/staged changes side-by-side
- `<leader>gh` opens file history for the current buffer
- Tab-completion for branch range (e.g. `main..HEAD`)

**Gitsigns Hunk Keymaps** (from `kickstart.plugins.gitsigns` extra):

| Shortcut | Action |
|---|---|
| `]h` / `[h` | Next/previous hunk |
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |
| `<leader>hS` | Stage buffer |
| `<leader>hu` | Undo stage hunk |
| `<leader>hp` | Preview hunk |
| `<leader>hb` | Blame line |
| `<leader>hd` | Diff this file |
| `<leader>hB` | Full blame (with commit info) |

### Keymaps

| Shortcut | Action | Plugin |
|---|---|---|
| `<leader>gg` | Open neogit status | neogit |
| `<leader>gd` | Open diffview | diffview.nvim |
| `<leader>gh` | File history | diffview.nvim |
| `]h` / `[h` | Next/previous hunk | gitsigns (extra) |
| `<leader>hs` | Stage hunk | gitsigns (extra) |
| `<leader>hr` | Reset hunk | gitsigns (extra) |
| `<leader>hb` | Blame line | gitsigns (extra) |
| `<leader>hd` | Diff file | gitsigns (extra) |

---

## Phase 4 — Code Quality

**Status**: ✅ Implemented

**Goal**: Async linting beyond LSP diagnostics, better diagnostics browsing.

### Implementation

Created `~/.config/nvim/lua/custom/plugins/lint.lua`.

### Plugins Installed

| Plugin | Purpose | vim.pack Add |
|---|---|---|
| `mfussenegger/nvim-lint` | Async linter runner — runs on save | ✅ |
| `folke/trouble.nvim` | Structured, filterable diagnostics list | ✅ |

### Linters by Filetype

| Filetype | Linter | Install Method |
|---|---|---|
| `c`, `cpp` | `clang-tidy` | Symlinked from llvm-17 to `~/.local/bin` |
| `rust` | `clippy` | Symlinked from rustup toolchain to `~/.local/bin` |
| `go` | `staticcheck` | `go install` |
| `javascript`, `typescript`, `typescriptreact`, `javascriptreact` | `eslint_d` | Mason (installed as `eslint_d`) |

Linters run automatically on `BufWritePost` (every save).

**ESLint note**: `eslint.config.js` at the repo root uses only ESLint's built-in rules. `eslint_d` (installed via Mason) bundles its own eslint, so no project-level npm packages are needed for basic linting. The config applies to any JS/TS project opened with this Neovim config.

### Keymaps

| Shortcut | Action | Plugin |
|---|---|---|
| `<leader>xx` | Toggle trouble list | trouble.nvim |
| `<leader>xw` | Workspace diagnostics | trouble.nvim |
| `<leader>xd` | Document diagnostics | trouble.nvim |
| `<leader>xl` | Loclist | trouble.nvim |
| `<leader>xq` | Quickfix list | trouble.nvim |

---

## Phase 5 — Language-Specific

**Status**: ✅ Implemented

### Implementation

Created `lang-cpp.lua`, `lang-rust.lua`, `lang-go.lua`, `lang-ts.lua` in `lua/custom/plugins/`.

### C++

| Plugin | Purpose | File |
|---|---|---|
| `Civitasv/cmake-tools.nvim` | Configure, build, test, run CMake projects | `lang-cpp.lua` |
| `p00f/clangd_extensions.nvim` | Inlay hints, type hierarchy, memory usage | `lang-cpp.lua` |

| Shortcut | Action |
|---|---|
| `<leader>cc` | CMake: configure |
| `<leader>cb` | CMake: build |
| `<leader>ct` | CMake: test |
| `<leader>cr` | CMake: run |
| `<leader>cT` | CMake: select target |

cmake-tools auto-generates on save, soft-links `compile_commands.json`, and supports DAP with codelldb.

### Rust

| Plugin | Purpose | File |
|---|---|---|
| `saecki/crates.nvim` | Crate version management in `Cargo.toml` | `lang-rust.lua` |

| Shortcut | Action |
|---|---|
| `<leader>rc` | Show crate updates |
| `<leader>ru` | Update crate at cursor |
| `<leader>rU` | Upgrade all crates |

Works in `Cargo.toml` files — shows inline diagnostics for outdated crates.

### Go

| Plugin | Purpose | File |
|---|---|---|
| `ray-x/go.nvim` | Build, test, coverage, alternate file, AI integration | `lang-go.lua` |

| Shortcut | Action |
|---|---|
| `<leader>gr` | Go: run |
| `<leader>gb` | Go: build |
| `<leader>gt` | Go: test (nearest function) |
| `<leader>ga` | Go: test all |
| `<leader>gc` | Go: coverage |

Provides additional commands via `:GoAlt`, `:GoDoc`, `:GoImpl`, etc.

### JavaScript / TypeScript

Sticking with `ts_ls` (typescript-language-server via Mason) which handles definition, references, rename, completion, and diagnostics. If you want more advanced features (project-wide actions, separate tsconfig handling), `typescript-tools.nvim` is documented in `lang-ts.lua` — just uncomment and remove `ts_ls` from the servers list in `init.lua`.

---

## Phase 6 — Productivity

**Status**: ✅ Implemented

**Goal**: Speed up everyday editing.

### Implementation

Created `~/.config/nvim/lua/custom/plugins/productivity.lua`.  
Enabled friendly-snippets in `init.lua` (uncommented existing code).

### Plugins Installed

| Plugin | Purpose | Config |
|---|---|---|
| `rafamadriz/friendly-snippets` | Pre-made snippet library for all languages | `luasnip.loaders.from_vscode.lazy_load()` in `init.lua` |
| `windwp/nvim-autopairs` | Auto-close brackets, quotes, parens | Treesitter-aware, enabled |
| `RRethy/vim-illuminate` | Auto-highlight word under cursor | Defaults (200ms delay, LSP + treesitter providers) |
| `iamcco/markdown-preview.nvim` | Live HTML preview of markdown in browser | `<leader>mp` to toggle |

### Keymaps

| Shortcut | Action | Plugin |
|---|---|---|
| `<leader>mp` | Toggle markdown preview | markdown-preview.nvim |

Snippets expand automatically via luasnip + blink.cmp integration (Tab to accept).  
Autopairs work globally with treesitter awareness (no keymap needed).  
Illuminate highlights all occurrences of word under cursor after 200ms idle.

### Not Implemented

- **AI (Copilot/CodeCompanion)** — requires subscription or API key; add later if desired
- **AI chat keymaps** (`<leader>cc`, `<leader>cC`) — available if you install codecompanion.nvim later

---

## Phase 7 — Polish

**Status**: ✅ Implemented

**Goal**: Refine the visual experience with toggle-able cosmetics.

### Implementation

Created `~/.config/nvim/lua/custom/plugins/polish.lua`.  
All features have individual toggle flags at the top of the file.

### Toggle System

Edit `polish.lua` and flip any flag to `false`, then restart nvim:

```lua
local enable = {
  noice      = true,  -- modern cmdline, messages, popups
  dressing   = true,  -- prettier input/select dialogs
  colorizer  = true,  -- inline color previews (e.g. #ff6600)
  surround   = true,  -- alternate surround keybinds (ys/cs/ds)
}
```

Set to `false` → plugin is not loaded, not required, not configured.

### Plugin Details

| Plugin | What it changes | Disable by setting to `false` |
|---|---|---|
| **noice.nvim** | Replaces `:` cmdline with popup, messages become notifications, `:help` gets a border | `enable.noice = false` |
| **dressing.nvim** | Gives LSP rename, code action pickers, and `vim.ui.select` a Telescope-style popup | `enable.dressing = false` |
| **nvim-colorizer.lua** | Highlights `#ff6600`, `rgb(...)`, color names in CSS/HTML with their actual color | `enable.colorizer = false` |
| **nvim-surround** | `ysiw)` to wrap word, `ds"` to delete quotes, `cs'"` to change quotes (coexists with mini.surround) | `enable.surround = false` |

### Surround Keybind Comparison

| Action | mini.surround (kickstart) | nvim-surround (polish) |
|---|---|---|
| Add parens around word | `saiw)` | `ysiw)` |
| Delete quotes | `sd'` | `ds"` |
| Change `'` to `"` | `sr)'` | `cs'"` |

Both are active. Use whichever feels natural.

---

## Phase 8 — Agentic AI

**Status**: ✅ Implemented

**Goal**: AI-assisted coding with chat, inline transformations, and agentic tools — using GitHub Copilot via CodeCompanion.

### Implementation

Created `~/.config/nvim/lua/custom/plugins/ai.lua`.  
Uses GitHub Copilot as the LLM adapter (zero API keys — reuses your existing GitHub auth).

### Plugins Installed

| Plugin | Purpose | vim.pack Add |
|---|---|---|
| `olimorris/codecompanion.nvim` | AI chat, inline transformations, agentic tools | ✅ |
| `nvim-lua/plenary.nvim` | Dependency for CodeCompanion | ✅ |

### Features

- **Chat buffer** (`<leader>cc`) — ask questions, refactor, explain code, generate tests
- **Inline transformations** (`ga` in visual mode) — select code, describe the change, apply the diff
- **Action palette** (`<leader>ce`) — built-in prompts: fix LSP errors, explain code, add docstrings
- **Agent tools** — `@run_command` (execute terminal commands), `@files` (read/write project files), `@insert_edit_into_file`
- **MCP support** — plug into external MCP servers for custom tools
- **blink.cmp integration** — `@` completion in chat for context, tools, and slash commands

### Keymaps

| Shortcut | Action | Mode |
|---|---|---|
| `<leader>cc` | Open chat buffer | Normal, Visual |
| `<leader>cC` | Open chat in vertical split | Normal, Visual |
| `ga` | Inline transformation | Visual |
| `<leader>ce` | Action palette | Normal |

### How to Use

1. **Chat**: `<leader>cc` opens a right-side chat buffer. Type your question or use `@` to tag files, tools, or context.
2. **Inline**: Select code with `V` or `v`, then press `ga` and describe the change. Review the diff, accept or reject.
3. **Actions**: `<leader>ce` opens the action palette — pick "Explain code", "Add docstrings", "Fix LSP diagnostics", etc.
4. **Tools**: In chat, type `@run_command` to let the AI run terminal commands, or `@files` to read/write files.

---

## Recommended Implementation Order

```
✅ Phase 1  →  Debugging (DAP)
✅ Phase 2  →  Navigation & Projects
✅ Phase 3  →  Git                    (neogit, diffview)
✅ Phase 4  →  Code Quality           (linters, trouble)
✅ Phase 5  →  Language-specific      (CMake, crates, go.nvim)
✅ Phase 6  →  Productivity           (snippets, autopairs)
✅ Phase 7  →  Polish                 (noice, dressing, colorizer)
✅ Phase 8  →  Agentic AI             (CodeCompanion + Copilot)
```

---

## Config Organization

As phases accumulate, split `init.lua` into a modular structure:

```
~/.config/nvim/
├── init.lua                       ← leaders, options, colorscheme, core mappings
└── lua/
    ├── core/
    │   ├── options.lua
    │   ├── keymaps.lua
    │   └── autocmds.lua
    └── plugins/
        ├── dap.lua
        ├── navigation.lua
        ├── git.lua          ← Phase 3 ✅
        ├── lint.lua          ← Phase 4 ✅
        ├── lang-cpp.lua      ← Phase 5 ✅
        ├── lang-rust.lua     ← Phase 5 ✅
        ├── lang-go.lua       ← Phase 5 ✅
        ├── lang-ts.lua       ← Phase 5 ⬜ (optional)
        ├── productivity.lua  ← Phase 6 ✅
        └── ai.lua            ← Phase 8 ✅ (Agentic AI)
```

Each plugin file calls `vim.pack.add(...)` followed by `.setup()`.  
When the kickstart `init.lua` would grow too large, the modular approach keeps it maintainable.
