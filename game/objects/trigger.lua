-- trigger.lua
local object = require('game.objects.object')
local trigger  = require('classes.class')(object)
trigger._group_ = 'trigger'

function trigger:initialize(x, y, properties)
  self.x, self.y = x, y
  self.properties = properties
end

function trigger:update(dt)
  if self:checkPlayers() then
    local _g = setmetatable( { self = self }, { __index = _G } )
    local f = loadstring(self.properties.script)
    setfenv(f, _g)
    f()
    gameroom:releaseInstance(self)
  end
end

function trigger:checkPlayers()
  local has_player
  for player in gameroom:eachFromGroup('player') do
    has_player = true
    if player.x < self.x then
      return false
    end
  end
  return has_player
end

return trigger
