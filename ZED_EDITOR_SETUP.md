# Setting Up Zed Editor for ReiLua Development

Zed is a high-performance, modern code editor built for speed and collaboration. This guide shows you how to set up Zed for the best ReiLua game development experience.

## Why Zed?

- ⚡ **Fast**: Written in Rust, extremely responsive
- 🧠 **Smart**: Built-in AI assistance (optional)
- 🎨 **Beautiful**: Clean, modern interface
- 🔧 **Powerful**: LSP support, multi-cursor editing, vim mode
- 🆓 **Free**: Open source and free to use

## Installation

### Download Zed

Visit https://zed.dev/ and download for your platform:

- **Windows**: Download installer and run
- **Mac**: Download .dmg and install
- **Linux**: 
  ```bash
  curl https://zed.dev/install.sh | sh
  ```

### First Launch

1. Launch Zed
2. Choose your theme (light/dark)
3. Select keybindings (VS Code, Sublime, or default)
4. Optional: Sign in for collaboration features

## Setting Up for ReiLua

### 1. Install Lua Language Server

The Lua Language Server provides autocomplete, error detection, and documentation.

**Method 1: Automatic (Recommended)**
1. Open Zed
2. Open any `.lua` file
3. Zed will prompt to install Lua support
4. Click "Install"

**Method 2: Manual**
1. Press `Ctrl+Shift+P` (Windows/Linux) or `Cmd+Shift+P` (Mac)
2. Type "zed: install language server"
3. Select "Lua"

### 2. Create Workspace Configuration

Create a `.zed` folder in your project root:

```bash
cd your_game_project
mkdir .zed
```

### 3. Configure Lua Language Server

Create `.zed/settings.json` with ReiLua-specific settings:

```json
{
  "lsp": {
    "lua-language-server": {
      "settings": {
        "Lua": {
          "runtime": {
            "version": "Lua 5.4",
            "path": [
              "?.lua",
              "?/init.lua"
            ]
          },
          "diagnostics": {
            "globals": [
              "RL"
            ],
            "disable": [
              "lowercase-global"
            ]
          },
          "workspace": {
            "library": [
              "ReiLua_API.lua"
            ],
            "checkThirdParty": false
          },
          "completion": {
            "callSnippet": "Both",
            "keywordSnippet": "Both"
          },
          "hint": {
            "enable": true,
            "setType": true
          }
        }
      }
    }
  },
  "languages": {
    "Lua": {
      "format_on_save": "on",
      "formatter": "language_server",
      "tab_size": 4,
      "hard_tabs": false
    }
  },
  "tab_size": 4,
  "soft_wrap": "editor_width",
  "theme": "One Dark",
  "buffer_font_size": 14,
  "ui_font_size": 14
}
```

**What this does:**
- Sets Lua 5.4 runtime (matches ReiLua)
- Adds `RL` as a global (prevents "undefined global" warnings)
- Loads ReiLua_API.lua for autocomplete
- Enables format-on-save
- Sets tab size to 4 spaces
- Enables type hints
- Disables third-party library checking (reduces noise)

### 4. Add ReiLua API Definitions

Copy `ReiLua_API.lua` to your project:

```bash
# Windows
copy path\to\ReiLua\ReiLua_API.lua your_game_project\

# Linux/Mac
cp path/to/ReiLua/ReiLua_API.lua your_game_project/
```

This file provides:
- Autocomplete for all 1000+ ReiLua functions
- Function signatures
- Parameter hints
- Documentation tooltips

### 5. Create Tasks Configuration

Create `.zed/tasks.json` for quick commands:

```json
{
  "tasks": [
    {
      "label": "Run Game (Dev)",
      "command": "path/to/ReiLua.exe",
      "args": ["--log", "--no-logo"],
      "cwd": "${workspaceFolder}"
    },
    {
      "label": "Run Game (Production)",
      "command": "path/to/ReiLua.exe",
      "args": [],
      "cwd": "${workspaceFolder}"
    },
    {
      "label": "Run Game with Logging",
      "command": "path/to/ReiLua.exe",
      "args": ["--log"],
      "cwd": "${workspaceFolder}"
    },
    {
      "label": "Build Release",
      "command": "path/to/ReiLua/build_release.bat",
      "cwd": "path/to/ReiLua"
    }
  ]
}
```

**Usage:**
1. Press `Ctrl+Shift+P` / `Cmd+Shift+P`
2. Type "task: spawn"
3. Select your task

Replace `path/to/ReiLua.exe` with the actual path to your ReiLua executable.

## Essential Keyboard Shortcuts

### Navigation

| Shortcut | Action | Description |
|----------|--------|-------------|
| `Ctrl+P` / `Cmd+P` | Quick Open | Jump to any file instantly |
| `Ctrl+Shift+P` / `Cmd+Shift+P` | Command Palette | Access all commands |
| `Ctrl+T` / `Cmd+T` | Go to Symbol | Jump to function/variable |
| `F12` | Go to Definition | Jump to where something is defined |
| `Shift+F12` | Find References | Find all uses of a symbol |
| `Alt+←` / `Alt+→` | Navigate Back/Forward | Like browser navigation |
| `Ctrl+G` / `Cmd+G` | Go to Line | Jump to specific line number |

