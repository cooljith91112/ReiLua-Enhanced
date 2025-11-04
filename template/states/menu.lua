--[[
Menu State - Example menu screen
Demonstrates:
- GameState usage
- Simple UI with keyboard navigation
]]

local Object = require("lib.classic")
local MenuState = Object:extend()

function MenuState:new()
  self.options = {"Start Game", "Options", "Exit"}
  self.selected = 1
  self.title = "MY AWESOME GAME"
  self.font = nil
end

function MenuState:enter(previous)
  print("Entered menu state")
  -- Load menu assets here if needed
end

function MenuState:update(dt)
  -- Navigate menu
  if RL.IsKeyPressed(RL.KEY_DOWN) or RL.IsKeyPressed(RL.KEY_S) then
    self.selected = self.selected + 1
    if self.selected > #self.options then
      self.selected = 1
    end
  end
  
  if RL.IsKeyPressed(RL.KEY_UP) or RL.IsKeyPressed(RL.KEY_W) then
    self.selected = self.selected - 1
    if self.selected < 1 then
      self.selected = #self.options
    end
  end
  
  -- Select option
  if RL.IsKeyPressed(RL.KEY_ENTER) or RL.IsKeyPressed(RL.KEY_SPACE) then
    if self.selected == 1 then
      -- Switch to game state
      local GameState = require("lib.gamestate")
      local game = require("states.game")
      GameState.switch(game)
    elseif self.selected == 2 then
      -- Options (not implemented)
      print("Options selected")
    elseif self.selected == 3 then
      -- Exit
      RL.CloseWindow()
    end
  end
end

function MenuState:draw()
  local screenSize = RL.GetScreenSize()
  local centerX = screenSize[1] / 2
  local centerY = screenSize[2] / 2
  
  RL.ClearBackground(RL.BLACK)
  
  -- Draw title
  local titleSize = 40
  local titleText = self.title
  local titleWidth = RL.MeasureText(titleText, titleSize)
  RL.DrawText(titleText, {centerX - titleWidth / 2, centerY - 100}, titleSize, RL.WHITE)
  
  -- Draw menu options
  local optionSize = 24
  local startY = centerY
  for i, option in ipairs(self.options) do
    local color = (i == self.selected) and RL.YELLOW or RL.GRAY
    local prefix = (i == self.selected) and "> " or "  "
    local text = prefix .. option
    local width = RL.MeasureText(text, optionSize)
    RL.DrawText(text, {centerX - width / 2, startY + (i - 1) * 40}, optionSize, color)
  end
  
  -- Draw controls hint
  local hint = "UP/DOWN: Navigate  |  ENTER: Select"
  local hintSize = 16
  local hintWidth = RL.MeasureText(hint, hintSize)
  RL.DrawText(hint, {centerX - hintWidth / 2, screenSize[2] - 40}, hintSize, RL.DARKGRAY)
end

function MenuState:leave()
  print("Left menu state")
  -- Cleanup menu assets here if needed
end

return MenuState
