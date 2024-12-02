-- energyorb.lua
local object = require('game.objects.object')
local energyorb = require('classes.class')(object)
energyorb._group_ = 'bullet'

local cache = require 'managers.cache'

local sprite    = require 'game.sprite'
local collision = require 'game.collision'

local image = cache.getImage('assets/sprite/dracula.png')
local frame = {
  -- x, y, w, h, ox, oy
  wait = {
    { 120, 40, 16, 16, 8, 8 },
    { 136, 40, 16, 16, 8, 8 },
  },
  move = {
    { 120, 56, 16, 16, 8, 8 },
    { 120, 72, 16, 16, 8, 8 },
    { 120, 56, 16, 16, 8, 8 },
    { 136, 72, 16, 16, 8, 8 },
  },
}

local function new_particles()
  local particlesystem = love.graphics.newParticleSystem(image)
  particlesystem:setParticleLifetime(0.25)
  particlesystem:setEmissionRate(60)
  local q1 = love.graphics.newQuad(96, 56, 8, 8, image)
  local q2 = love.graphics.newQuad(96, 64, 8, 8, image)
  particlesystem:setQuads( q1, q2, q1, q2, q1, q2 )
  particlesystem:setEmitterLifetime(-1)
  particlesystem:setRadialAcceleration( -90 )
  particlesystem:setSpread( math.rad(360) )
  particlesystem:setSpeed(60)
  particlesystem:setEmissionArea('uniform', 8, 8, math.rad(360), true )
  return particlesystem
end

function energyorb:initialize(x, y, dir)
  self.x, self.y = x, y
  self.width, self.height = 6, 6
  self.sprite_flip = dir
  self.sprite = sprite(image, frame)
  self.sprite:setAnimation('wait')
  self.sprite:setFrameDuration(1/15)
  self.wait = 0.5
  self.x_speed = 0
  self.particles = new_particles()
end

function energyorb:update(dt)
  self.wait = self.wait - dt
  if self.wait <= 0 then
    self.x_speed = self.x_speed + 160 * self.sprite_flip * dt
    self:move(self.x_speed * dt, 0)
    self.sprite:setAnimation('move')
    if not self.flag then
      self.flag = true
      gameaudio:playSFX('fireball.wav')
    end
  end
  self:checkTarget()
  self.particles:update(dt)
  self.sprite:update(dt)
  self.particles:setPosition( math.floor(self.x), math.floor(self.y) )
  if not collision.camera_test(self, 64) then
    gameroom:releaseInstance(self)
  end
end

function energyorb:draw()
  love.graphics.push('all')
  local dx, dy = math.floor(self.x), math.floor(self.y)
  love.graphics.draw(self.particles)
  self.sprite:draw(dx, dy, self.sprite_angle, self.sprite_flip, 1)
  collision.draw_hitbox(self)
  love.graphics.pop()
end

function energyorb:checkTarget()
  for other in gameroom:eachFromGroup('player') do
    if collision.test(self, other) then
      other:kill()
    end
  end
end


return energyorb
