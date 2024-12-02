-- megaskeleton.lua
local enemy = require('game.objects.enemy')
local megaskeleton = require('classes.class')(enemy)
local chain = require 'classes.chain'

local mathx = require 'libs.mathx'
local cache = require 'managers.cache'

local sprite    = require 'game.sprite'
local collision = require 'game.collision'

local image = cache.getImage('assets/sprite/skeleton_boss.png')
local quad_body = love.graphics.newQuad(0,  40, 80, 64, image)
local quad_head = love.graphics.newQuad(0,   0, 32, 40, image)
local quad_hand = love.graphics.newQuad(48,  0, 32, 16, image)
local quad_arm  = love.graphics.newQuad(64, 24, 16, 16, image)
local state = { }

local dt = love.timer.getDelta

function megaskeleton:initialize(x)
  self.layer_id = 'tiles_back'
  self.x, self.y = x, 88 + 128
  self.width, self.height = -math.huge, -math.huge
  self.pivot_x, self.pivot_y = x, 56
  self.offset = 0
  self.damage_timer = 0
  self.count = 0
  self.spawn_time = 1
  self.started = false
  self.health = 20
  self:reset(self.x, self.y)
end

function megaskeleton:reset(x, y)
  self.head = { x = 0, y = 0,  r = 0 }
  self.body = { x = 0, y = 32, r = 0 }

  self.arml = { x = x - 32, y = y + 32, r = 0 }
  self.armr = { x = x + 32, y = y + 32, r = 0 }

  self.l_chain = chain(8, image, quad_arm)
  self.r_chain = chain(8, image, quad_arm)

  self.state = state.rise(self)
end

function megaskeleton:damage()
  if self.damage_timer > 0 then return end
  self.damage_timer = 0.5
  gameaudio:playSFX('kill.wav')
  self.health = self.health - 1
  if self.health <= 0 then
    self.started = false
    self.state = state.death(self)
    self.width, self.height = -math.huge, -math.huge
    for enemy in gameroom:eachFromGroup('enemy') do
      if enemy ~= self then enemy:kill() end
    end
    gameaudio:fadeBGM(0.75, 0, 1)
    gameaudio:playSFX('huge_death.wav')
    gamestate:addScore(5000)
  end
end

function megaskeleton:update(dt)
  self.state()
  self.damage_timer = self.damage_timer - dt
  self.l_chain:setPositions(self.x - 32, self.y + 28, self.arml.x, self.arml.y)
  self.r_chain:setPositions(self.x + 32, self.y + 28, self.armr.x, self.armr.y)
  if self.started then self:updateSpawner(dt) end
end

function megaskeleton:updateSpawner(dt)
  self.count = self.count + dt
  if self.count >= self.spawn_time then
    self.count = self.count - self.spawn_time
    if self.health <= 5 then
      self.spawn_time = 0.5 + love.math.random()
    elseif self.health <= 10 then
      self.spawn_time = 1.0 + love.math.random()
    else
      self.spawn_time = 2.0 + love.math.random()
    end
    local l, t, r, b = gamecamera:getBoundaries()
    local side = love.math.random() < 0.5 and 'left' or 'right'
    if side == 'left' then
      local properties = { direction = 'right' }
      gameroom:addInstance('skeleton', 'objects', l + 4, 144 - 28, properties)
    elseif side == 'right' then
      local properties = { direction = 'left' }
      gameroom:addInstance('skeleton', 'objects', r - 4, 144 - 28, properties)
    end
  end
end

function megaskeleton:draw()
  love.graphics.push('all')
  local x, y = math.floor(self.x), math.floor(self.y)
  local a = math.floor( (self.damage_timer * 60) % 2 )
  if self.health < 1 then love.graphics.setColor(1, 1, 1, a ) end
  love.graphics.draw(image, quad_body, math.floor(x+self.body.x), math.floor(y+self.body.y), self.body.r, 1, 1, 40, 32)
  if self.damage_timer > 0 then love.graphics.setColor(1, 1, 1, a ) end
  love.graphics.draw(image, quad_head, math.floor(x+self.head.x), math.floor(y+self.head.y), self.head.r, 1, 1, 16, 24)
  if self.health > 0 then love.graphics.setColor(1, 1, 1) end

  self.l_chain:draw(); self.r_chain:draw()
  love.graphics.draw(image, quad_hand, math.floor(self.arml.x), math.floor(self.arml.y), self.arml.r, -1, 1, 16, 8)
  love.graphics.draw(image, quad_hand, math.floor(self.armr.x), math.floor(self.armr.y), self.armr.r, 1, 1, 16, 8)
  love.graphics.pop()
  --collision.draw_hitbox(self)