### Editing

| Shortcut | Action | Description |
|----------|--------|-------------|
| `Ctrl+D` / `Cmd+D` | Add Selection | Select next occurrence |
| `Alt+Click` | Add Cursor | Multiple cursors |
| `Ctrl+Shift+L` / `Cmd+Shift+L` | Select All Occurrences | Multi-cursor all matches |
| `Ctrl+/` / `Cmd+/` | Toggle Comment | Comment/uncomment line |
| `Alt+↑` / `Alt+↓` | Move Line Up/Down | Move current line |
| `Ctrl+Shift+D` / `Cmd+Shift+D` | Duplicate Line | Copy line below |
| `Ctrl+Shift+K` / `Cmd+Shift+K` | Delete Line | Remove entire line |
| `Ctrl+]` / `Cmd+]` | Indent | Indent selection |
| `Ctrl+[` / `Cmd+[` | Outdent | Unindent selection |

### Search

| Shortcut | Action | Description |
|----------|--------|-------------|
| `Ctrl+F` / `Cmd+F` | Find | Search in current file |
| `Ctrl+H` / `Cmd+H` | Replace | Find and replace |
| `Ctrl+Shift+F` / `Cmd+Shift+F` | Find in Files | Search entire project |
| `F3` / `Cmd+G` | Find Next | Next search result |
| `Shift+F3` / `Cmd+Shift+G` | Find Previous | Previous search result |

### View

| Shortcut | Action | Description |
|----------|--------|-------------|
| `Ctrl+\` / `Cmd+\` | Split Editor | Side-by-side editing |
| `` Ctrl+` `` / `` Cmd+` `` | Toggle Terminal | Show/hide terminal |
| `Ctrl+B` / `Cmd+B` | Toggle Sidebar | Show/hide file tree |
| `Ctrl+K Z` / `Cmd+K Z` | Zen Mode | Distraction-free mode |
| `Ctrl+K V` / `Cmd+K V` | Toggle Preview | For markdown files |

### Code

| Shortcut | Action | Description |
|----------|--------|-------------|
| `Ctrl+Space` | Trigger Autocomplete | Force show suggestions |
| `Ctrl+.` / `Cmd+.` | Code Actions | Quick fixes |
| `F2` | Rename Symbol | Rename variable/function |
| `Ctrl+K Ctrl+F` / `Cmd+K Cmd+F` | Format Selection | Format selected code |

## Project Structure Best Practices

### Recommended Layout

```
your_game/
├── .zed/
│   ├── settings.json
│   └── tasks.json
├── assets/
│   ├── images/
│   ├── sounds/
│   └── fonts/
├── lib/
│   └── (your libraries)
├── src/
│   ├── main.lua
│   ├── player.lua
│   ├── enemy.lua
│   └── game.lua
├── ReiLua_API.lua
└── README.md
```

### Using Multiple Folders

Add ReiLua source for reference:

1. File → Add Folder to Workspace
2. Select ReiLua source directory
3. Now you can reference ReiLua code easily

## Advanced Features

### Multi-Cursor Editing

**Use cases:**
- Rename variables in multiple places
- Edit similar lines simultaneously
- Batch formatting

**Example:**
1. Select a variable name
2. Press `Ctrl+D` repeatedly to select more occurrences
3. Type to edit all at once

### Split Editor

Work on multiple files simultaneously:

1. Press `Ctrl+\` to split
2. Open different files in each pane
3. Example: `main.lua` on left, `player.lua` on right

### Vim Mode (Optional)

If you love Vim:

1. `Ctrl+Shift+P` → "zed: toggle vim mode"
2. All Vim keybindings become available
3. Normal, Insert, Visual modes work
4. `:w` to save, `:q` to close, etc.

### Live Grep

Powerful project-wide search:

1. Press `Ctrl+Shift+F`
2. Type your search query
3. Results show in context
4. Click to jump to location

**Search tips:**
- Use regex with `.*` for patterns
- Search by file type: `*.lua`
- Exclude folders: Add to `.gitignore`

### Collaboration (Optional)

Share your coding session:

1. Click "Share" button (top right)
2. Send link to teammate
3. Collaborate in real-time
4. See each other's cursors

## Workflow Tips

### 1. Quick File Switching

```
Ctrl+P → type filename → Enter
```

Example: `Ctrl+P` → "play" → selects `player.lua`

### 2. Symbol Search

```
Ctrl+T → type function name → Enter
```

Example: `Ctrl+T` → "update" → jumps to `function RL.update()`

### 3. Multi-File Editing

1. `Ctrl+Shift+F` → Search for text
2. Results show all occurrences
3. Use multi-cursor to edit across files

### 4. Integrated Terminal

Keep terminal open while coding:

1. `` Ctrl+` `` → Open terminal
2. Split view: code above, terminal below
3. Run `ReiLua.exe --log --no-logo` for testing

### 5. Quick Testing Loop

