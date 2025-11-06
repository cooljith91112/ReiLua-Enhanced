# Zed Editor Setup for ReiLua

This guide explains how to set up autocomplete, type hints, and documentation for ReiLua in Zed Editor.

---

## Method 1: Using Lua Language Server (Recommended)

Zed uses the **Lua Language Server (LuaLS)** for Lua support. ReiLua includes `tools/ReiLua_API.lua` with LuaLS annotations.

### Setup Steps

#### 1. Install Lua Language Server in Zed

Zed should automatically install LuaLS when you open a Lua file. If not:

1. Open Zed
2. Go to **Extensions** (Cmd/Ctrl + Shift + X)
3. Search for "Lua"
4. Install the Lua extension

#### 2. Configure Your Project

Create a `.luarc.json` file in your project root:

```json
{
  "runtime.version": "Lua 5.4",
  "workspace.library": [
    "${3rd}/luassert/library",
    "${3rd}/busted/library"
  ],
  "completion.enable": true,
  "diagnostics.globals": [
    "RL"
  ],
  "workspace.checkThirdParty": false
}
```

#### 3. Copy tools/ReiLua_API.lua to Your Project

Copy `tools/ReiLua_API.lua` to your game project folder:

```bash
# From ReiLua directory
cp tools/ReiLua_API.lua /path/to/your/game/project/
```

Or on Windows:
```powershell
Copy-Item tools/ReiLua_API.lua "C:\path\to\your\game\project\"
```

#### 4. (Optional) Create Library Directory

For better organization, create a library directory:

```
your-game/
├── main.lua
├── .luarc.json
└── .lua/
    └── tools/ReiLua_API.lua
```

Update `.luarc.json`:
```json
{
  "runtime.version": "Lua 5.4",
  "workspace.library": [".lua"],
  "completion.enable": true,
  "diagnostics.globals": ["RL"],
  "workspace.checkThirdParty": false
}
```

---

## Method 2: Global Configuration (All Projects)

To make ReiLua API available for all projects:

### Windows

1. Create directory: `%USERPROFILE%\.luarocks\lib\lua\5.4\`
2. Copy `tools/ReiLua_API.lua` to this directory
3. Add to global LuaLS config:

**Location:** `%APPDATA%\Zed\settings.json` or via Zed settings

```json
{
  "lsp": {
    "lua-language-server": {
      "settings": {
        "Lua.workspace.library": [
          "C:\\Users\\YourName\\.luarocks\\lib\\lua\\5.4"
        ],
        "Lua.diagnostics.globals": ["RL"]
      }
    }
  }
}
```

### Linux/macOS

1. Create directory: `~/.lua/reilua/`
2. Copy `tools/ReiLua_API.lua` to this directory
3. Update Zed settings:

```json
{
  "lsp": {
    "lua-language-server": {
      "settings": {
        "Lua.workspace.library": [
          "~/.lua/reilua"
        ],
        "Lua.diagnostics.globals": ["RL"]
      }
    }
  }
}
```

---

## Method 3: Using Zed's LSP Configuration

Create a `.zed/settings.json` in your project:
> Note  There is a sample zed settings json file in the repo root (zed.sample.settings.json)
```json
{
  "lsp": {
    "lua-language-server": {
      "settings": {
        "Lua.runtime.version": "Lua 5.4",
        "Lua.workspace.library": [
          "."
        ],
        "Lua.completion.enable": true,
        "Lua.completion.callSnippet": "Replace",
        "Lua.completion.displayContext": 3,
        "Lua.diagnostics.globals": [
          "RL"
        ],
        "Lua.hint.enable": true,
        "Lua.hint.paramName": "All",
        "Lua.hint.setType": true
      }
    }
  }
}
```

---

## Verifying Setup

Create a test file `test.lua`:

```lua
function RL.init()
    -- Type "RL." and you should see autocomplete
    RL.SetWindowTitle("Test")  -- Should show documentation

    local color = RL.RED  -- Should autocomplete color constants

    -- Hover over functions to see documentation
    RL.DrawText("Hello", 10, 10, 20, color)
end

function RL.update(delta)
    -- 'delta' should show as number type
