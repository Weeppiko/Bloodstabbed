-- skeleton.lua
local enemy = require('game.objects.enemy')
local skeleton = require('classes.class')(enemy)

local mathx = require 'libs.mathx'
local cache = require 'managers.cache'

local sprite    = require 'game.sprite'
local collision = require 'game.collision'

local image = cache.getImage('assets/sprite/skeleton.png')
local frame = {
  -- x, y, w, h, ox, oy
  stand = {
    { 0, 16, 32, 16, 16, 8 },
  },
  dead = {
    { 224, 0, 32, 32, 16, 16 },
  },
}

local absmax_speed = 300
local gravity      = 420

function skeleton:initialize(x, y, properties)
  self.x, self.y = x, y
  self.width, self.height = 6, 7
  self.sprite = sprite(image, frame)
  self.sprite:setAnimation('stand')
  self.sprite:setFrameDuration(1/9)
  self.sprite_flip = properties.direction == 'left' and -1 or 1
  self.sprite_angle = 0
  self.x_speed, self.y_speed = 0, 0
  self.timer = 0.5
  self.reward = 50
end

function skeleton:update(dt)
  if self.state == 'dead' then
    self.x_speed = mathx.clamp(self.x_speed,                -absmax_speed, absmax_speed)
    self.y_speed = mathx.clamp(self.y_speed + gravity * dt, -absmax_speed, absmax_speed)
    self:move(self.x_speed * dt, self.y_speed * dt)
  else
    self:checkPlayer()
  end
  if collision.camera_test(self) and self.state ~= 'dead' then
    self.timer = self.timer - dt
    if self.timer <= 0 then
      self.timer = self.timer + 2
      local x = self.x + 12 * self.sprite_flip
      local vx = 70 * self.sprite_flip
      gameroom:addInstance('bullet', 'objects', x, self.y, vx, 0, 'player')
    end
  end
  self:updateAnimation(dt)
end

function skeleton:updateAnimation(dt)
  if self.state == 'dead' then
    self.sprite:setAnimation('dead')
  else
    self.sprite:setAnimation('stand')
  end
  self.sprite:update(dt)
end

function skeleton:checkPlayer()
  local player = self:getNearestPlayer()
  if not player then return end
  if self.x < player.x then
    self.sprite_flip = 1
  else
    self.sprite_flip = -1
  end
end


return skeleton
