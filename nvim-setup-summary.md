# Neovim Setup Summary

**Version**: NVIM v0.12.2  
**Config**: [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) (modified)  
**Plugin Manager**: `vim.pack` (built-in, Neovim 0.11+)


## Important Keys

- `
- v
- space <leader>

---

## Mason — LSP Servers & Tools

### What is Mason?

Mason is a Neovim plugin that **manages external editor tools** — LSP servers, linters, formatters, DAP servers, and more. Instead of manually installing each tool with a different package manager (apt, npm, cargo, go install, etc.) and managing their paths, Mason provides a single consistent UI and API for installing, updating, and removing them.

Think of it as a **language-tool package manager** purpose-built for Neovim.

### Why use Mason?

Before Mason, you had to:

- Install `clangd` via your system package manager (`apt install clangd`), which is often outdated
- Install `typescript-language-server` via npm (`npm i -g typescript-language-server`), polluting your global node_modules
- Install `rust-analyzer` via rustup, `gopls` via `go install` — each with its own update mechanism
- Manually ensure every binary is on `$PATH` for Neovim to find

Mason solves all of this by:

1. **Installing tools to `~/.local/share/nvim/mason/bin/`** — a single, isolated directory Neovim knows about
2. **Providing version-pinned, pre-built binaries** when possible (no compilation needed for most tools)
3. **Keeping tools separate from your system** — no global npm packages, no apt污染, no `go install` clutter
4. **Auto-adding that directory to Neovim's `$PATH`** — LSP configs like `nvim-lspconfig` find them automatically
5. **Allowing declarative config** — list what you want, Mason ensures they're installed

### How does it work in this setup?

```
init.lua
  ↓
mason.nvim (.setup {})              ← enables the Mason UI & registry
  ↓
mason-lspconfig.nvim                ← bridges Mason ↔ nvim-lspconfig
  ↓
mason-tool-installer.nvim           ← auto-installs everything at startup
  ↓
  ensure_installed = {
    'clangd', 'gopls', 'rust_analyzer', 'ts_ls',   ← LSP servers
    'clang-format', 'prettier',                     ← formatters
  }
