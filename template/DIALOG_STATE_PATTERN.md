# Dialog State Pattern

This document explains how to implement Zelda-style dialog systems using the GameState push/pop stack pattern.

## Overview

The GameState system supports a **state stack** that allows you to temporarily push a new state (like a dialog) on top of the current game state, then pop back when done. This is perfect for:

- Dialog systems (Zelda-style text boxes)
- Pause menus
- Inventory screens
- Any UI that needs exclusive input control

## How It Works

```lua
GameState.push(newState)  -- Pushes current state to stack, switches to new state
GameState.pop()           -- Returns to previous state from stack
```

When you `push()` a state:
- Current state's `leave()` is called
- New state's `enter()` is called
- Current state remains in memory on the stack

When you `pop()`:
- Current state's `leave()` is called
- Previous state's `resume()` is called (not `enter()`)
- Previous state gets control back

## Example: Dialog System

### Step 1: Create Dialog State

Create `states/dialog.lua`:

```lua
local Object = require("lib.classic")
local GameState = require("lib.gamestate")
local DialogState = Object:extend()

function DialogState:new(dialogData)
  self.texts = dialogData.texts or {"Default dialog text"}
  self.currentIndex = 1
  self.characterName = dialogData.name or ""
  self.portrait = dialogData.portrait or nil
  self.textSpeed = dialogData.textSpeed or 50  -- chars per second
  self.currentCharIndex = 0
  self.displayedText = ""
  self.isComplete = false
end

function DialogState:enter(previous)
  print("Dialog opened")
  self.currentCharIndex = 0
  self.displayedText = ""
  self.isComplete = false
end

function DialogState:update(dt)
  local currentText = self.texts[self.currentIndex]
  
  -- Animate text reveal
  if not self.isComplete then
    self.currentCharIndex = self.currentCharIndex + self.textSpeed * dt
    if self.currentCharIndex >= #currentText then
      self.currentCharIndex = #currentText
      self.isComplete = true
    end
    self.displayedText = currentText:sub(1, math.floor(self.currentCharIndex))
  end
  
  -- Handle input
  if RL.IsKeyPressed(RL.KEY_ENTER) or RL.IsKeyPressed(RL.KEY_SPACE) then
    if not self.isComplete then
      -- Skip to end of current text
      self.currentCharIndex = #currentText
      self.displayedText = currentText
      self.isComplete = true
    else
      -- Move to next text or close dialog
      if self.currentIndex < #self.texts then
        self.currentIndex = self.currentIndex + 1
        self.currentCharIndex = 0
        self.displayedText = ""
        self.isComplete = false
      else
        -- Dialog finished, return to game
        GameState.pop()
      end
    end
  end
end

function DialogState:draw()
  local screenSize = RL.GetScreenSize()
  local boxHeight = 200
  local boxY = screenSize[2] - boxHeight - 20
  local padding = 20
  
  -- Draw dialog box
  RL.DrawRectangle({0, boxY, screenSize[1], boxHeight}, {20, 20, 30, 240})
  RL.DrawRectangleLines({0, boxY, screenSize[1], boxHeight}, 3, RL.WHITE)
  
  -- Draw character name if present
  if self.characterName ~= "" then
    local nameBoxWidth = 200
    local nameBoxHeight = 40
    RL.DrawRectangle({padding, boxY - nameBoxHeight + 5, nameBoxWidth, nameBoxHeight}, {40, 40, 50, 255})
    RL.DrawRectangleLines({padding, boxY - nameBoxHeight + 5, nameBoxWidth, nameBoxHeight}, 2, RL.WHITE)
    RL.DrawText(self.characterName, {padding + 15, boxY - nameBoxHeight + 15}, 20, RL.WHITE)
  end
  
  -- Draw portrait if present
  local textX = padding + 10
  if self.portrait then
    RL.DrawTexture(self.portrait, {padding + 10, boxY + padding}, RL.WHITE)
    textX = textX + self.portrait.width + 20
  end
  
  -- Draw text
  RL.DrawText(self.displayedText, {textX, boxY + padding}, 20, RL.WHITE)
  
  -- Draw continue indicator
  if self.isComplete then
    local indicator = "▼"
    if self.currentIndex < #self.texts then
      indicator = "Press ENTER to continue"
    else
      indicator = "Press ENTER to close"
    end
    local indicatorSize = 16
    local indicatorWidth = RL.MeasureText(indicator, indicatorSize)
    RL.DrawText(indicator, {screenSize[1] - indicatorWidth - padding, boxY + boxHeight - padding - 20}, indicatorSize, RL.LIGHTGRAY)
  end
end

function DialogState:leave()
  print("Dialog closed")
end

return DialogState
```

