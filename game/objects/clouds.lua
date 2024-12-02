-- clouds.lua
local object = require('game.objects.object')
local clouds = require('classes.class')(object)

local mathx = require 'libs.mathx'
local cache = require 'managers.cache'

local layer = cache.getImage('assets/sprite/clouds1.png')
local shader  = love.graphics.newShader('shaders/wave.glsl')

function clouds:initialize()
  self.opacity = 0
  self.cycle = 0
  self.x, self.y = gamecamera:getBoundaries()
  self.quad = love.graphics.newQuad(0, 0, 160, 144, layer)
  self.strength = 0
  layer:setWrap('repeat')
end

function clouds:update(dt)
  self.cycle = self.cycle + dt
  self.opacity = math.min(1, self.opacity + dt)
  self.x, self.y = gamecamera:getBoundaries()
  local x, y, w, h = self.quad:getViewport()
  self.quad:setViewport(x + dt * 15, y + dt * 20, w, h)
end

function clouds:draw()
  love.graphics.push('all')
  love.graphics.setShader(shader)
  love.graphics.setColor(1, 1, 1, math.floor(self.opacity))
  shader:send('wave_phase', self.cycle)
  shader:send('wave_strength', self.strength)
  love.graphics.draw(layer, self.quad, self.x, self.y)
  love.graphics.pop()
end

return clouds
