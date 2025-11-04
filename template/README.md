# ReiLua-Enhanced Game Template

A complete game template for rapid development with ReiLua-Enhanced.

## 📁 Structure

```
template/
├── main.lua              # Entry point
├── lib/                  # Core libraries
│   ├── classic.lua       # OOP class system
│   ├── gamestate.lua     # State management
│   └── animation.lua     # Sprite animation system
├── states/               # Game states
│   ├── menu.lua          # Menu screen
│   └── game.lua          # Main gameplay
└── assets/               # Game assets (images, sounds, etc.)
```

## 🚀 Quick Start

### Development

1. **Copy template to your game folder:**
   ```bash
   xcopy /E /I template MyGame
   cd MyGame
   ```

2. **Run your game:**
   ```bash
   path\to\ReiLua.exe --log --no-logo
   ```

3. **Start coding!**
   - Edit `states/menu.lua` for your menu
   - Edit `states/game.lua` for gameplay
   - Add assets to `assets/` folder

### Release Build

1. **Copy files to build directory:**
   ```bash
   cd ReiLua-Enhanced\build
   xcopy /E /I ..\MyGame\*.lua .
   xcopy /E /I ..\MyGame\lib lib
   xcopy /E /I ..\MyGame\states states
   mkdir assets
   xcopy /E /I ..\MyGame\assets assets
   ```

2. **Build release:**
   ```bash
   cd ..
   scripts\build_release.bat
   ```

3. **Your game is ready!**
   - `build/ReiLua.exe` (or your custom name)
   - Everything embedded in one executable

## 📚 Libraries Included

### Classic (OOP)
Object-oriented class system by rxi.

```lua
local Object = require("lib.classic")
local Player = Object:extend()

function Player:new(x, y)
  self.x = x
  self.y = y
end

function Player:update(dt)
  -- Update logic
end

local player = Player(100, 100)
```

### GameState
State management system inspired by hump.gamestate.

```lua
local GameState = require("lib.gamestate")
local menu = require("states.menu")

-- Register callbacks
GameState.registerEvents()

-- Switch state
GameState.switch(menu)

-- Push state (with return)
GameState.push(pauseMenu)
GameState.pop()  -- Returns to previous state
```

**State Callbacks:**
- `state:enter(previous, ...)` - Entering state
- `state:leave()` - Leaving state
- `state:resume(previous, ...)` - Returning via pop()
- `state:update(dt)` - Frame update
- `state:draw()` - Rendering
- `state:event(event)` - Input events

### Animation
Sprite sheet animation system.

```lua
local Animation = require("lib.animation")

-- Load texture
local playerTexture = RL.LoadTexture("assets/player.png")

-- Create animation (32x32 frame size)
local anim = Animation.new(playerTexture, 32, 32, {
  idle = {frames = {1, 2, 3, 4}, fps = 8, loop = true},
  walk = {frames = {5, 6, 7, 8, 9, 10}, fps = 12, loop = true},
  jump = {frames = {11, 12, 13}, fps = 10, loop = false}
})

-- Play animation
anim:play("idle")

-- In update loop
anim:update(dt)

-- In draw loop
anim:draw(x, y)

-- Or simple draw (no rotation/scale)
anim:drawSimple(x, y)

-- Advanced features
anim:setFlip(true, false)  -- Flip horizontally
anim:setScale(2, 2)        -- Scale 2x
anim:setTint(RL.RED)       -- Color tint
anim:pause()               -- Pause animation
anim:resume()              -- Resume
anim:stop()                -- Stop and reset
```

## 🎮 Example States

### Menu State (states/menu.lua)
- Keyboard navigation (Up/Down)
- Start game / Options / Exit
- Clean UI rendering

### Game State (states/game.lua)
- Player movement (WASD/Arrows)
- Pause menu (ESC/P)
- Animation integration example
- Basic game loop

## 🎨 Adding Assets

### Sprite Sheets
Place sprite sheets in `assets/` folder:

```
assets/
├── player.png      # Player sprite sheet (grid-based)
├── enemy.png       # Enemy sprites
├── explosion.png   # Explosion animation
└── background.png  # Background image
```

