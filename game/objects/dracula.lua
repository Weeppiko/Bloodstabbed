-- dracula.lua
local enemy = require('game.objects.enemy')
local dracula = require('classes.class')(enemy)

local mathx = require 'libs.mathx'
local cache = require 'managers.cache'

local sprite    = require 'game.sprite'
local collision = require 'game.collision'

local state = { }
local image = cache.getImage('assets/sprite/dracula.png')
local frame = {
  -- x, y, w, h, ox, oy
  stand = {
    { 0, 0, 32, 40, 12, 24 },
  },
  attack = {
    { 32, 0, 32, 40, 12, 24 },
    { 64, 0, 32, 40, 12, 24 },
  },
  retreat = {
    { 96, 0, 32, 40, 12, 24 },
    { 0, 0, 32, 40, 12, 24 },
  },
  float = {
    { 0, 40, 48, 48, 24, 16 },
  },
  hurt = {
    { 128, 0, 32, 40, 12, 24 },
  },
  dead = {
    { 48, 40, 48, 48, 24, 16 },
  },
}

local function new_particles()
  local particlesystem = love.graphics.newParticleSystem(image)
  particlesystem:setParticleLifetime(0.5)
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


function dracula:initialize(x, y)
  self.x, self.y = x + 64, y
  self.pivot = x
  self.width, self.height = -math.huge, -math.huge
  self.sprite = sprite(image, frame)
  self.sprite:setAnimation('stand')
  self.sprite:setFrameDuration(1/9)
  self.sprite_flip = -1
  self.sprite_angle = 0
  self.opacity = 0
  self.health = 20
  self.phase = 1
  self.state = state.start(self)
  self.damage_timer = 0
  self.sequence = { -1, 1, 1, -1, 1, -1, -1, 1, 1, -1, -1, 1, -1, 1, -1, 1 }
  self.particles = new_particles()
  self.particles:stop()
  self.attack_bias = 0.5
  self.clouds = gameroom:addInstance('clouds', 'tiles_back')
  self.offset = 0
end

function dracula:update(dt)
  self.state()
  self.damage_timer = self.damage_timer - dt
  self.no_damage = self.damage_timer > 0
  self.particles:update(dt)
  self.sprite:update(dt)
  if self.phase == 2 then
    if self.damage_timer > 0 then
      self.sprite:setAnimation('dead')
    else
      self.offset = self.offset + dt
      self.y = 48 + math.sin(self.offset) * 4
      self.sprite:setAnimation('float')
    end
  end
end

function dracula:draw()
  love.graphics.push('all')
  local a = self.damage_timer > 0 and math.floor( (self.damage_timer * 60) % 2 ) or 1
  love.graphics.setColor(1, 1, 1, self.opacity * a)
  local dx, dy = math.floor(self.x), math.floor(self.y)
  if self.phase == 1 then
    self.sprite:draw(dx, dy, self.sprite_angle, self.sprite_flip, 1)
    love.graphics.draw(self.particles, dx, dy)
  else
    love.graphics.draw(self.particles, dx, dy)
    self.sprite:draw(dx, dy, self.sprite_angle, self.sprite_flip, 1)
  end
  collision.draw_hitbox(self)
  love.graphics.pop()
end

function dracula:damage()
  if self.damage_timer > 0 then return end
  self.damage_timer = 1
  gameaudio:playSFX('kill.wav')
  self.health = self.health - 1
  if self.health <= 10 and self.phase ~= 2 then
    self.state = state.hurt(self)
  end
  if self.health <= 0 then
    self.started = false
    self.state = state.death(self)
    self.width, self.height = -math.huge, -math.huge
    for enemy in gameroom:eachFromGroup('enemy') do
      if enemy ~= self then enemy:kill() end
    end
    gameaudio:fadeBGM(0.75, 0, 1)
    gameaudio:playSFX('huge_death.wav')
    gamestate:addScore(10000)
  end
end


function dracula:getSequence()
  local v = self.sequence[1]
  self.sequence[1] = -self.sequence[1]
  tablx.lshift(self.sequence)
  return v
end

local dt = love.timer.getDelta
local function wait(x)
  while x > 0 do
    x = x - dt()
    coroutine.yield()
  end
end

local function fadein(self)
  self.particles:start()
  while self.opacity < 1 do
    self.opacity = math.min(self.opacity + dt(), 1)
    coroutine.yield()
  end
  self.particles:stop()
  self.width, self.height = 8, 16
  self.damage_timer = 0
end

local function fadeout(self, snext)
  self.damage_timer = 1e10
  self.width, self.height = -math.huge, -math.huge
  self.particles:start()
  wait(0.5)
  while self.opacity > 0 do
    self.opacity = math.max(self.opacity - dt(), 0)
    coroutine.yield()
  end
  self.particles:stop()