Set up this workflow:
1. Edit code in Zed
2. Save with `Ctrl+S` (autosave optional)
3. Switch to terminal with `` Ctrl+` ``
4. Press `↑` to recall previous command
5. Press `Enter` to run game

## Troubleshooting

### Lua Language Server Not Working

**Problem**: No autocomplete or diagnostics

**Solutions:**
1. Check LSP status: `Ctrl+Shift+P` → "lsp: show active servers"
2. Restart LSP: `Ctrl+Shift+P` → "lsp: restart"
3. Check `.zed/settings.json` syntax
4. Verify `ReiLua_API.lua` exists in project

### ReiLua Functions Show as Undefined

**Problem**: `RL.DrawText` shows as error

**Solutions:**
1. Add `"RL"` to globals in `.zed/settings.json`:
   ```json
   "diagnostics": {
     "globals": ["RL"]
   }
   ```
2. Restart LSP

### Format on Save Not Working

**Problem**: Code doesn't format when saving

**Solutions:**
1. Check formatter setting:
   ```json
   "languages": {
     "Lua": {
       "format_on_save": "on"
     }
   }
   ```
2. Ensure LSP is running
3. Try manual format: `Ctrl+Shift+F`

### Tasks Not Showing

**Problem**: Can't find run tasks

**Solutions:**
1. Verify `.zed/tasks.json` exists
2. Check JSON syntax
3. Reload window: `Ctrl+Shift+P` → "zed: reload"

## Themes and Appearance

### Change Theme

1. `Ctrl+Shift+P` → "theme selector: toggle"
2. Browse themes
3. Select one

**Recommended for coding:**
- One Dark (dark)
- One Light (light)
- Andromeda (dark)
- GitHub Light (light)

### Adjust Font Size

**Method 1: Settings**
Edit `.zed/settings.json`:
```json
{
  "buffer_font_size": 14,
  "ui_font_size": 14
}
```

**Method 2: Quick Zoom**
- `Ctrl+=` / `Cmd+=` → Increase font
- `Ctrl+-` / `Cmd+-` → Decrease font
- `Ctrl+0` / `Cmd+0` → Reset font

### Custom Font

```json
{
  "buffer_font_family": "JetBrains Mono",
  "buffer_font_size": 14
}
```

**Recommended coding fonts:**
- JetBrains Mono
- Fira Code
- Cascadia Code
- Source Code Pro

## Extensions and Enhancements

### Install Extensions

1. `Ctrl+Shift+X` / `Cmd+Shift+X`
2. Search for extensions
3. Click install

### Recommended for Lua Development

**Core:**
- ✅ Lua Language Server (built-in)

**Productivity:**
- Better Comments - Enhanced comment highlighting
- Error Lens - Inline error display
- Bracket Pair Colorizer - Match brackets with colors

**Optional:**
- GitHub Copilot - AI code suggestions (requires subscription)
- GitLens - Advanced git integration

## Sample Workspace

Here's a complete example setup:

### Directory Structure
```
MyGame/
├── .zed/
│   ├── settings.json
│   └── tasks.json
├── src/
│   ├── main.lua
│   ├── player.lua
│   └── enemy.lua
├── assets/
│   ├── player.png
│   └── music.wav
├── ReiLua_API.lua
└── README.md
```

### .zed/settings.json
```json
{
  "lsp": {
    "lua-language-server": {
      "settings": {
        "Lua": {
          "runtime": {"version": "Lua 5.4"},
          "diagnostics": {"globals": ["RL"]},
          "workspace": {"library": ["ReiLua_API.lua"]}
        }
      }
    }
  },
  "languages": {
    "Lua": {
      "format_on_save": "on",
      "tab_size": 4
    }
  },
  "theme": "One Dark",
  "buffer_font_size": 14
}
```

### .zed/tasks.json
```json
{
  "tasks": [
    {
      "label": "Run Game",
      "command": "C:/ReiLua/build/ReiLua.exe",
      "args": ["--log", "--no-logo"]
    }
  ]
}
```

Now you can:
- Open project in Zed
- Get autocomplete for all RL functions
- Press `Ctrl+Shift+P` → "Run Game" to test
- Edit code with full LSP support

## Tips for Efficient Development

1. **Learn 5 shortcuts**: `Ctrl+P`, `Ctrl+Shift+F`, `Ctrl+D`, `F12`, `` Ctrl+` ``
2. **Use multi-cursor**: Speed up repetitive edits
3. **Split editor**: Work on related files side-by-side
4. **Keep terminal open**: Quick testing without leaving Zed
5. **Use Zen mode**: Focus during complex coding
6. **Enable autosave**: Never lose work

## Next Steps

✅ Install Zed
✅ Configure for Lua 5.4
✅ Add ReiLua_API.lua to project
✅ Set up tasks for quick testing
✅ Learn essential shortcuts
✅ Start coding your game!

## Additional Resources

- **Zed Documentation**: https://zed.dev/docs
- **Zed GitHub**: https://github.com/zed-industries/zed
- **Community**: https://zed.dev/community
- **Keyboard Shortcuts**: View in Zed with `Ctrl+K Ctrl+S`

---

Happy coding with Zed and ReiLua! 🚀
