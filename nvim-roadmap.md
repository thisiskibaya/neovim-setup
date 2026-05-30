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

**Goal**: AI-assisted coding with agentic tools, inline transformations, and autonomous agents — using GitHub Copilot via CodeCompanion.

### Dependencies

| Dependency | Role | Status |
|---|---|---|
| Neovim >= 0.10.0 | Runtime | ✅ v0.12.2 |
| `plenary.nvim` | Async I/O, utilities | ✅ Installed |
| `copilot.lua` | Copilot authentication & API bridge (inline suggestions disabled) | ✅ Installed |
| GitHub Copilot subscription | API access | Required at github.com/settings/copilot |

**Copilot adapter supports full tool use** ✅ — unlike the `github_models` adapter which is chat-only.

### Implementation

Created `~/.config/nvim/lua/custom/plugins/ai.lua`.  
Auto-loaded via `lua/custom/plugins/init.lua` (the kickstart module loader).

Full configuration:

```lua
require('copilot').setup {
  suggestion = { enabled = false },  -- Chat only, no inline completions
  panel = { enabled = false },
}

require('codecompanion').setup {
  strategies = {
    chat = { adapter = 'copilot' },    -- Full agentic tool support
    inline = { adapter = 'copilot' },
  },
  display = {
    chat = {
      window = {
        layout = 'vertical',   -- Right sidebar
        width = 0.4,
      },
    },
  },
  opts = { log_level = 'INFO' },
}
```

### Plugins Installed

| Plugin | Purpose | vim.pack Add |
|---|---|---|
| `olimorris/codecompanion.nvim` | AI chat, inline transformations, agentic tools | ✅ |
| `zbirenbaum/copilot.lua` | Copilot auth & API bridge (required by copilot adapter) | ✅ |
| `nvim-lua/plenary.nvim` | Async I/O and utility library (dependency) | ✅ |

### Agentic Features

| Feature | Trigger | Description |
|---|---|---|
| **Chat buffer** | `<leader>cc` | Right-side chat. Ask questions, request refactors, generate code. |
| **Inline transformation** | `ga` (visual) | Select code, press `ga`, describe change. Accept diff with `<C-y>`. |
| **Action palette** | `<leader>ce` | Built-in prompts: explain code, add docstrings, fix LSP errors, write tests. |
| **Agent mode** | `@{agent}` in chat | Full autonomous agent with 10 tools. Reads/writes files, runs commands, greps, checks diagnostics, asks clarifying questions. |
| **File tools** | `@{files}` in chat | Scaffold projects, read/edit/create files, grep search, git diff awareness. |
| **Individual tools** | `@tool_name` | `@run_command`, `@insert_edit_into_file`, `@grep_search`, `@file_search`, `@read_file`, `@create_file`, `@delete_file`, `@get_diagnostics`, `@get_changed_files`, `@fetch_webpage`, `@memory` |
| **Slash commands** | `/command` in chat | `/file`, `/buffer`, `/fetch` (URL), `/help`, `/symbols`, `/compact`, `/image`, `/mcp` |
| **Editor context** | `#variable` | `#buffer` (current buffer), `#lsp` (LSP diagnostics), `#problems` (all diagnostics) |
| **MCP servers** | Config | Connect external MCP servers (databases, APIs, etc.) for custom tools |
| **blink.cmp** | `@` / `#` / `/` | Autocomplete for tools, context, and slash commands in chat buffer |

### Tool Security

Tools that modify files (`create_file`, `delete_file`, `insert_edit_into_file`) and run commands (`run_command`) require **user approval** by default. Approvals are tracked per-tool per-buffer. YOLO mode (`gty`) bypasses approval for non-destructive tools.

### Keymaps

| Shortcut | Action | Mode |
|---|---|---|
| `<leader>ai` | Open AI chat buffer (right sidebar) | Normal, Visual |
| `<leader>aA` | Open AI chat in vertical split | Normal, Visual |
| `ga` | Inline AI transformation | Visual |
| `<leader>ce` | Open action palette | Normal |

### How to Use

#### 1. Chat (`<leader>ai`)

```
<leader>ai → type message → <C-Enter> to send
```

Use `@` for tools and context:

- `@{agent} Refactor the auth module to use JWT` — full autonomous agent
- `@{files} Scaffold a new React component` — file operations
- `@run_command Run npm test` — execute terminal commands
- `@buffer` — include current buffer content
- `@lsp` — include LSP diagnostics

#### 2. Agent Mode (`@{agent}`)

The most powerful feature. Include `@{agent}` in your prompt to give the LLM full agentic access:

- Reads/writes/creates/deletes files
- Runs shell commands (with approval)
- Searches code with grep
- Checks LSP diagnostics
- Asks clarifying questions when stuck
- Edits buffers with diff review

Example: `@{agent} Add input validation to the signup form. Check for existing tests first.`

#### 3. Inline (`ga`)

1. Visually select code
2. Press `ga`
3. Describe the transformation
4. Review the diff — `<C-y>` accept, `<C-x>` reject

#### 4. Action Palette (`<leader>ce`)

Built-in prompts: explain code, add docstrings, fix LSP errors, write tests, optimize code.

### First-Time Setup

```vim
" 1. Install plugins (run inside Neovim)
:lua vim.pack.update()

" 2. Authenticate Copilot (opens browser)
:Copilot auth

" 3. Verify
:checkhealth codecompanion
```

