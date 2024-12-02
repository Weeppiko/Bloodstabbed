-- sprite.lua
local sprite = { }
sprite.__index = sprite

local function newSprite(image, anim_list)
  return setmetatable({
    image = image,
    quad = love.graphics.newQuad(1, 1, 1, 1, 1, 1),
    animations = anim_list,
    animation_mode = 'loop',
    current_animation = nil,
    current_frame = 1,
    frame_timer = 0,
    frame_direction = 1,
    frame_duration = 1/60,
    is_playing = true,
  }, sprite)
end

function sprite:update(dt)
  if not self.is_playing then return end
  self.frame_timer = self.frame_timer + dt
  if self.frame_timer >= self.frame_duration then
    local anim = self.animations[self.current_animation]
    if (not anim) or #anim == 0 then return end
    self.frame_timer = self.frame_timer - self.frame_duration
    if self.animation_mode == 'once' then
      self.current_frame = self.current_frame + 1
      if self.current_frame > #anim then
        self.current_frame = #anim
        self.is_playing = false
      end
    elseif self.animation_mode == 'ping_pong' then
      if self.frame_direction == 1 then
        self.current_frame = math.min(self.current_frame + 1, #anim)
        if self.current_frame == #anim then
          self.frame_direction = -1
        end
      elseif self.frame_direction == -1 then
        self.current_frame = math.max(self.current_frame - 1, 1)
        if self.current_frame == 1 then
          self.frame_direction = 1
        end
      end
    else
      self.current_frame = self.current_frame + 1
      if self.current_frame > #anim then
        self.current_frame = 1
      end
    end
  end
end

function sprite:draw(x, y, r, sx, sy, ox, oy, ...)
  local anim = self.animations[self.current_animation]
  if (not anim) or #anim == 0 then return end
  local qx, qy, qw, qh, qox, qoy = unpack(anim[self.current_frame])
  self.quad:setViewport(qx, qy, qw, qh, self.image:getDimensions())
  love.graphics.draw(self.image, self.quad, x, y, r, sx, sy, (ox or 0) + qox, (oy or 0) + qoy)
end

function sprite:setAnimation(animation, mode)
  if animation == self.current_animation then
    if mode ~= self.animation_mode then
      self.animation_mode = mode
      self:resetAnimation()
    end
  else
    self.animation_mode = mode
    self.current_animation = animation
    self:resetAnimation()
  end
end

function sprite:setFrameDuration(frame_duration)
  self.frame_duration = math.max(frame_duration, 1/60)
end

function sprite:resetAnimation()
  local anim = self.animations[self.current_animation]
  self.current_frame = 1
  self.frame_timer = 0
  self.frame_direction = 1
  self.is_playing = true
end

function sprite:pause()
  self.is_playing = false
end

function sprite:resume()
  self.is_playing = true
end

return newSprite
