--[[
GameState - State management for ReiLua-Enhanced
Inspired by hump.gamestate for Love2D
Adapted for ReiLua-Enhanced by providing similar API

Usage:
  local GameState = require("lib.gamestate")
  local menu = {}
  local game = {}
  
  function menu:enter() end
  function menu:update(dt) end
  function menu:draw() end
  
  GameState.registerEvents()
  GameState.switch(menu)
]]

local GameState = {}

-- Current state
local current = nil

-- Stack of states for push/pop functionality
local stack = {}

-- Helper function to call state function if it exists
local function call(state, func, ...)
  if state and state[func] then
    return state[func](state, ...)
  end
end

-- Switch to a new state
function GameState.switch(to, ...)
  if current then
    call(current, 'leave')
  end
  
  local pre = current
  current = to
  
  return call(current, 'enter', pre, ...)
end

-- Push current state to stack and switch to new state
function GameState.push(to, ...)
  if current then
    table.insert(stack, current)
  end
  return GameState.switch(to, ...)
end

-- Pop state from stack and return to it
function GameState.pop(...)
  if #stack < 1 then
    return
  end
  
  local pre = current
  current = table.remove(stack)
  
  if pre then
    call(pre, 'leave')
  end
  
  return call(current, 'resume', pre, ...)
end

-- Get current state
function GameState.current()
  return current
end

-- Register callbacks to RL framework
function GameState.registerEvents()
  -- Override RL callbacks to forward to current state
  local RL_init = RL.init
  local RL_update = RL.update
  local RL_draw = RL.draw
  local RL_event = RL.event
  local RL_exit = RL.exit
  
  RL.init = function()
    if RL_init then RL_init() end
    call(current, 'init')
  end
  
  RL.update = function(dt)
    if RL_update then RL_update(dt) end
    call(current, 'update', dt)
  end
  
  RL.draw = function()
    if RL_draw then RL_draw() end
    call(current, 'draw')
  end
  
  RL.event = function(event)
    if RL_event then RL_event(event) end
    call(current, 'event', event)
  end
  
  RL.exit = function()
    if RL_exit then RL_exit() end
    call(current, 'exit')
  end
end

-- State callbacks that can be implemented:
-- state:enter(previous, ...) - Called when entering state
-- state:leave() - Called when leaving state
-- state:resume(previous, ...) - Called when returning to state via pop()
-- state:init() - Called once at game start if state is initial
-- state:update(dt) - Called every frame
-- state:draw() - Called every frame for rendering
-- state:event(event) - Called on input events
-- state:exit() - Called when game exits

return GameState