**Sprite Sheet Format:**
- Grid-based (equal-sized frames)
- Frames read left-to-right, top-to-bottom
- Example: 32x32 frames in 256x256 texture = 8x8 grid (64 frames)

### Sounds & Music
```lua
-- In state:enter()
self.music = RL.LoadMusicStream("assets/music.ogg")
self.jumpSound = RL.LoadSound("assets/jump.wav")

-- In state:update()
RL.UpdateMusicStream(self.music)

-- Play sound
RL.PlaySound(self.jumpSound)
```

## 🔧 Configuration

### Window Settings (main.lua)
```lua
local GAME_TITLE = "My Awesome Game"
local WINDOW_WIDTH = 1280
local WINDOW_HEIGHT = 720
local TARGET_FPS = 60
local START_FULLSCREEN = false  -- Start in fullscreen?
```

For complete window configuration (fullscreen, resizable, etc.), see [WINDOW_CONFIG.md](WINDOW_CONFIG.md).

### Exit Key Behavior
By default, the template disables ESC as an exit key so you can use it for pause menus:
```lua
RL.SetExitKey(0)  -- 0 = No exit key
```

To change this behavior, see [COMMON_ISSUES.md](COMMON_ISSUES.md#esc-key-closes-the-game).

### Global Hotkeys
- **F1 / F11** - Toggle fullscreen
- **ESC** - Pause game (in game state)

## 📖 State Management Patterns

### Simple State Switch
```lua
-- From menu to game
GameState.switch(gameState)
```

### State Stack (Pause Menu)
```lua
-- Push pause menu (game continues in background)
GameState.push(pauseMenu)

-- Return to game
GameState.pop()
```

### Passing Data Between States
```lua
-- Pass score to game over screen
GameState.switch(gameOverState, score, highScore)

-- In game over state:
function gameOverState:enter(previous, score, highScore)
  self.score = score
  self.highScore = highScore
end
```

## 🎯 Best Practices

### Performance
- Load assets in `state:enter()`, not `update()`
- Unload assets in `state:leave()`
- Use object pooling for bullets/particles
- Profile with `--log` flag

### Organization
- One file per state
- Keep states small and focused
- Use OOP for game entities (Player, Enemy, etc.)
- Separate rendering from logic

### Asset Loading
```lua
function state:enter()
  -- Show loading if needed
  local assets = {"player.png", "enemy.png", "music.ogg"}
  RL.BeginAssetLoading(#assets)
  
  for _, asset in ipairs(assets) do
    RL.UpdateAssetLoading(asset)
    -- Load asset...
  end
  
  RL.EndAssetLoading()
end
```

## 🐛 Debugging

### Development Mode
```bash
ReiLua.exe --log --no-logo
```
- Shows console output
- Skips splash screens
- Fast iteration

### Common Issues

**Animation not showing:**
- Check texture loaded: `if not texture then print("Failed!") end`
- Verify frame size matches sprite sheet
- Check animation is playing: `anim:play("idle")`

**State not switching:**
- Verify `GameState.registerEvents()` called in `RL.init()`
- Check state has required functions (`:update()`, `:draw()`)
- Use `print()` in `:enter()` to verify state switch

**Assets not loading:**
- Use relative paths: `"assets/player.png"` not `"C:/..."`
- Check file exists with `RL.FileExists()`
- View console with `--log` flag

## 📦 Building for Release

See main ReiLua-Enhanced documentation:
- [EMBEDDING.md](../docs/EMBEDDING.md) - Embedding guide
- [BUILD_SCRIPTS.md](../docs/BUILD_SCRIPTS.md) - Build automation
- [CUSTOMIZATION.md](../docs/CUSTOMIZATION.md) - Branding/icons

## 📄 License

- **classic.lua** - MIT License (rxi)
- **gamestate.lua** - Inspired by hump (MIT)
- **animation.lua** - MIT License
- **Template** - Free to use for any project

## 🎮 Ready to Make Games!

This template gives you everything needed to start building games immediately. Focus on gameplay, not boilerplate!

For more examples and documentation, see the main ReiLua-Enhanced repository.

Happy game jamming! 🚀
