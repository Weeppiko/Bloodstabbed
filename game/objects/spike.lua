-- spike.lua
local object = require('game.objects.object')
local spike = require('classes.class')(object)
spike._group_ = 'bullet'

local cache = require 'managers.cache'
local collision = require 'game.collision'

local image = cache.getImage('assets/sprite/dracula.png')
local quad = love.graphics.newQuad(104, 56, 8, 40, image)

function spike:initialize(x, y)
  self.x, self.y = x, y
  self.target_up = y - 32
  self.target_down = y + 24
  self.width, self.height = 3, 15
  self.wait = 1
  self.sustain = 0.5
  self.decay = 1
  self.flag = false
  self.draw_priority = 9999
end

function spike:update(dt)
  self.wait = self.wait - dt
  if self.wait <= 0 then
    if not self.flag then
      self.flag = true
      gameaudio:playSFX('spike.wav')
    end
    self.sustain = self.sustain - dt
    if self.sustain > 0 then
      self.y = mathx.smoothApproach(self.y, self.target_up, dt * 32)
    else
      self.decay = self.decay - dt
      self.y = mathx.smoothApproach(self.y, self.target_down, dt * 8)
      if self.decay < 0 then
        return gameroom:releaseInstance(self)
      end
    end
  end
  self:checkTarget()
end

function spike:draw()
  love.graphics.push('all')
  local dx, dy = math.floor(self.x), math.floor(self.y)
  love.graphics.draw(image, quad, dx, dy, 0, 1, 1, 4, 24)
  love.graphics.pop()
end

function spike:checkTarget()
  for other in gameroom:eachFromGroup('player') do
    if collision.test(self, other) then
      other:kill()
    end
  end
end


return spike
