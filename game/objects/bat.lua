-- bat.lua
local enemy = require('game.objects.enemy')
local bat = require('classes.class')(enemy)

local mathx = require 'libs.mathx'
local cache = require 'managers.cache'

local sprite    = require 'game.sprite'
local collision = require 'game.collision'

local image = cache.getImage('assets/sprite/bat.png')
local frame = {
  -- x, y, w, h, ox, oy
  normal = {
    {  0, 0, 16, 16, 8, 8 },
    { 16, 0, 16, 16, 8, 8 },
  },
  dead = {
    { 32, 0, 16, 16, 8, 8 },
  }
}

local absmax_speed = 300
local gravity      = 420

function bat:initialize(x, y, properties)
  self.x, self.y = x, y
  self.width, self.height = 6, 6
  self.properties = properties
  self.sprite = sprite(image, frame)
  self.sprite:setAnimation('normal')
  self.sprite:setFrameDuration(1/9)

  self.sprite_flip = properties.direction == 'left' and -1 or 1
  self.sprite_angle = 0
  self.x_speed, self.y_speed = 0, 0
  self.timer = properties.modifier * 8
  self.speed = properties.move_speed
  self.reward = 30
end

function bat:update(dt)
  if self.state == 'dead' then
    self.x_speed = mathx.clamp(self.x_speed,                -absmax_speed, absmax_speed)
    self.y_speed = mathx.clamp(self.y_speed + gravity * dt, -absmax_speed, absmax_speed)
  else
    self.timer = self.timer + dt
    self.x_speed = self.speed * self.sprite_flip
    self.y_speed = math.cos(self.timer * 4) * 30
  end
  self:move(self.x_speed * dt, self.y_speed * dt)
  self:updateAnimation(dt)
  if not collision.camera_test(self) then
    gameroom:releaseInstance(self)
  end
end

function bat:updateAnimation(dt)
  if self.state == 'dead' then
    self.sprite:setAnimation('dead')
  else
    self.sprite:setAnimation('normal')
  end
  self.sprite:setFrameDuration(1/9)
  self.sprite:update(dt)
end

return bat
