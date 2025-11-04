--[[
Animation - Sprite sheet animation system for ReiLua-Enhanced

Features:
- Grid-based sprite sheet animation
- Multiple animation tracks per spritesheet
- Configurable FPS and looping
- Callbacks on animation complete
- Pause/resume/reset functionality

Usage:
  local Animation = require("lib.animation")
  
  -- Create animation from sprite sheet
  local playerAnim = Animation.new(
    playerTexture,    -- RL.LoadTexture("player.png")
    32, 32,          -- Frame width, height
    {
      idle = {frames = {1, 2, 3, 4}, fps = 8, loop = true},
      walk = {frames = {5, 6, 7, 8, 9, 10}, fps = 12, loop = true},
      jump = {frames = {11, 12, 13}, fps = 10, loop = false}
    }
  )
  
  playerAnim:play("idle")
  
  -- In update:
  playerAnim:update(dt)
  
  -- In draw:
  playerAnim:draw(x, y)
]]

local Animation = {}
Animation.__index = Animation

-- Create new animation from sprite sheet
function Animation.new(texture, frameWidth, frameHeight, animations)
  local self = setmetatable({}, Animation)
  
  self.texture = texture
  self.frameWidth = frameWidth
  self.frameHeight = frameHeight
  
  -- Calculate grid dimensions
  local texSize = RL.GetTextureSize(texture)
  self.columns = math.floor(texSize[1] / frameWidth)
  self.rows = math.floor(texSize[2] / frameHeight)
  
  -- Animation tracks
  self.animations = animations or {}
  
  -- Current state
  self.currentAnim = nil
  self.currentFrame = 1
  self.frameTimer = 0
  self.playing = false
  self.paused = false
  self.onComplete = nil
  
  -- Default tint and scale
  self.tint = RL.WHITE
  self.flipX = false
  self.flipY = false
  self.rotation = 0
  self.scale = {1, 1}
  self.origin = {frameWidth / 2, frameHeight / 2}
  
  return self
end

-- Add animation track
function Animation:addAnimation(name, frames, fps, loop)
  self.animations[name] = {
    frames = frames,
    fps = fps or 10,
    loop = loop ~= false  -- Default true
  }
end

-- Play animation
function Animation:play(name, onComplete)
  if not self.animations[name] then
    print("Warning: Animation '" .. name .. "' not found")
    return
  end
  
  -- Don't restart if already playing
  if self.currentAnim == name and self.playing then
    return
  end
  
  self.currentAnim = name
  self.currentFrame = 1
  self.frameTimer = 0
  self.playing = true
  self.paused = false
  self.onComplete = onComplete
end

-- Stop animation
function Animation:stop()
  self.playing = false
  self.currentFrame = 1
  self.frameTimer = 0
end

-- Pause animation
function Animation:pause()
  self.paused = true
end

-- Resume animation
function Animation:resume()
  self.paused = false
end

-- Reset to first frame
function Animation:reset()
  self.currentFrame = 1
  self.frameTimer = 0
end

-- Update animation
function Animation:update(dt)
  if not self.playing or self.paused or not self.currentAnim then
    return
  end
  
  local anim = self.animations[self.currentAnim]
  if not anim then return end
  
  self.frameTimer = self.frameTimer + dt
  local frameDuration = 1.0 / anim.fps
  
  -- Advance frames
  while self.frameTimer >= frameDuration do
    self.frameTimer = self.frameTimer - frameDuration
    self.currentFrame = self.currentFrame + 1
    
    -- Check if animation completed
    if self.currentFrame > #anim.frames then
      if anim.loop then
        self.currentFrame = 1
      else
        self.currentFrame = #anim.frames
        self.playing = false
        
        -- Call completion callback
        if self.onComplete then
          self.onComplete()
          self.onComplete = nil
        end
      end
    end
  end
end

-- Get source rectangle for current frame
function Animation:getFrameRect()
  if not self.currentAnim then
    return {0, 0, self.frameWidth, self.frameHeight}
  end
  
  local anim = self.animations[self.currentAnim]
  if not anim then
    return {0, 0, self.frameWidth, self.frameHeight}
  end
  
  -- Get frame index from animation
  local frameIndex = anim.frames[self.currentFrame] or 1
  
  -- Convert to grid position (0-indexed for calculation)
  local gridX = (frameIndex - 1) % self.columns
  local gridY = math.floor((frameIndex - 1) / self.columns)
  
  -- Calculate source rectangle
  local x = gridX * self.frameWidth
  local y = gridY * self.frameHeight
  local w = self.frameWidth
  local h = self.frameHeight
  
  -- Apply flip
  if self.flipX then
    w = -w
  end
  if self.flipY then
    h = -h
  end
  
  return {x, y, w, h}
end

-- Draw animation at position
function Animation:draw(x, y, rotation, scale, origin, tint)
  if not self.texture then return end
  
  local source = self:getFrameRect()
  local dest = {
    x,
    y,
    math.abs(source[3]) * (scale and scale[1] or self.scale[1]),
    math.abs(source[4]) * (scale and scale[2] or self.scale[2])
  }
  
  RL.DrawTexturePro(
    self.texture,
    source,
    dest,
    origin or self.origin,
    rotation or self.rotation,
    tint or self.tint
  )
end

-- Draw animation with simple position
function Animation:drawSimple(x, y)
  if not self.texture then return end
  
  local source = self:getFrameRect()
  RL.DrawTextureRec(self.texture, source, {x, y}, self.tint)
end

-- Set tint color
function Animation:setTint(color)
  self.tint = color
end

-- Set flip
function Animation:setFlip(flipX, flipY)
  self.flipX = flipX
  self.flipY = flipY
end

-- Set scale
function Animation:setScale(sx, sy)
  self.scale = {sx, sy or sx}
end

-- Set origin (rotation/scale point)
function Animation:setOrigin(ox, oy)
  self.origin = {ox, oy}
end

-- Check if animation is playing
function Animation:isPlaying(name)
  if name then
    return self.currentAnim == name and self.playing
  end
  return self.playing
end

-- Get current animation name
function Animation:getCurrentAnimation()
  return self.currentAnim
end

-- Get current frame number
function Animation:getCurrentFrame()
  return self.currentFrame
end

return Animation
