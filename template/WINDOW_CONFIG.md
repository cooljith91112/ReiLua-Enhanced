# Window Configuration Guide

Complete guide for setting up window size, fullscreen, and window management in ReiLua-Enhanced.

## Table of Contents
- [Window Size](#window-size)
- [Fullscreen Mode](#fullscreen-mode)
- [Window Flags](#window-flags)
- [Window States](#window-states)
- [Complete Examples](#complete-examples)

## Window Size

### Initial Window Size

Set window size when initializing:

```lua
-- Method 1: Default size (uses RayLib's default: 800x450)
function RL.init()
  RL.SetWindowTitle("My Game")
end

-- Method 2: Set specific size after init
function RL.init()
  RL.SetWindowTitle("My Game")
  RL.SetWindowSize({1280, 720})  -- 1280x720 window
end

-- Method 3: Manual InitWindow (in RL.config, advanced)
function RL.config()
  RL.InitWindow({1920, 1080}, "My Game")
end
```

### Change Window Size During Runtime

```lua
-- Resize window to 1920x1080
RL.SetWindowSize({1920, 1080})

-- Get current window size
local size = RL.GetScreenSize()
print("Width: " .. size[1] .. ", Height: " .. size[2])

-- Common resolutions
RL.SetWindowSize({800, 600})    -- 4:3 ratio
RL.SetWindowSize({1280, 720})   -- HD (720p)
RL.SetWindowSize({1920, 1080})  -- Full HD (1080p)
RL.SetWindowSize({2560, 1440})  -- QHD (1440p)
RL.SetWindowSize({3840, 2160})  -- 4K (2160p)
```

### Resizable Window

Allow users to resize the window:

```lua
function RL.init()
  -- Enable window resizing
  RL.SetWindowState(RL.FLAG_WINDOW_RESIZABLE)
  
  -- Optional: Set min/max size constraints
  RL.SetWindowMinSize({800, 600})
  RL.SetWindowMaxSize({1920, 1080})
end

function RL.update(dt)
  -- Check if window was resized
  if RL.IsWindowResized() then
    local size = RL.GetScreenSize()
    print("Window resized to: " .. size[1] .. "x" .. size[2])
    
    -- Update your game viewport/camera if needed
  end
end
```

## Fullscreen Mode

### Toggle Fullscreen

```lua
-- Simple toggle (F11 or F1 key)
function RL.update(dt)
  if RL.IsKeyPressed(RL.KEY_F11) then
    RL.ToggleFullscreen()
  end
end

-- The template already includes this with F1 and F11
```

### Set Fullscreen at Startup

```lua
function RL.init()
  RL.SetWindowTitle("My Game")
  
  -- Start in fullscreen mode
  RL.SetWindowState(RL.FLAG_FULLSCREEN_MODE)
end
```

### Borderless Fullscreen (Windowed Fullscreen)

Better alternative to true fullscreen - faster alt-tab, no resolution change:

```lua
function RL.update(dt)
  if RL.IsKeyPressed(RL.KEY_F11) then
    RL.ToggleBorderlessWindowed()
  end
end

-- Or at startup
function RL.init()
  RL.SetWindowTitle("My Game")
  RL.ToggleBorderlessWindowed()
end
```

### Check Fullscreen Status

```lua
if RL.IsWindowFullscreen() then
  print("Running in fullscreen")
else
  print("Running in windowed mode")
end
```

### Different Fullscreen Modes

```lua
-- Method 1: True fullscreen (changes display resolution)
RL.SetWindowState(RL.FLAG_FULLSCREEN_MODE)

-- Method 2: Borderless windowed (keeps desktop resolution)
RL.ToggleBorderlessWindowed()

-- Method 3: Toggle between windowed and last fullscreen mode
RL.ToggleFullscreen()
```

## Window Flags

Window flags control various window behaviors. Set them before or after initialization.

### Common Window Flags

```lua
-- VSync (synchronize with monitor refresh rate)
RL.SetWindowState(RL.FLAG_VSYNC_HINT)

-- Fullscreen mode
RL.SetWindowState(RL.FLAG_FULLSCREEN_MODE)

-- Resizable window
RL.SetWindowState(RL.FLAG_WINDOW_RESIZABLE)

-- Borderless window (no title bar)
RL.SetWindowState(RL.FLAG_WINDOW_UNDECORATED)

-- Always on top
RL.SetWindowState(RL.FLAG_WINDOW_TOPMOST)

-- Hidden window (start hidden)
RL.SetWindowState(RL.FLAG_WINDOW_HIDDEN)

-- Transparent window
RL.SetWindowState(RL.FLAG_WINDOW_TRANSPARENT)

-- High DPI support
RL.SetWindowState(RL.FLAG_WINDOW_HIGHDPI)

-- MSAA 4x antialiasing
RL.SetWindowState(RL.FLAG_MSAA_4X_HINT)
```

### Combining Multiple Flags

You can't OR flags in Lua, so set them individually:

```lua
function RL.init()
  RL.SetWindowTitle("My Game")
  
  -- Set multiple flags
  RL.SetWindowState(RL.FLAG_VSYNC_HINT)
  RL.SetWindowState(RL.FLAG_WINDOW_RESIZABLE)
  RL.SetWindowState(RL.FLAG_MSAA_4X_HINT)
end
```

### Check if Flag is Enabled

```lua
if RL.IsWindowState(RL.FLAG_WINDOW_RESIZABLE) then
  print("Window is resizable")
end

if RL.IsWindowState(RL.FLAG_VSYNC_HINT) then
  print("VSync is enabled")
end
```

### Clear Window Flags

```lua
-- Remove a specific flag
RL.ClearWindowState(RL.FLAG_WINDOW_TOPMOST)

-- Remove resizable flag
RL.ClearWindowState(RL.FLAG_WINDOW_RESIZABLE)
```

## Window States

### Maximize/Minimize

```lua
-- Maximize window (fill screen without fullscreen)
RL.MaximizeWindow()

-- Minimize window (to taskbar)
RL.MinimizeWindow()

-- Restore window
RL.RestoreWindow()
```

### Check Window State

```lua
-- Check if window is maximized
if RL.IsWindowMaximized() then
  print("Window is maximized")
end

-- Check if window is minimized
if RL.IsWindowMinimized() then
  print("Window is minimized")
end

-- Check if window is focused
if RL.IsWindowFocused() then
  print("Window has focus")
end

-- Check if window is hidden
if RL.IsWindowHidden() then
  print("Window is hidden")
end
```

### Window Position

```lua
-- Set window position on screen
RL.SetWindowPosition({100, 100})  -- x, y from top-left of screen

-- Get current window position
local pos = RL.GetWindowPosition()
print("Window at: " .. pos[1] .. ", " .. pos[2])

-- Center window on monitor
local monitorWidth = RL.GetMonitorWidth(0)
local monitorHeight = RL.GetMonitorHeight(0)
local windowSize = RL.GetScreenSize()

RL.SetWindowPosition({
  (monitorWidth - windowSize[1]) / 2,
  (monitorHeight - windowSize[2]) / 2
})
```

### Monitor Information

```lua
-- Get number of monitors
local monitorCount = RL.GetMonitorCount()

-- Get monitor dimensions
local width = RL.GetMonitorWidth(0)   -- Monitor 0 (primary)
local height = RL.GetMonitorHeight(0)

-- Get monitor name
local name = RL.GetMonitorName(0)
print("Monitor: " .. name)

-- Get current monitor
local currentMonitor = RL.GetCurrentMonitor()
```

## Complete Examples

### Example 1: Game with Options Menu

```lua
-- config.lua
local Config = {
  resolution = {1280, 720},
  fullscreen = false,
  vsync = true,
  resizable = true
}

function Config.apply()
  -- Apply resolution
  RL.SetWindowSize(Config.resolution)
  
  -- Apply fullscreen
  if Config.fullscreen then
    if not RL.IsWindowFullscreen() then
      RL.ToggleBorderlessWindowed()
    end
  else
    if RL.IsWindowFullscreen() then
      RL.ToggleBorderlessWindowed()
    end
  end
  
  -- Apply VSync
  if Config.vsync then
    RL.SetWindowState(RL.FLAG_VSYNC_HINT)
  else
    RL.ClearWindowState(RL.FLAG_VSYNC_HINT)
  end
end

-- main.lua
function RL.init()
  RL.SetWindowTitle("My Game")
  
  -- Apply saved config
  Config.apply()
  
  -- Make window resizable
  if Config.resizable then
    RL.SetWindowState(RL.FLAG_WINDOW_RESIZABLE)
    RL.SetWindowMinSize({800, 600})
  end
end
```

### Example 2: Adaptive Resolution

```lua
function RL.init()
  RL.SetWindowTitle("My Game")
  
  -- Get monitor size
  local monitorWidth = RL.GetMonitorWidth(0)
  local monitorHeight = RL.GetMonitorHeight(0)
  
  -- Use 80% of monitor size
  local width = math.floor(monitorWidth * 0.8)
  local height = math.floor(monitorHeight * 0.8)
  
  RL.SetWindowSize({width, height})
  
  -- Center window
  RL.SetWindowPosition({
    (monitorWidth - width) / 2,
    (monitorHeight - height) / 2
  })
  
  RL.SetWindowState(RL.FLAG_WINDOW_RESIZABLE)
end
```

### Example 3: Dynamic Fullscreen Toggle

```lua
local isFullscreen = false

function toggleFullscreen()
  isFullscreen = not isFullscreen
  
  if isFullscreen then
    -- Save windowed size before going fullscreen
    windowedSize = RL.GetScreenSize()
    windowedPos = RL.GetWindowPosition()
    
    -- Go fullscreen
    RL.ToggleBorderlessWindowed()
  else
    -- Restore windowed mode
    RL.ToggleBorderlessWindowed()
    
    -- Restore previous size and position
    if windowedSize then
      RL.SetWindowSize(windowedSize)
      RL.SetWindowPosition(windowedPos)
    end
  end
end

function RL.update(dt)
  if RL.IsKeyPressed(RL.KEY_F11) then
    toggleFullscreen()
  end
end
```

### Example 4: Resolution Presets

```lua
local resolutions = {
  {name = "HD", size = {1280, 720}},
  {name = "Full HD", size = {1920, 1080}},
  {name = "QHD", size = {2560, 1440}},
  {name = "Custom", size = {800, 600}}
}

local currentResolution = 2  -- Start with Full HD

function changeResolution(index)
  currentResolution = index
  local res = resolutions[index]
  
  if RL.IsWindowFullscreen() then
    -- Exit fullscreen first
    RL.ToggleBorderlessWindowed()
  end
  
  RL.SetWindowSize(res.size)
  
  -- Center window after resize
  local monitorWidth = RL.GetMonitorWidth(0)
  local monitorHeight = RL.GetMonitorHeight(0)
  RL.SetWindowPosition({
    (monitorWidth - res.size[1]) / 2,
    (monitorHeight - res.size[2]) / 2
  })
  
  print("Resolution changed to: " .. res.name)
end

-- In options menu:
function drawResolutionOptions()
  for i, res in ipairs(resolutions) do
    local color = (i == currentResolution) and RL.YELLOW or RL.WHITE
    local text = res.name .. " (" .. res.size[1] .. "x" .. res.size[2] .. ")"
    -- Draw option...
  end
end
```

### Example 5: Template Integration

Update your template's `main.lua`:

```lua
-- Game configuration
local GAME_TITLE = "My Game"
local WINDOW_WIDTH = 1280
local WINDOW_HEIGHT = 720
local TARGET_FPS = 60
local START_FULLSCREEN = false  -- Start in fullscreen?

function RL.init()
  -- Window setup
  RL.SetWindowTitle(GAME_TITLE)
  RL.SetWindowSize({WINDOW_WIDTH, WINDOW_HEIGHT})
  RL.SetTargetFPS(TARGET_FPS)
  
  -- Window flags
  RL.SetWindowState(RL.FLAG_VSYNC_HINT)
  RL.SetWindowState(RL.FLAG_WINDOW_RESIZABLE)
  
  -- Start fullscreen if configured
  if START_FULLSCREEN then
    RL.ToggleBorderlessWindowed()
  end
  
  -- Disable ESC exit key
  RL.SetExitKey(0)
  
  -- Rest of initialization...
end

function RL.update(delta)
  -- Global hotkeys
  if RL.IsKeyPressed(RL.KEY_F1) or RL.IsKeyPressed(RL.KEY_F11) then
    RL.ToggleBorderlessWindowed()
  end
  
  -- Handle window resize
  if RL.IsWindowResized() then
    local newSize = RL.GetScreenSize()
    print("Window resized to: " .. newSize[1] .. "x" .. newSize[2])
    -- Update your camera/viewport here if needed
  end
  
  -- Rest of update...
end
```

## Quick Reference

### Most Used Functions

```lua
-- Size
RL.SetWindowSize({width, height})
RL.GetScreenSize()

-- Fullscreen
RL.ToggleBorderlessWindowed()  -- Recommended
RL.ToggleFullscreen()           -- Alternative
RL.IsWindowFullscreen()

-- Flags
RL.SetWindowState(RL.FLAG_VSYNC_HINT)
RL.SetWindowState(RL.FLAG_WINDOW_RESIZABLE)

-- State
RL.MaximizeWindow()
RL.MinimizeWindow()
RL.IsWindowResized()
RL.IsWindowFocused()

-- Position
RL.SetWindowPosition({x, y})
RL.GetWindowPosition()

-- Monitor
RL.GetMonitorWidth(0)
RL.GetMonitorHeight(0)
```

## Tips and Best Practices

### Performance
- Use `RL.FLAG_VSYNC_HINT` to prevent screen tearing
- Use borderless fullscreen instead of true fullscreen for faster alt-tab
- Check `IsWindowResized()` before recalculating viewport/camera

### User Experience
- Always provide a fullscreen toggle (F11 is standard)
- Save window size/position preferences
- Offer resolution presets in options menu
- Make window resizable for flexibility

### Compatibility
- Test different resolutions and aspect ratios
- Use `GetMonitorWidth/Height()` to detect screen size
- Don't hardcode UI positions - use percentages or anchors
- Support both windowed and fullscreen modes

---

**Updated**: 2025-11-05  
**Template Version**: 1.0