After `:Copilot auth`, your browser will open to authorize GitHub Copilot. Once complete, `<leader>ai` will work immediately.

**Note on token storage:** The Copilot LSP stores your OAuth token in an SQLite database (`~/.config/github-copilot/auth.db`). CodeCompanion's Copilot adapter reads from `hosts.json` (the VS Code format). If `:Copilot auth` succeeds but CodeCompanion reports "token not found", create `hosts.json` by extracting the token from `auth.db`:

```bash
sqlite3 ~/.config/github-copilot/auth.db "SELECT oauth_token FROM oauth_tokens;" \\
  | head -1 \\
  | xargs -I{} sh -c 'echo "{\"github.com\":{\"oauth_token\":\"{}\"}}" > ~/.config/github-copilot/hosts.json'
```

No restart needed — CodeCompanion reads the file on the next request.

### Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| "Failed to set up adapter" | `copilot.lua` not loaded | Run `:lua vim.cmd.packadd('copilot.lua')` then restart |
| No tools available (ghost menu) | Using wrong adapter | Only `copilot`, `anthropic`, `openai`, `gemini`, `deepseek`, `ollama` support tools |
| `@{agent}` does nothing | Model doesn't support function calling | Ensure Copilot subscription is active |
| `:Copilot auth` fails | No Copilot subscription | Check github.com/settings/copilot |
| Slow git clone on setup | Large repo / slow network | Use `git clone --depth 1` for copilot.lua |
| "Token not found" / auth fails | Copilot LSP stores token in `auth.db` but CodeCompanion reads `hosts.json` | Extract token from `auth.db` → `hosts.json` (see note above) |

---

## Phase 9 — Auth Bridge: `auth.db` → `hosts.json` (Planned)

**Status**: ⬜ Planned

**Goal**: Automate Copilot token extraction from the LSP's SQLite `auth.db` into the `hosts.json` format that CodeCompanion's Copilot adapter expects.

### Problem

The GitHub Copilot ecosystem has two token storage formats:

| Format | File | Used by | Status |
|---|---|---|---|
| JSON | `~/.config/github-copilot/hosts.json` | VS Code, CodeCompanion, avante.nvim | ✅ CodeCompanion reads this |
| JSON | `~/.config/github-copilot/apps.json` | Older copilot.lua versions | ⚠️ Fallback in CodeCompanion |
| SQLite | `~/.config/github-copilot/auth.db` | Copilot LSP (Neovim built-in), copilot.lua v2+ | ❌ CodeCompanion cannot read this |

When `:Copilot auth` runs, copilot.lua delegates to the Copilot LSP, which stores the token in `auth.db`. CodeCompanion's `token.lua` looks for `hosts.json` or `apps.json` — both JSON files that never get created by the LSP auth flow. The result: authentication succeeds but CodeCompanion can't find the token.

### Current Workaround

Manual extraction via `sqlite3`:

```bash
sqlite3 ~/.config/github-copilot/auth.db \
  "SELECT oauth_token FROM oauth_tokens;" \
  | head -1 \
  | xargs -I{} sh -c \
    'echo "{\"github.com\":{\"oauth_token\":\"{}\"}}" > ~/.config/github-copilot/hosts.json'
```

This works but is fragile: if the token is revoked or expires, there's no automated refresh.

### Proposed Solution

Create a small Neovim Lua module or CLI script that bridges the gap:

**Option A: Neovim `token-bridge.lua` plugin file**
- On `VimEnter` or when the Copilot adapter initializes, check if `hosts.json` exists
- If not, check `auth.db` (via `vim.system` calling `sqlite3`)
- If token found in `auth.db`, write `hosts.json` automatically
- Optionally watch the file for changes / refresh on token expiry

**Option B: Standalone shell script (`copilot-token-bridge`)**
- Check if `auth.db` is newer than `hosts.json`
- If so, re-extract the token
- Can be run from cron or as a git hook

**Option C: CodeCompanion adapter patch**
- Contribute a PR to CodeCompanion's `token.lua` to add `auth.db` as a third token source
- Parse SQLite via `vim.system({"sqlite3", path, "SELECT oauth_token FROM oauth_tokens"})`
- No external file needed — read the token directly

### Implementation Notes

- SQLite query: `SELECT oauth_token FROM oauth_tokens WHERE token_type = 'oauth'` — returns the GitHub OAuth token
- The `hosts.json` format is: `{"github.com": {"oauth_token": "<token>", "user": "<username>"}}`
- Token expiry: The OAuth token itself is long-lived. The short-lived Copilot API token is obtained from the OAuth token via `GET https://api.github.com/copilot_internal/v2/token`
- CodeCompanion already handles the OAuth → API token refresh internally once it has the OAuth token

### Files to Modify

| File | Change |
|---|---|
| `lua/custom/plugins/ai.lua` | Add auto-bridge on setup, or add a `:CopilotTokenBridge` command |
| (or) submit upstream to `codecompanion.nvim` | Add `auth.db` support to `lua/codecompanion/adapters/http/copilot/token.lua` |

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
⬜ Phase 9  →  Auth Bridge            (automate token extraction auth.db → hosts.json)
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
        └── ai.lua            ← Phase 8 ✅ (Agentic AI + Copilot)
```

Each plugin file calls `vim.pack.add(...)` followed by `.setup()`.  
When the kickstart `init.lua` would grow too large, the modular approach keeps it maintainable.
