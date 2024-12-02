-- undead.lua
local enemy = require('game.objects.enemy')
local undead = require('classes.class')(enemy)

local mathx = require 'libs.mathx'
local cache = require 'managers.cache'

local sprite    = require 'game.sprite'
local collision = require 'game.collision'

local image = cache.getImage('assets/sprite/undead.png')
local frame = {
  -- x, y, w, h, ox, oy
  stand = {
    { 0, 0, 32, 32, 16, 20 },
    { 32, 0, 32, 32, 16, 20 },
    { 64, 0, 32, 32, 16, 20 },
    { 96, 0, 32, 32, 16, 20 },
  },
  dead = {
    { 128, 0, 32, 32, 16, 20 },
  },
  fall = {
    { 32, 0, 32, 32, 16, 20 },
  }
}

-- physics constants
local move_speed    = 62
local absmax_xspeed = 120
local absmax_yspeed = 300
local gravity       = 420
local jump_force    = 160

function undead:initialize(x, y, properties)
  self.x, self.y = x, y
  self.width, self.height = 7, 9
  self.properties = properties
  self.sprite = sprite(image, frame)
  self.sprite:setAnimation('stand')
  self.sprite:setFrameDuration(1/9)
  self.sprite_flip = properties.direction == 'left' and -1 or 1
  self.sprite_angle = 0
  self.reward = 20
  self.x_speed = properties.move_speed * self.sprite_flip
  self.y_speed = 0
  self.state = 'landed'
  self.gravity = gravity
  self.floor_sensor = 12
  self.wall_sensor = 4
  self:checkCollision()
end

function undead:update(dt)
  self.last_x, self.last_y = self.x, self.y

  self.x_speed = mathx.clamp(self.x_speed,          -absmax_xspeed, absmax_xspeed)
  self.y_speed = mathx.clamp(self.y_speed + self.gravity * dt, -absmax_yspeed, absmax_yspeed)
  self:move(self.x_speed * dt, self.y_speed * dt)

  self:checkCollision()
  self:updateAnimation(dt)

  if not collision.camera_test(self) then
    gameroom:releaseInstance(self)
  elseif self.state == 'dead' and self.y_speed >= 180 then
    gameroom:releaseInstance(self)
  end
end

function undead:updateAnimation(dt)
  if self.state == 'dead' then
    self.sprite:setAnimation('dead')
  elseif self.state == 'falling' then
    self.sprite:setAnimation('fall')
  else
    self.sprite:setAnimation('stand')
  end
  self.sprite:setFrameDuration(1/9)
  self.sprite:update(dt)
end

function undead:checkCollision()
  if self.state == 'dead' then return end
  local y = self:hasFloorCollision()
  if y then
    self.y = y - self.floor_sensor
    self.state = 'landed'
    self.y_speed = 0
  else
    self.state = 'falling'
  end
end

return undead