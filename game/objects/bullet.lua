-- bullet.lua
local object = require('game.objects.object')
local bullet = require('classes.class')(object)
bullet._group_ = 'bullet'

local mathx = require 'libs.mathx'
local cache = require 'managers.cache'

local sprite    = require 'game.sprite'
local collision = require 'game.collision'

local image = cache.getImage('assets/sprite/things.png')
local frame = {
  -- x, y, w, h, ox, oy
  basic = {
    { 0, 0, 8, 8, 4, 4 },
    { 8, 0, 8, 8, 4, 4 },
    { 16, 0, 8, 8, 4, 4 },
    { 24, 0, 8, 8, 4, 4 },
  },
}

local sound_knife = cache.getSound('assets/sound/kill.wav')

local absmax_speed = 300
local gravity      = 420

function bullet:initialize(x, y, vx, vy, target, btype)
  self.x, self.y = x, y
  self.width, self.height = 3, 3
  self.sprite = sprite(image, frame)
  self.sprite:setAnimation(btype or 'basic')
  self.sprite:setFrameDuration(1/15)

  self.sprite_flip = 1
  self.sprite_angle = 0
  self.x_speed, self.y_speed = vx, vy
  self.target = target
  self.draw_priority = 1000
end

function bullet:update(dt)
  self.x_speed = mathx.clamp(self.x_speed, -absmax_speed, absmax_speed)
  self.y_speed = mathx.clamp(self.y_speed, -absmax_speed, absmax_speed)
  self:move(self.x_speed * dt, self.y_speed * dt)
  self:checkTarget()
  if not collision.camera_test(self) then
    gameroom:releaseInstance(self)
  end
  self.sprite:update(dt)
end

function bullet:draw()
  love.graphics.push('all')
  local dx, dy = math.floor(self.x), math.floor(self.y)
  self.sprite:draw(dx, dy, self.sprite_angle, self.sprite_flip, 1)
  love.graphics.pop()
end

function bullet:checkTarget()
  for other in gameroom:eachFromGroup(self.target) do
    if collision.test(self, other) then
      other:kill()
    end
  end
end


return bullet
