-- enemy.lua
local object = require('game.objects.object')
local enemy  = require('classes.class')(object)
enemy._group_ = 'enemy'

local mathx = require 'libs.mathx'
local cache = require 'managers.cache'

local sprite    = require 'game.sprite'
local collision = require 'game.collision'

function enemy:damage(...)
  self:kill(...)
end

function enemy:kill(...)
  if self.state == 'dead' then return end
  self.state = 'dead'
  self.x_speed = 0
  self.y_speed = -90
  gameaudio:playSFX('kill.wav')
  gamestate:addScore(self.reward or 0)
  if self.onKill then self:onKill(...) end
end

function enemy:draw()
  love.graphics.push('all')
  if self.state == 'dead' then
    local a = self.y_speed / 180
    love.graphics.setColor(1, 1, 1, 1 - a)
  end
  local dx, dy = math.floor(self.x), math.floor(self.y)
  self.sprite:draw(dx, dy, self.sprite_angle, self.sprite_flip, 1)
  collision.draw_hitbox(self)
  love.graphics.pop()
end

function enemy:getNearestPlayer()
  local player
  local old_dist = math.huge
  for other in gameroom:eachFromGroup('player') do
    local dist = math.abs(self.x - other.x)
    if dist < old_dist then
      old_dist = dist
      player = other
    end
  end
  return player
end

return enemy
