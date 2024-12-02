-- item.lua
local object = require('game.objects.object')
local item = require('classes.class')(object)
item._group_ = 'item'

local mathx = require 'libs.mathx'
local cache = require 'managers.cache'

local sprite    = require 'game.sprite'
local collision = require 'game.collision'

local image = cache.getImage('assets/sprite/things.png')
local frame = {
  -- x, y, w, h, ox, oy
  normal = {
    {  0, 8, 16, 16, 8, 8 },
  },
}

local absmax_speed = 300
local gravity      = 360

function item:initialize(x, y, vx)
  self.x, self.y = x, y
  self.width, self.height = 6, 6
  self.sprite = sprite(image, frame)
  self.sprite:setAnimation('normal')
  self.sprite:setFrameDuration(1/15)

  self.sprite_flip = 1
  self.sprite_angle = 0
  self.x_speed, self.y_speed = vx, -180
  self.floor_sensor = 6
end

function item:update(dt)
  self.x_speed = mathx.clamp(self.x_speed,                -absmax_speed, absmax_speed)
  self.y_speed = mathx.clamp(self.y_speed + gravity * dt, -absmax_speed, absmax_speed)
  self:move(self.x_speed * dt, self.y_speed * dt)
  local l, t, r, b = gamecamera:getBoundaries()
  if self.x > r and self.x_speed > 0 then
    self.x_speed = -self.x_speed
  elseif self.x < l and self.x_speed < 0 then
    self.x_speed = -self.x_speed
  end
  self.sprite:update(dt)
  local y = self:hasFloorCollision()
  if y then self.y, self.x_speed = y - self.floor_sensor, 0 end
  if not collision.camera_test(self) then
    gameroom:releaseInstance(self)
  end
end

function item:draw()
  love.graphics.push('all')
  local dx, dy = math.floor(self.x), math.floor(self.y)
  self.sprite:draw(dx, dy, self.sprite_angle, self.sprite_flip, 1)
  --collision.draw_hitbox(self)
  love.graphics.pop()
end


function item:pick()
  gameaudio:playSFX('item.wav')
  gamestate:chargeWeapon(1)
  gameroom:releaseInstance(self)
end

return item