### Step 2: Use Dialog in Game State

Modify `states/game.lua`:

```lua
local Object = require("lib.classic")
local GameState = require("lib.gamestate")
local Animation = require("lib.animation")
local DialogState = require("states.dialog")
local GameState_Class = Object:extend()

-- ... (Player class code) ...

function GameState_Class:new()
  self.player = nil
  self.paused = false
end

function GameState_Class:enter(previous)
  print("Entered game state")
  
  local screenSize = RL.GetScreenSize()
  self.player = Player(screenSize[1] / 2 - 16, screenSize[2] / 2 - 16)
  
  -- Example: Show dialog when entering game (for testing)
  -- Remove this after testing
  local welcomeDialog = DialogState({
    name = "System",
    texts = {
      "Welcome to the game!",
      "Use WASD or Arrow keys to move around.",
      "Press ENTER to continue through dialogs."
    },
    textSpeed = 30
  })
  GameState.push(welcomeDialog)
end

function GameState_Class:update(dt)
  -- ESC pauses game
  if RL.IsKeyPressed(RL.KEY_ESCAPE) then
    self.paused = not self.paused
  end
  
  if self.paused then
    return
  end
  
  -- Example: Press T to trigger dialog (for testing)
  if RL.IsKeyPressed(RL.KEY_T) then
    local testDialog = DialogState({
      name = "NPC",
      texts = {
        "Hello traveler!",
        "This is an example dialog system.",
        "You can have multiple text boxes.",
        "Press ENTER to continue!"
      },
      textSpeed = 40
    })
    GameState.push(testDialog)
  end
  
  -- Update game objects (only when not in dialog)
  if self.player then
    self.player:update(dt)
  end
end

function GameState_Class:resume(previous)
  -- Called when returning from dialog
  print("Resumed game state from: " .. tostring(previous))
  -- You can handle post-dialog logic here
  -- Example: Give item, update quest state, etc.
end

function GameState_Class:draw()
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
    
    RL.DrawRectangle({0, 0, screenSize[1], screenSize[2]}, {0, 0, 0, 128})
    
    local text = "PAUSED"
    local size = 40
    local width = RL.MeasureText(text, size)
    RL.DrawText(text, {centerX - width / 2, centerY - 20}, size, RL.WHITE)
  end
  
  -- Draw controls hint
  local hint = "WASD/ARROWS: Move  |  T: Test Dialog  |  ESC: Pause"
  local hintSize = 16
  local screenSize = RL.GetScreenSize()
  RL.DrawText(hint, {10, screenSize[2] - 30}, hintSize, RL.LIGHTGRAY)
end

function GameState_Class:leave()
  print("Left game state")
end

return GameState_Class
```

## Key Benefits

✅ **Clean Separation**: Dialog has its own file and logic
✅ **Input Control**: Dialog gets exclusive control when active
✅ **No Coupling**: Game doesn't need to know about dialog internals
✅ **Automatic Pause**: Game automatically stops updating when dialog is pushed
✅ **Easy Extension**: Add more dialog types (shops, menus) using same pattern
✅ **Post-Dialog Logic**: Use `resume()` callback to handle what happens after dialog closes

## Advanced: Passing Data Back to Game

You can pass data when popping:

```lua
-- In dialog state
function DialogState:update(dt)
  if playerMadeChoice then
    GameState.pop(choiceData)  -- Pass choice back to game
  end
end

-- In game state
function GameState_Class:resume(previous, choiceData)
  if choiceData then
    print("Player chose: " .. choiceData.choice)
    -- Handle the choice
  end
end
```

## State Stack Visual

```
Initial:   [Game State]
           
After push: [Game State] -> [Dialog State]  (Dialog has control)
           
After pop:  [Game State]                     (Game has control back)
```

## When to Use Push/Pop vs Flags

**Use Push/Pop for:**
- Dialog systems
- Pause menus
- Shop interfaces
- Inventory screens
- Any state that needs exclusive control

**Use Flags (self.paused, etc.) for:**
- Simple on/off toggles
- Quick state checks
- Non-blocking overlays
- Debug info displays

## See Also

- `lib/gamestate.lua` - Full GameState implementation
- `states/game.lua` - Example game state
- `states/menu.lua` - Example menu state
