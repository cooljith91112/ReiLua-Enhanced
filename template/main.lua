--[[
ReiLua-Enhanced Game Template
Entry point for your game

This template includes:
- Classic OOP library (class system)
- GameState management (scene/state switching)
- Animation system (sprite sheet animations)
- Example menu and game states

Quick Start:
1. Edit states/menu.lua for your main menu
2. Edit states/game.lua for your gameplay
3. Add assets to assets/ folder
4. Run with: ReiLua.exe --log --no-logo (for development)

For production build:
1. Copy all files to ReiLua-Enhanced/build/
2. Run: scripts\build_release.bat
]]

-- Load libraries
local GameState = require("lib.gamestate")

-- Load game states
local menu = require("states.menu")()
local game = require("states.game")()

-- Game configuration
local GAME_TITLE = "My Game"
local WINDOW_WIDTH = 1280
local WINDOW_HEIGHT = 720
local TARGET_FPS = 60
local START_FULLSCREEN = false

function RL.init()
  -- Window setup
  RL.SetWindowTitle(GAME_TITLE)
  RL.SetWindowSize({WINDOW_WIDTH, WINDOW_HEIGHT})
  RL.SetTargetFPS(TARGET_FPS)
  
  -- Window flags
  RL.SetWindowState(RL.FLAG_VSYNC_HINT)
  RL.SetWindowState(RL.FLAG_WINDOW_RESIZABLE)
  
  -- Set min window size for resizable window
  RL.SetWindowMinSize({800, 600})
  
  -- Start fullscreen if configured
  if START_FULLSCREEN then
    RL.ToggleBorderlessWindowed()
  end
  
  -- Disable ESC key from closing the window (so we can use it for pause menu)
  RL.SetExitKey(0)  -- 0 = KEY_NULL (no exit key)
  
  -- Initialize audio
  RL.InitAudioDevice()
  
  -- Register GameState callbacks
  GameState.registerEvents()
  
  -- Start with menu state
  GameState.switch(menu)
  
  print("Game initialized!")
  print("Press F1 or F11 to toggle fullscreen")
  print("Window size: " .. WINDOW_WIDTH .. "x" .. WINDOW_HEIGHT)
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
  
  -- GameState will handle update for current state
end

function RL.draw()
  -- GameState will handle drawing for current state
end

function RL.exit()
  -- Cleanup
  RL.CloseAudioDevice()
  print("Game closing...")
end

-- Optional: Window configuration
-- Call this before InitWindow if you need custom window setup
function RL.config()
  -- Example: Set custom window size before init
  -- RL.SetConfigFlags(RL.FLAG_WINDOW_RESIZABLE)
end

-- Optional: Handle window/input events
function RL.event(event)
  -- Handle events here if needed
  -- Example: event.type == RL.GLFW_KEY_EVENT
end
