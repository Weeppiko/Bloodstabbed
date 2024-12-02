-- spawner.lua
local object = require('game.objects.object')
local spawner = require('classes.class')(object)

local mathx = require 'libs.mathx'
local cache = require 'managers.cache'
local collision = require 'game.collision'

function spawner:initialize(x, y, properties, object)
  self.x, self.y = x, y
  self.properties = properties
  self.bias = 0.5
  local v = love.math.random() * self.properties.variation
  self.timer = self.properties.frequency + v
end

function spawner:update(dt)
  self.timer = self.timer - dt
  if self.timer <= 0 then
    if self:spawn() then
      local v = love.math.random() * self.properties.variation
      self.timer = self.properties.frequency + v
    end
  end
end

function spawner:canUpdate()
  return collision.camera_test(self)
end

local function get_floor_type(tx, ty)
  local tile_id = gameroom:getTileID(tx, ty, 'tiles')
  return gameroom:getTileProperty(tile_id, 'type')
end

local function has_floor(x, y)
  x, y = gameroom:positionToGrid(x, y)
  local a = get_floor_type( x, y )
  local b = get_floor_type( x, y - 1 )
  if a and a ~= 'ladder' then return true end
  if a and not b then return true end
end

function spawner:spawn()
  local l, t, r, b = gamecamera:getBoundaries()
  local side = love.math.random() < 0.5 and 'left' or 'right'
  if self.properties.sides == 'left'  then side = 'left'  end
  if self.properties.sides == 'right' then side = 'right' end
  if side == 'left' then
    if (not self.properties.meet_floor) or has_floor(l + 4, self.y) then
      local properties = { modifier = love.math.random(), direction = 'right' }
      gameroom:addInstance(self.properties.enemy, 'objects', l - 8, self.y - 16, properties)
    end
    return true
  elseif side == 'right' then
    if (not self.properties.meet_floor) or has_floor(r - 4, self.y) then
      local properties = { modifier = love.math.random(), direction = 'left' }
      gameroom:addInstance(self.properties.enemy, 'objects', r + 8, self.y - 16, properties)
    end
    return true
  end
end

return spawner
