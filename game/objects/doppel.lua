-- doppel.lua
local enemy = require('game.objects.enemy')
local doppel = require('classes.class')(enemy)

local mathx = require 'libs.mathx'
local cache = require 'managers.cache'

local sprite    = require 'game.sprite'
local collision = require 'game.collision'

local image1 = cache.getImage('assets/sprite/player.png')
local image2 = cache.getImage('assets/sprite/player2.png')
local frame = {
  -- x, y, w, h, ox, oy
  stand = {
    { 32, 0, 32, 32, 16, 20 },
  },
  jump = {
    { 64, 0, 32, 32, 16, 20 },
  },
  fall = {
    { 64, 0, 32, 32, 16, 20 },
  },
  walk = {
    {  0, 0, 32, 32, 16, 20 },
    { 32, 0, 32, 32, 16, 20 },
    { 64, 0, 32, 32, 16, 20 },
    { 96, 0, 32, 32, 16, 20 },
  },
  knife = {
    --{  0, 0, 32, 32, 16, 20 },
    {  128, 0, 32, 32, 16, 20 },
  },
  climb = {
    {  96,  32, 32, 32, 16, 20 },
    {  128, 32, 32, 32, 16, 20 },
  },
  crouch = {
    {   0, 32, 64, 16, 32, 10 },
  },
  crouch_knife = {
    --{   0, 32, 64, 16, 32, 10 },
    { 0, 48, 64, 16, 32, 10 },
  },
  death_airborne = {
    { 0, 64, 32, 32, 16, 20 },
  },
  dead = {
    { 32, 80, 32, 16, 16, 4 },
  },
}

-- physics constants
local move_speed    = 62
local absmax_xspeed = 120
local absmax_yspeed = 300
local gravity       = 420
local jump_force    = 160

function doppel:initialize(x, y, properties)
  self.x, self.y = x, y
  self.width, self.height = 5, 9
  self.properties = properties
  self.sprite = sprite(image1, frame)
  self.sprite:setAnimation('stand')
  self.sprite:setFrameDuration(1/9)
  self.sprite_flip = properties.direction == 'left' and -1 or 1
  self.sprite_angle = 0
  self.x_speed = properties.move_speed * self.sprite_flip
  self.y_speed = 0
  self.state = 'landed'
  self.gravity = gravity
  self.floor_sensor = 12
  self.wall_sensor = 4
  self.timer = 0
  self:checkCollision()
end

function doppel:update(dt)
  self.timer = self.timer + dt
  self.last_x, self.last_y = self.x, self.y

  self.x_speed = mathx.clamp(self.x_speed,          -absmax_xspeed, absmax_xspeed)
  self.y_speed = mathx.clamp(self.y_speed + self.gravity * dt, -absmax_yspeed, absmax_yspeed)
  self:move(self.x_speed * dt, self.y_speed * dt)

  self:checkCollision()
  self:updateAnimation(dt)

  if not collision.camera_test(self) then
    gameroom:releaseInstance(self)
  end
end

function doppel:updateAnimation(dt)
  if self.state == 'dead' then
    self.sprite:setAnimation('dead')
  elseif self.state == 'falling' then
    self.sprite:setAnimation('fall')
  else
    self.sprite:setAnimation('walk')
  end
  self.sprite:setFrameDuration(1/9)
  self.sprite:update(dt)
  if (self.timer * 60) % 8 < 4 then
    self.sprite.image = image1
  else
    self.sprite.image = image2
  end
end

function doppel:checkCollision()
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

function doppel:onKill(knife)
  if knife then
    gameroom:addInstance('item', self.layer_id, self.x, self.y, -self.sprite_flip * 90)
    gameroom:releaseInstance(self)
  else
    self.state = 'dead'
  end
end



return doppel
