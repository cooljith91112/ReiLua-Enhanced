--[[
Game State - Main gameplay state
Demonstrates:
- GameState usage
- Animation system
- Object-oriented player
- Basic game loop
]]

local Object = require("lib.classic")
local Animation = require("lib.animation")
local GameState = Object:extend()

-- Player class
local Player = Object:extend()

function Player:new(x, y)
  self.x = x
  self.y = y
  self.speed = 200
  self.animation = nil
end

function Player:update(dt)
  local moved = false
  
  -- Movement
  if RL.IsKeyDown(RL.KEY_LEFT) or RL.IsKeyDown(RL.KEY_A) then
    self.x = self.x - self.speed * dt
    moved = true
  end
  if RL.IsKeyDown(RL.KEY_RIGHT) or RL.IsKeyDown(RL.KEY_D) then
    self.x = self.x + self.speed * dt
    moved = true
  end
  if RL.IsKeyDown(RL.KEY_UP) or RL.IsKeyDown(RL.KEY_W) then
    self.y = self.y - self.speed * dt
    moved = true
  end
  if RL.IsKeyDown(RL.KEY_DOWN) or RL.IsKeyDown(RL.KEY_S) then
    self.y = self.y + self.speed * dt
    moved = true
  end
  
  -- Update animation
  if self.animation then
    if moved then
      self.animation:play("walk")
    else
      self.animation:play("idle")
    end
    self.animation:update(dt)
  end
end

function Player:draw()
  if self.animation then
    self.animation:drawSimple(self.x, self.y)
  else
    -- Fallback: draw a simple rectangle
    RL.DrawRectangle({self.x, self.y, 32, 32}, RL.BLUE)
  end
end

-- Game State
function GameState:new()
  self.player = nil
  self.paused = false
end

function GameState:enter(previous)
  print("Entered game state")
  
  local screenSize = RL.GetScreenSize()
  
  -- Create player
  self.player = Player(screenSize[1] / 2 - 16, screenSize[2] / 2 - 16)
  
  -- TODO: Load player sprite sheet and create animation
  -- Example:
  -- local playerTexture = RL.LoadTexture("assets/player.png")
  -- self.player.animation = Animation.new(playerTexture, 32, 32, {
  --   idle = {frames = {1, 2, 3, 4}, fps = 8, loop = true},
  --   walk = {frames = {5, 6, 7, 8}, fps = 12, loop = true}
  -- })
  -- self.player.animation:play("idle")
end

function GameState:update(dt)
  -- Pause/unpause
  if RL.IsKeyPressed(RL.KEY_ESCAPE) or RL.IsKeyPressed(RL.KEY_P) then
    self.paused = not self.paused
  end
  
  if self.paused then
    return
  end
  
  -- Update game objects
  if self.player then
    self.player:update(dt)
  end
end

function GameState:draw()
  RL.ClearBackground({50, 50, 50, 255})
  
  -- Draw game objects
  if self.player then
    self.player:draw()
  end
  
  -- Draw pause overlay
  if self.paused then
    local screenSize = RL.GetScreenSize()
    local centerX = screenSize[1] / 2
    local centerY = screenSize[2] / 2
    
    -- Semi-transparent overlay
    RL.DrawRectangle({0, 0, screenSize[1], screenSize[2]}, {0, 0, 0, 128})
    
    -- Pause text
    local text = "PAUSED"
    local size = 40
    local width = RL.MeasureText(text, size)
    RL.DrawText(text, {centerX - width / 2, centerY - 20}, size, RL.WHITE)
    
    local hint = "Press ESC or P to resume"
    local hintSize = 20
    local hintWidth = RL.MeasureText(hint, hintSize)
    RL.DrawText(hint, {centerX - hintWidth / 2, centerY + 30}, hintSize, RL.GRAY)
  end
  
  -- Draw controls hint
  local hint = "WASD/ARROWS: Move  |  ESC: Pause"
  local hintSize = 16
  local screenSize = RL.GetScreenSize()
  RL.DrawText(hint, {10, screenSize[2] - 30}, hintSize, RL.LIGHTGRAY)
end

function GameState:leave()
  print("Left game state")
  -- Cleanup game assets here
end

return GameState