end

function state.rise(self)
  return coroutine.wrap( function()
    local lx, ly = self.arml.x, self.arml.y
    local rx, ry = self.armr.x, self.armr.y

    local timer = 0
    while timer < 2 do
      timer = timer + dt()
      self.arml.x = mathx.smoothApproach(self.arml.x, lx - 32,  dt() * 4)
      self.arml.y = mathx.smoothApproach(self.arml.y, ly - 128, dt() * 4)
      self.armr.x = mathx.smoothApproach(self.armr.x, rx + 32,  dt() * 4)
      self.armr.y = mathx.smoothApproach(self.armr.y, ry - 128, dt() * 4)
      coroutine.yield()
    end

    while self.y > self.pivot_y + 1 do
      self.y = mathx.smoothApproach(self.y, self.pivot_y, dt() * 4)
      coroutine.yield()
    end
    self.y = self.pivot_y

    self.offset = 0
    self.width, self.height = 10, 14
    self.started = true
    self.state = state.idle( self, 3 + love.math.random() * 2 )
  end)
end

function state.idle(self, time)
  return coroutine.wrap(function()
    local mul
    while time > 0 do
      time = time - dt()
      mul = ( (self.health <= 5) and 4 ) or ( (self.health <= 10) and 3 ) or 2
      self.offset = self.offset + dt() * mul
      self.x = self.pivot_x + math.sin(self.offset) * 40
      self.y = mathx.smoothApproach(self.y, self.pivot_y + math.sin(self.offset * 3.5) * 4, dt() * 4)
      self.head.x = math.sin(self.offset * 2.5) * 2
      self.head.y = math.sin(self.offset * 3.5) * 2
      coroutine.yield()
    end
    self.state = state.attack(self)
  end)
end

function state.attack(self)
  return coroutine.wrap(function()
    local time
    while self.y > self.pivot_y - 16 do
      self.y = mathx.approach(self.y, self.pivot_y - 16, dt() * 60)
      self.head.x = mathx.smoothApproach(self.head.x, 0, dt() * 4)
      self.head.y = mathx.smoothApproach(self.head.y, 0, dt() * 4)
      coroutine.yield()
    end

    time = self.health <= 5 and 0.25 or 0.5
    while time > 0 do
      time = time - dt()
      coroutine.yield()
    end

    local spd = self.health <= 5 and 24 or 16
    time = self.health <= 5 and 0.5 or 1
    while time > 0 do
      time = time - dt()
      self.y = mathx.smoothApproach(self.y, self.pivot_y + 48, dt() * spd)
      coroutine.yield()
    end

    time = 0.25
    while time > 0 do
      time = time - dt()
      coroutine.yield()
    end

    while self.y > self.pivot_y + 1 do
      self.y = mathx.smoothApproach(self.y, self.pivot_y, dt() * 8)
      coroutine.yield()
    end
    self.y = self.pivot_y
    time = love.math.random(3, 5)
    if self.health <= 5 then time = time * 0.5 end
    self.state = state.idle( self, time )
  end)
end

function state.death(self)
  self.damage_timer = 1e5
  return coroutine.wrap(function()
    self.arml.vy = -90
    self.armr.vy = -90
    self.head.vy = -120
    self.vy      = -160
    local time = 3
    while time > 0 do
      time = time - dt()
      self.arml.vy = self.arml.vy + 240 * dt()
      self.arml.y = self.arml.y + self.arml.vy * dt()
      self.armr.vy = self.armr.vy + 240 * dt()
      self.armr.y = self.armr.y + self.armr.vy * dt()
      self.head.vy = self.head.vy + 240 * dt()
      self.head.y = self.head.y + self.head.vy * dt()
      self.vy = self.vy + 240 * dt()
      self.y = self.y + self.vy * dt()
      coroutine.yield()
    end
    gameroom:releaseInstance(self)
    gamescreen:fadeout(2)
    gamescene.switch('scenes.ingame', 'stage2')
  end)
end

return megaskeleton
