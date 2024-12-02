-- placeholder.lua
local object = require('game.objects.object')
local placeholder = require('classes.class')(object)
local collision = require 'game.collision'

function placeholder:initialize(x, y, properties, object)
  self.x, self.y = x, y
  self.width, self.height = 2, 2
  self.properties = properties
end

function placeholder:update(dt)
  local l, t, r, b = gamecamera:getBoundaries()
  if self.properties.direction == 'left' and self.x >= r then
    gameroom:addInstance(self.properties.enemy, 'objects', self.x, self.y - 16, self.properties)
    gameroom:releaseInstance(self)
  elseif self.properties.direction == 'right' and self.x <= l then
    gameroom:addInstance(self.properties.enemy, 'objects', self.x, self.y - 16, self.properties)
    gameroom:releaseInstance(self)
  end
end

function placeholder:canUpdate()
  return collision.camera_test(self)
end

return placeholder