end

local function throw_orbs(self)
  local ox = self.sprite_flip * 16
  if love.math.random() < 0.5 then
    gameroom:addInstance('energyorb', 'objects', self.x + ox, self.y + 6, self.sprite_flip)
    wait(1)
    gameroom:addInstance('energyorb', 'objects', self.x + ox, self.y - 6, self.sprite_flip)
    wait(1)
    gameroom:addInstance('energyorb', 'objects', self.x + ox, self.y + 6, self.sprite_flip)
    wait(1)
  else
    gameroom:addInstance('energyorb', 'objects', self.x + ox, self.y - 6, self.sprite_flip)
    wait(1)
    gameroom:addInstance('energyorb', 'objects', self.x + ox, self.y + 6, self.sprite_flip)
    wait(1)
    gameroom:addInstance('energyorb', 'objects', self.x + ox, self.y - 6, self.sprite_flip)
    wait(2)
  end
end

local function cast_spikes(self)
  local x = self.sprite_flip
  for i = 1, 6 do
    gameroom:addInstance('spike', 'tiles_back', self.x + x * i * 24, 144)
    wait(0.2)
  end
  wait(1)
end


function state.start(self)
  return coroutine.wrap(function()
    fadein(self)
    wait(2)
    fadeout(self)
    wait(1)
    self.state = state.loop(self)
  end)
end

function state.loop(self)
  return coroutine.wrap(function()
    local dir = self:getSequence()
    self.x = self.pivot + 64 * dir
    self.sprite_flip = -dir

    fadein(self)
    wait(1)

    self.sprite:setAnimation('attack', 'once')
    if love.math.random() < self.attack_bias then
      self.attack_bias = self.attack_bias - 0.25
      throw_orbs(self)
    else
      self.attack_bias = self.attack_bias + 0.25
      cast_spikes(self)
    end

    self.sprite:setAnimation('retreat', 'once')
    wait(1)

    fadeout(self)
    self.state = state.loop(self)
  end)
end

function state.hurt(self)
  return coroutine.wrap(function()
    self.opacity = 1
    self.sprite:setAnimation('hurt')
    self.width, self.height = -math.huge, -math.huge
    self.damage_timer = 1e10
    wait(1)
    fadeout(self)
    wait(2)
    self.phase = 2
    self.state = state.rise(self)
    self.layer_id = 'tiles_back'
    self.draw_priority = 9999
    self.particles:start()
    self.particles:setSpeed(90)
  end)
end

function state.rise(self)
  return coroutine.wrap(function()
    self.opacity = 1
    self.sprite:setAnimation('float')
    self.x, self.y = self.pivot, 180
    while self.y > 50 do
      self.y = mathx.smoothApproach(self.y, 48, dt() * 4)
      self.clouds.strength = mathx.smoothApproach(self.clouds.strength, 0.4, dt())
      coroutine.yield()
    end
    self.damage_timer = 0
    self.state = state.float(self)
  end)
end

function state.float(self)
  local bias =  0.5
  local rand = love.math.random
  local y = gameroom:chooseFromGroup('player', function(a, b) return a.x > b.x end).y_land
  local l, t, r, b = gamecamera:getBoundaries()
  local list = { 'undead', 'doppel', 'undead', 'bat', 'skeleton', 'bat', 'doppel', 'bat', 'skeleton', 'werewolf', 'doppel', 'undead', 'skeleton', 'bat', 'doppel', 'werewolf', 'undead', }
  return coroutine.wrap(function()
    while true do
      wait( 0.25 + rand() * 0.5 )
      local y = y
      local e = list[1]
      tablx.rshift(list)
      if rand() < bias then
        bias = bias - 0.25
        local properties = { direction = 'right', move_speed = 50 + rand(10), modifier = rand() }
        if e == 'bat' then y = - 8 end
        if e == 'doppel' then properties.move_speed = properties.move_speed - 5 end
        gameroom:addInstance(e, 'objects', l, y, properties)
      else
        bias = bias + 0.25
        local properties = { direction = 'left', move_speed = 50 + rand(10), modifier = rand() }
        if e == 'bat' then y = - 8 end
        if e == 'doppel' then properties.move_speed = properties.move_speed - 5 end
        gameroom:addInstance(e, 'objects', r, y, properties)
      end
      coroutine.yield()
    end
  end)
end

function state.death(self)
  self.damage_timer = 1e5
  return coroutine.wrap(function()
    local time = 3
    while time > 0 do
      time = time - dt()
      self.y = self.y + 60 * dt()
      coroutine.yield()
    end
    gameroom:releaseInstance(self)
    gamescreen:fadeout(2)
    gamescene.set('scenes.ending')
  end)
end


return dracula