end
```

If autocomplete works, you should see:
-  Function suggestions when typing `RL.`
-  Parameter hints when calling functions
-  Documentation on hover
-  Constant values (RL.RED, RL.KEY_SPACE, etc.)

---

## Enhanced Features

### Enable Inlay Hints

In Zed settings:

```json
{
  "inlay_hints": {
    "enabled": true
  },
  "lsp": {
    "lua-language-server": {
      "settings": {
        "Lua.hint.enable": true,
        "Lua.hint.paramName": "All",
        "Lua.hint.setType": true,
        "Lua.hint.paramType": true
      }
    }
  }
}
```

This will show:
- Parameter names inline
- Variable types
- Return types

### Disable Annoying Warnings

Add these to suppress common false positives:

```json
{
  "lsp": {
    "lua-language-server": {
      "settings": {
        "Lua.diagnostics.disable": [
          "lowercase-global",
          "unused-local",
          "duplicate-set-field",
          "missing-fields",
          "undefined-field"
        ],
        "Lua.diagnostics.globals": ["RL"]
      }
    }
  }
}
```

Common warnings and what they mean:
- `lowercase-global` - Using global variables with lowercase names (RL is intentional)
- `unused-local` - Local variables that aren't used
- `duplicate-set-field` - Redefining functions (callback functions are expected to be redefined)
- `missing-fields` - Table fields that might not exist
- `undefined-field` - Accessing fields that aren't documented

> **Note:** The `tools/ReiLua_API.lua` file now uses type annotations instead of function definitions for callbacks to prevent duplicate warnings.

---

## Troubleshooting

### "duplicate-set-field" Error

**Problem:** Getting warnings like `Duplicate field 'init'. (Lua Diagnostics. duplicate-set-field)`

**Why:** The `tools/ReiLua_API.lua` file previously defined callback functions as empty function definitions. When you define them in your `main.lua`, LSP sees it as redefining the same field.

**Solution:** The latest `tools/ReiLua_API.lua` now uses type annotations instead:

```lua
-- Old way (caused warnings)
function RL.init() end

-- New way (no warnings)
---@type fun()
RL.init = nil
```

Fix Steps:
1. **Update `tools/ReiLua_API.lua`** - Copy the latest version from the repository
2. **Or add to diagnostics.disable** in your configuration:
   ```json
   {
     "diagnostics.disable": ["duplicate-set-field"]
   }
   ```
3. **Restart Zed** to reload the configuration

Benefits of the new approach:
-  No duplicate warnings
-  Still get autocomplete
-  Still get documentation on hover
-  Still get type checking

---

### Autocomplete Not Working

1. **Restart Zed** after configuration changes
2. **Check LSP Status**: Look for Lua Language Server in bottom-right status bar
3. **Verify File Location**: Ensure `tools/ReiLua_API.lua` is in the workspace
4. **Check Console**: Open Zed's log to see LSP errors

### Performance Issues

If the language server is slow:

```json
{
  "lsp": {
    "lua-language-server": {
      "settings": {
        "Lua.workspace.maxPreload": 2000,
        "Lua.workspace.preloadFileSize": 1000
      }
    }
  }
}
```

### Missing Documentation

Ensure hover is enabled:

```json
{
  "hover_popover_enabled": true
}
```

---

## Advanced: Custom Annotations

You can extend `tools/ReiLua_API.lua` with your own game types:

```lua
---@class Player
---@field x number
---@field y number
---@field health number

---@class Enemy
---@field x number
---@field y number
---@field damage number

-- Your game globals
---@type Player
player = {}

---@type Enemy[]
enemies = {}
```

---

## Keyboard Shortcuts in Zed

- **Trigger Autocomplete**: `Ctrl+Space` (Windows/Linux) or `Cmd+Space` (macOS)
- **Show Documentation**: Hover or `Ctrl+K Ctrl+I`
- **Go to Definition**: `F12` or `Cmd+Click`
- **Find References**: `Shift+F12`
- **Rename Symbol**: `F2`

---

## Additional Resources

- [Lua Language Server GitHub](https://github.com/LuaLS/lua-language-server)
- [LuaLS Annotations Guide](https://github.com/LuaLS/lua-language-server/wiki/Annotations)
- [Zed Documentation](https://zed.dev/docs)

---

## Example Project Structure

```
my-reilua-game/
├── .luarc.json              # LuaLS configuration
├── .zed/
│   └── settings.json        # Zed-specific settings
├── tools/ReiLua_API.lua           # API definitions (copy from ReiLua)
├── main.lua                 # Your game entry point
├── player.lua
├── enemy.lua
└── assets/
    ├── sprites/
    └── sounds/
```

---

## Quick Start Template

Save this as `.luarc.json` in your project:

```json
{
  "runtime.version": "Lua 5.4",
  "completion.enable": true,
  "completion.callSnippet": "Replace",
  "diagnostics.globals": ["RL"],
  "diagnostics.disable": [
    "lowercase-global",
    "duplicate-set-field",
    "missing-fields"
  ],
  "workspace.checkThirdParty": false,
  "workspace.library": ["."],
  "hint.enable": true
}
```

Save this as `.zed/settings.json`:

```json
{
  "lsp": {
    "lua-language-server": {
      "settings": {
        "Lua.hint.enable": true,
        "Lua.hint.paramName": "All",
        "Lua.hint.setType": true,
        "Lua.diagnostics.disable": [
          "lowercase-global",
          "duplicate-set-field",
          "missing-fields"
        ]
      }
    }
  },
  "inlay_hints": {
    "enabled": true
  }
}
```

Then copy `tools/ReiLua_API.lua` to your project root, and you're ready to go!

---

Happy Coding! 
