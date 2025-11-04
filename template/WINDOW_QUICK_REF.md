# Window Configuration - Quick Summary

## ✅ What Was Added

Created comprehensive window configuration documentation and improved template.

### Files Created/Modified

1. **`template/WINDOW_CONFIG.md`** (12+ KB) - Complete guide covering:
   - Window size configuration
   - Fullscreen modes (true fullscreen, borderless, toggle)
   - Window flags (VSync, resizable, transparent, etc.)
   - Window states (maximize, minimize, focus)
   - Monitor information
   - 5 complete working examples
   - Quick reference guide
   - Best practices

2. **`template/main.lua`** - Updated with:
   - Better default window size (1280x720 instead of 800x600)
   - Window resizable flag
   - Minimum window size constraint
   - START_FULLSCREEN configuration option
   - Borderless fullscreen toggle (F1/F11)
   - Window resize detection
   - Better console output

3. **`template/README.md`** - Updated with:
   - Reference to WINDOW_CONFIG.md
   - New window configuration options

## 🎮 Quick Usage

### Set Window Size
```lua
-- In main.lua configuration
local WINDOW_WIDTH = 1920
local WINDOW_HEIGHT = 1080

-- Or at runtime
RL.SetWindowSize({1920, 1080})
```

### Enable Fullscreen
```lua
-- Toggle with F1 or F11 (already in template)

-- Or start in fullscreen
local START_FULLSCREEN = true  -- In main.lua

-- Or manually
RL.ToggleBorderlessWindowed()  -- Borderless (recommended)
RL.ToggleFullscreen()           -- True fullscreen
```

### Make Window Resizable
```lua
-- Already enabled in template!
RL.SetWindowState(RL.FLAG_WINDOW_RESIZABLE)
RL.SetWindowMinSize({800, 600})  -- Optional min size
```

### Common Resolutions
```lua
RL.SetWindowSize({1280, 720})   -- HD (720p)
RL.SetWindowSize({1920, 1080})  -- Full HD (1080p)
RL.SetWindowSize({2560, 1440})  -- QHD (1440p)
RL.SetWindowSize({3840, 2160})  -- 4K (2160p)
```

### Window Flags
```lua
RL.SetWindowState(RL.FLAG_VSYNC_HINT)          -- VSync (in template)
RL.SetWindowState(RL.FLAG_WINDOW_RESIZABLE)    -- Resizable (in template)
RL.SetWindowState(RL.FLAG_FULLSCREEN_MODE)     -- Fullscreen
RL.SetWindowState(RL.FLAG_WINDOW_TOPMOST)      -- Always on top
RL.SetWindowState(RL.FLAG_MSAA_4X_HINT)        -- Antialiasing
```

## 📚 All Available Functions

### Size
- `RL.SetWindowSize({width, height})` - Set window size
- `RL.GetScreenSize()` - Get current size
- `RL.SetWindowMinSize({w, h})` - Set minimum size
- `RL.SetWindowMaxSize({w, h})` - Set maximum size

### Fullscreen
- `RL.ToggleBorderlessWindowed()` - Borderless fullscreen (recommended)
- `RL.ToggleFullscreen()` - True fullscreen
- `RL.IsWindowFullscreen()` - Check if fullscreen

### Window State
- `RL.MaximizeWindow()` - Maximize
- `RL.MinimizeWindow()` - Minimize
- `RL.RestoreWindow()` - Restore
- `RL.IsWindowMaximized()` - Check maximized
- `RL.IsWindowMinimized()` - Check minimized
- `RL.IsWindowFocused()` - Check focused
- `RL.IsWindowResized()` - Check if resized this frame

### Flags
- `RL.SetWindowState(flag)` - Enable flag
- `RL.ClearWindowState(flag)` - Disable flag
- `RL.IsWindowState(flag)` - Check flag

### Position
- `RL.SetWindowPosition({x, y})` - Set position
- `RL.GetWindowPosition()` - Get position

### Monitor
- `RL.GetMonitorCount()` - Number of monitors
- `RL.GetMonitorWidth(index)` - Monitor width
- `RL.GetMonitorHeight(index)` - Monitor height
- `RL.GetMonitorName(index)` - Monitor name
- `RL.GetCurrentMonitor()` - Current monitor index

## 💡 Best Practices

### Recommended Settings
```lua
function RL.init()
  -- Good default settings
  RL.SetWindowSize({1280, 720})
  RL.SetWindowState(RL.FLAG_VSYNC_HINT)
  RL.SetWindowState(RL.FLAG_WINDOW_RESIZABLE)
  RL.SetWindowMinSize({800, 600})
end
```

### Fullscreen Toggle
```lua
-- Use borderless windowed (faster alt-tab, no resolution change)
if RL.IsKeyPressed(RL.KEY_F11) then
  RL.ToggleBorderlessWindowed()
end
```

### Responsive Design
```lua
function RL.update(dt)
  if RL.IsWindowResized() then
    local size = RL.GetScreenSize()
    -- Update your UI/camera to new size
    updateViewport(size[1], size[2])
  end
end
```

### Adaptive Resolution
```lua
-- Auto-size to 80% of monitor
local monitorW = RL.GetMonitorWidth(0)
local monitorH = RL.GetMonitorHeight(0)
RL.SetWindowSize({
  math.floor(monitorW * 0.8),
  math.floor(monitorH * 0.8)
})

-- Center window
local size = RL.GetScreenSize()
RL.SetWindowPosition({
  (monitorW - size[1]) / 2,
  (monitorH - size[2]) / 2
})
```

## 🎯 Common Use Cases

### 1. Options Menu
```lua
-- Store in config
config.resolution = {1920, 1080}
config.fullscreen = false

-- Apply settings
if config.fullscreen then
  RL.ToggleBorderlessWindowed()
else
  RL.SetWindowSize(config.resolution)
end
```

### 2. Multiple Resolution Presets
```lua
local resolutions = {
  {1280, 720},   -- HD
  {1920, 1080},  -- Full HD
  {2560, 1440}   -- QHD
}

function changeResolution(index)
  RL.SetWindowSize(resolutions[index])
end
```

### 3. Game Jam Quick Setup
```lua
-- Fast setup for prototyping
RL.SetWindowSize({1280, 720})
RL.SetWindowState(RL.FLAG_VSYNC_HINT)
RL.SetExitKey(0)  -- Disable ESC exit
```

## 📖 Documentation

For complete documentation with examples, see:
- **[WINDOW_CONFIG.md](WINDOW_CONFIG.md)** - Full guide with 5 complete examples
- **[COMMON_ISSUES.md](COMMON_ISSUES.md)** - Troubleshooting

## 🎮 Template Changes

The template now:
- ✅ Starts with 1280x720 (better than 800x600)
- ✅ Window is resizable
- ✅ Has minimum size constraint (800x600)
- ✅ Uses borderless fullscreen (better than true fullscreen)
- ✅ Detects window resize events
- ✅ Provides START_FULLSCREEN configuration option
- ✅ Works with F1 and F11 for fullscreen toggle

---

**Updated**: 2025-11-05  
**Template Version**: 1.0
