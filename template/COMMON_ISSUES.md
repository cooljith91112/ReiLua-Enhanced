# Common Issues and Solutions

## ESC Key Closes the Game

### Problem
By default, RayLib sets ESC as the exit key. When you press ESC, `WindowShouldClose()` returns true and the game closes immediately, even if you want to use ESC for pause menus or other game functionality.

### Solution
Disable the default ESC exit key behavior by calling `RL.SetExitKey(0)` in your `RL.init()` function:

```lua
function RL.init()
  -- Window setup
  RL.SetWindowTitle("My Game")
  
  -- Disable ESC key from closing the window
  RL.SetExitKey(0)  -- 0 = KEY_NULL (no exit key)
  
  -- OR set a different exit key
  -- RL.SetExitKey(RL.KEY_F12)  -- Use F12 instead
  
  -- Rest of initialization...
end
```

### Options

**Option 1: No Exit Key (Recommended for Games)**
```lua
RL.SetExitKey(0)  -- Disable exit key completely
```
Now ESC (and any key) won't close the game. Handle exit through:
- Menu option (File → Exit)
- Alt+F4 (Windows default)
- Close window button (X)

**Option 2: Different Exit Key**
```lua
RL.SetExitKey(RL.KEY_F12)  -- Use F12 to exit
```
Now only F12 will close the game, ESC is free for pause menus.

**Option 3: Custom Exit Handling**
```lua
-- In RL.update()
if RL.IsKeyPressed(RL.KEY_ESCAPE) then
  -- Show pause menu or confirmation dialog
  GameState.push(pauseMenu)
end

if RL.IsKeyPressed(RL.KEY_F10) then
  -- Exit game
  RL.CloseWindow()
end
```

### Technical Details

**What happens by default:**
1. RayLib sets ESC as the default exit key
2. When ESC is pressed, `WindowShouldClose()` returns true
3. Main loop in `src/main.c` checks this and exits

**After calling `RL.SetExitKey(0)`:**
1. No key triggers `WindowShouldClose()`
2. ESC is now available for your game logic
3. You control when the game exits

### Example: Pause Menu with ESC

```lua
-- In your game state:
function GameState:update(dt)
  -- Pause with ESC
  if RL.IsKeyPressed(RL.KEY_ESCAPE) then
    if self.paused then
      self.paused = false
    else
      self.paused = true
    end
  end
  
  if not self.paused then
    -- Update game logic
  end
end
```

### Template Fix

The template's `main.lua` has been updated with:
```lua
RL.SetExitKey(0)  -- Disable ESC exit key
```

This allows the game state to use ESC for pause functionality without closing the game.

### Related Functions

- `RL.SetExitKey(key)` - Set which key exits the game
- `RL.WindowShouldClose()` - Check if game should close
- `RL.CloseWindow()` - Manually close the window
- `RL.IsKeyPressed(key)` - Check if key was pressed this frame

### Development Tip

During development, you might want quick exit. Consider:
```lua
function RL.init()
  RL.SetExitKey(0)  -- Disable ESC
  
  -- But add debug exit key
  if DEBUG_MODE then
    RL.SetExitKey(RL.KEY_F12)
  end
end
```

Or handle it in update:
```lua
function RL.update(dt)
  -- Debug: Quick exit with Shift+ESC
  if RL.IsKeyDown(RL.KEY_LEFT_SHIFT) and RL.IsKeyPressed(RL.KEY_ESCAPE) then
    RL.CloseWindow()
  end
end
```

## Other Common Issues

### Window Closes When X Button Clicked
This is normal behavior. If you want to show a confirmation dialog:
```lua
function RL.update(dt)
  if RL.WindowShouldClose() then
    -- Show "Are you sure?" dialog
    -- If player cancels, need to prevent close somehow
  end
end
```
Note: Preventing X button close is tricky with RayLib's current API.

### Alt+F4 Closes Game
This is OS-level behavior and cannot be easily disabled. It's recommended to save game state frequently.

---

**Updated**: 2025-11-05  
**Template Version**: 1.0