```

On first launch, `mason-tool-installer.nvim` iterates over `ensure_installed`, finds each tool in Mason's registry, downloads it, and places the binary in `~/.local/share/nvim/mason/bin/`. Subsequent launches are no-ops — it's already installed.

Mason's registry (https://github.com/mason-org/mason-registry) maps tool names to download URLs, version checks, and platform-specific binaries. It supports Linux, macOS, and Windows out of the box.

### Inspecting and managing manually

| Command | What it does |
|---|---|
| `:Mason` | Open the interactive Mason TUI |
| `:Mason install <name>` | Install a specific tool |
| `:Mason uninstall <name>` | Remove a tool |
| `:Mason update` | Update all installed tools |
| `g?` | (In Mason TUI) Show keybind help |

### Installed via Mason

| Tool | Purpose | Language | Install source |
|---|---|---|---|
| `clangd` | LSP server | C, C++ | Pre-built LLVM binary |
| `clang-format` | Formatter | C, C++ | Pre-built LLVM binary |
| `rust-analyzer` | LSP server | Rust | Pre-built rust-analyzer binary |
| `typescript-language-server` | LSP server | JavaScript, TypeScript | npm (vendored by Mason) |
| `prettier` | Formatter | JS, TS, TSX, JSON, HTML, CSS | npm (vendored by Mason) |
| `stylua` | Formatter | Lua | Pre-built binary |
| `eslint_d` | Linter | JavaScript, TypeScript | npm (vendored by Mason) |

### Installed outside Mason

| Tool | How installed | Why not Mason |
|---|---|---|
| `gopls` (v0.22.0) | `go install golang.org/x/tools/gopls@latest` | Mason's gopls download timed out during headless install; `go install` is the canonical method and stays in sync with Go toolchain updates |
| `rustfmt` | `rustup component add rustfmt` | Rust toolchain component, not a standalone binary |
| `cargo` | `rustup` | The Rust build system |
| `node` / `npm` | `nvm` | The JS runtime itself |

---

## Treesitter Parsers — Syntax Highlighting

All 18 parsers compiled and installed:

```
bash, c, cpp, diff, go, html, javascript, json,
lua, luadoc, markdown, markdown_inline, query,
rust, tsx, typescript, vim, vimdoc
```

---

## Conform — Formatting

Filetype-to-formatter mapping in `init.lua`:

| Filetype(s) | Formatter |
|---|---|
| `c`, `cpp` | `clang-format` |
| `rust` | `rustfmt` |
| `go` | `gofmt` |
| `lua` | `stylua` |
| `lua` | `stylua` |
| `javascript`, `typescript`, `typescriptreact`, `javascriptreact` | `prettier` |
| `json`, `html`, `css` | `prettier` |

Format on save: **disabled** (manual via `<leader>f`).

---

## Linting (nvim-lint)

Async linters run automatically on every save via `lua/custom/plugins/lint.lua`:

| Filetype(s) | Linter | Installed via |
|---|---|---|
| `c`, `cpp` | `clang-tidy` | System (symlinked from llvm-17) |
| `rust` | `clippy` | rustup component |
| `go` | `staticcheck` | `go install` |
| `javascript`, `typescript`, `typescriptreact`, `javascriptreact` | `eslint_d` | Mason |

**ESLint config** (`eslint.config.js` at repo root) uses only built-in ESLint rules — no project-level npm dependencies required. `eslint_d` from Mason bundles its own eslint, so it works out of the box on any JS/TS project.

---

## Agentic AI (CodeCompanion + Copilot)

AI-assisted coding via `lua/custom/plugins/ai.lua` using the Copilot adapter. Requires `copilot.lua` for authentication (inline suggestions disabled — chat only).

**Full agentic tool support** ✅ — the Copilot adapter supports function calling and agentic tools (`@run_command`, `@files`, `@{agent}`, etc.).

### Features

| Feature | Trigger | What it does |
|---|---|---|
| **Chat buffer** | `<leader>cc` | Right-side chat. Ask questions, refactor, generate code. |
| **Agent mode** | `@{agent}` in chat | Autonomous agent: reads/writes files, runs commands, greps, checks diagnostics. |
| **File tools** | `@{files}` | Scaffold, read, edit, create, delete files. |
| **Inline transformation** | `ga` (visual) | Select code, describe change, apply diff. |
| **Action palette** | `<leader>ce` | Built-in prompts: explain, fix, test, docstring. |
| **Slash commands** | `/file`, `/buffer`, `/fetch` | Add context from files, buffers, URLs. |
| **Tools** | `@tool_name` | `run_command`, `grep_search`, `insert_edit_into_file`, `memory`, `web_search`, etc. |
| **MCP servers** | Configurable | Connect external MCP servers for custom tools. |

### Quick Start

1. `:Copilot auth` — authorize Copilot in your browser
2. If CodeCompanion reports "token not found" after auth, run:
   ```bash
   sqlite3 ~/.config/github-copilot/auth.db \
     "SELECT oauth_token FROM oauth_tokens;" \
     | head -1 \
     | xargs -I{} sh -c \
       'echo "{\"github.com\":{\"oauth_token\":\"{}\"}}" > ~/.config/github-copilot/hosts.json'
   ```
3. `<leader>ai` — open chat
4. Type `@{agent} Add input validation to this form` — full agentic mode
5. Or just ask a question like `Explain this file`

**Why this is needed:** The Copilot LSP stores tokens in SQLite (`auth.db`) but CodeCompanion reads JSON (`hosts.json`). A Phase 9 improvement could automate this bridge.

---

## Keymaps

| Shortcut | Action |
|---|---|
| `<leader>f` | Format buffer |
| `<space>sh` | Search help |
| `<space>sf` | Find files |
| `<space>sg` | Live grep |
| `<space>ss` | Search Telescope pickers |
| `grr` | LSP references |
| `grd` | LSP definition |
| `gri` | LSP implementation |
| `grn` | LSP rename |
| `gra` | LSP code action |
| `<leader>q` | Open diagnostics list |
| `<C-h/j/k/l>` | Window navigation |
| `<leader>ai` | Open AI chat | CodeCompanion |
| `<leader>aA` | Open AI chat (vertical split) | CodeCompanion |
| `ga` | Inline AI transformation (visual mode) | CodeCompanion |
| `<leader>ce` | AI action palette | CodeCompanion |

---

## Config Location

```
~/.config/nvim/init.lua
```

Key modifications from upstream kickstart (all in `init.lua`):
1. Uncommented `clangd`, `gopls`, `rust_analyzer`, `ts_ls` in the `servers` table
2. Added `clang-format` and `prettier` to Mason `ensure_installed`
3. Replaced `formatters_by_ft` with C++, Rust, Go, JS/TS formatter mappings
4. Added `cpp`, `rust`, `go`, `javascript`, `typescript`, `tsx`, `json` to treesitter parsers
5. Added `lua = { 'stylua' }` to conform formatters (Lua formatting)
6. Added `eslint_d` to linters with `eslint.config.js` at repo root (zero npm deps)
7. Added CodeCompanion.nvim with Copilot adapter for agentic AI (`lua/custom/plugins/ai.lua`)

## Nerd Font — Icons & Glyphs

which-key, telescope, neo-tree, and other UI plugins use Nerd Font glyphs for icons (folder arrows, file type icons, git status symbols, etc.). Without a Nerd Font, these show as blank boxes or question marks.

### Installation

```bash
# Download a Nerd Font (e.g. JetBrainsMono)
mkdir -p ~/.local/share/fonts
curl -fLo ~/.local/share/fonts/JetBrainsMonoNerdFont-Regular.ttf \
  "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/Ligatures/Regular/JetBrainsMonoNerdFont-Regular.ttf"

# Update font cache
fc-cache -fv ~/.local/share/fonts/
```

### Terminal Configuration

Set the font in your terminal emulator to the installed Nerd Font.

**Ptyxis (GNOME)**:
```bash
# Find your profile UUID first:
dconf dump /org/gnome/Ptyxis/
# Replace UUID with yours:
dconf write /org/gnome/Ptyxis/profiles/<uuid>/font "'JetBrainsMono Nerd Font 11'"
```

**Other terminals**: Set the font to `JetBrainsMono Nerd Font` in the terminal preferences UI.

Requires a terminal restart to take effect.

---

## Core Configuration

### Mouse

Mouse is **fully disabled** (`vim.o.mouse = ''` in `init.lua:116`). The cursor only follows keyboard input — clicking in a buffer never moves the cursor. This matches classic Vim behavior and avoids accidental cursor jumps.

To re-enable: change `vim.o.mouse = ''` to `vim.o.mouse = 'a'` (all modes) or `vim.o.mouse = 'n'` (normal mode only, click = cursor follows but can still resize splits).

### Autocmd: Cursor Restore

On `BufReadPost`, the `'"` mark is used to restore the cursor to its last known position when reopening a file. No plugin needed — purely built-in. See `init.lua` for the implementation.

---

## Symlink Setup

This repo is symlinked to `~/.config/nvim` so the live config is always in sync:

```bash
rm -rf ~/.config/nvim
ln -s /home/yusuf/Projects/neovim ~/.config/nvim
```

After that, editing in Neovim = editing the repo, and `git pull` in the repo updates the live config instantly.
