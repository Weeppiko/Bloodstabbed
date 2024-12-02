-- player.lua
local object = require('game.objects.object')
local player = require('classes.class')(object)
player._group_ = 'player'

local mathx = require 'libs.mathx'
local cache = require 'managers.cache'

local sprite    = require 'game.sprite'
local collision = require 'game.collision'

local image = cache.getImage('assets/sprite/player.png')
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
  death = {
    { 0, 64, 32, 32, 16, 20 },
    { 32, 80, 32, 16, 16, 4 },
  },
}

-- physics constants
local move_speed    = 60
local absmax_xspeed = 120
local absmax_yspeed = 300
local gravity       = 420
local jump_force    = 150

function player:initialize(x, y)
  self.update_priority = 100
  self.x, self.y = x, y
  self.width, self.height = 5, 9
  self.sprite = sprite(image, frame)
  self.sprite:setAnimation('stand')
  self.sprite:setFrameDuration(1/9)

  self.sprite_flip, self.animation_timer = 1, 0
  self.sprite_angle = 0
  self.recover_timer = 0
  self.attack_rect = { x = 0, y = 0, width = 0, height = 0 }
  self:reset()
  self:checkFloorCollision()
  gamestate:setWeapon(function(self)
    gamescreen:flash(1)
    for enemy in gameroom:eachFromGroup('enemy') do
      enemy:damage()
    end
    return 1
  end, 5)
end

function player:reset()
  self.x_speed = 0
  self.y_speed = 0
  self.state = 'landed'
  self.last_x, self.last_y = self.x, self.y
  self.y_land = self.y

  self.jump_buffer = 0
  self.attack_timer = 0
  self.respawn_timer = 0
  self.floor_sensor = 12
  self.wall_sensor = 4
  self.dead = false
end

function player:update(dt)
  self.recover_timer = self.recover_timer - dt
  self.last_x, self.last_y = self.x, self.y

  self:updateInput(dt)
  local g = self.state ~= 'climbing' and gravity or 0
  if math.abs(self.y_speed) < 20 then g = g / 2 end
  self.x_speed = mathx.clamp(self.x_speed,          -absmax_xspeed, absmax_xspeed)
  self.y_speed = mathx.clamp(self.y_speed + g * dt, -absmax_yspeed, absmax_yspeed)
  self:move(self.x_speed * dt, self.y_speed * dt)
  local l, t, r, b = gamecamera:getBoundaries()
  self.x = mathx.clamp(self.x, l + 8, gameroom:getPixelWidth() - 8)
  if self.y >= gameroom:getPixelHeight() then self.y = self.y % gameroom:getPixelHeight() end

  self:checkCollision()
  self:updateAnimation(dt)
  local w = gamecamera.width
  local x = math.max(self.x, gamecamera.x + w / 2)
  gamecamera:follow(dt, x, self.y, self.state == 'landed')
  self:checkEnemies()
  self:checkAttack()
  self:checkItems()
  if self.state ~= 'jumping' and self.state ~= 'falling' then
    self.y_land = self.y
  end
end

function player:updateInput(dt)
  self.jump_buffer  = self.jump_buffer - dt
  self.attack_timer = self.attack_timer - dt
  if self.state == 'landed'  and self.attack_timer > 0 then self.x_speed = 0 end
  if self.state == 'jumping' and self.y_speed >= 0 then self.state = 'falling' end
  if self.dead then return self:updateDeath(dt) end
  if self.state == 'landed'    then return self:updateStateLanded(dt)    end
  if self.state == 'jumping'   then return self:updateStateAirborne(dt)  end
  if self.state == 'falling'   then return self:updateStateAirborne(dt)  end
  if self.state == 'climbing'  then return self:updateStateClimbing(dt)  end
  if self.state == 'crouching' then return self:updateStateCrouching(dt) end
end

function player:updateStateLanded(dt)
  self:updateInputHorzMove(dt)
  self:updateInputJump(dt)
  self:updateInputAttack(dt)
  if self.state == 'landed' then
    self:updateInputClimb(dt)
  end
  if self.state == 'landed' then
    self:updateInputCrouch(dt)
  end
end

function player:updateStateAirborne(dt)
  self:updateInputHorzMove(dt)
  self:updateInputJump(dt)
  self:updateInputAttack(dt)
  self:updateInputClimb(dt)
end

function player:updateStateClimbing(dt)
  self:updateInputVertMove(dt)
end

function player:updateStateCrouching(dt)
  self:updateInputHorzMove(dt)
  self:updateInputVertMove(dt)
  self:updateInputAttack(dt)
end

function player:updateDeath(dt)
  if self.state == 'landed' then
    self.x_speed = 0
    self.respawn_timer = self.respawn_timer - dt
    if self.respawn_timer <= 0 then
      gamestate:addLife(-1)
      if gamestate.lifes > 0 then
        self:reset()
        self.recover_timer = 3
      else
        gamescene.get():gameover()
      end
    end
  end
end

function player:updateInputHorzMove(dt)
  local can_move = self.state == 'landed' and self.attack_timer <= 0
  if gameinput:get(JOY_LEFT) > 0 then
    if can_move then self.x_speed = -move_speed end
    self.sprite_flip = -1
  end
  if gameinput:get(JOY_RIGHT) > 0 then
    if can_move then self.x_speed = move_speed end
    self.sprite_flip = 1
  end
  if self.state == 'landed' and gameinput:get( bit.bor(JOY_RIGHT, JOY_LEFT) ) == 0 then
    self.x_speed = 0
  end
end

function player:updateInputVertMove(dt)
  if self.state == 'climbing' then
    self.y_speed = 0
    self.sprite:pause()
    if gameinput:get(JOY_UP) > 0 then
      self.y_speed = -move_speed
      self.sprite:resume()
    end
    if gameinput:get(JOY_DOWN) > 0 then
      self.y_speed = move_speed
      self.sprite:resume()
      if self:checkFloor() then
        self.state = 'falling'
        self.y_speed = 0
      end
    end
    if not self:checkLadder() then
      self.state = 'landed'
      self.y_speed = gravity
    end
  elseif self.state == 'crouching' then
    if gameinput:get(JOY_DOWN) == 0 then
      self:crouch(false)
    end
  end
end

function player:updateInputJump(dt)
  if gameinput:getOnce(JOY_UP) > 0 then self.jump_buffer = 5 / 60 end
  if self.jump_buffer > 0 and self.state == 'landed' then
    self.jump_buffer = 0
    self.y_speed = -jump_force
    self.state = 'jumping'
  end
end

function player:updateInputAttack(dt)
  if gameinput:get(JOY_B) == 0 then
    self.attack_timer = 0
  end
  if gameinput:getOnce(JOY_B) > 0 then
    self.attack_timer = 1/60 * 10
    self.sprite:resetAnimation()
    gameaudio:playSFX('knife.wav')
    if self.state == 'landed' then self.x_speed = 0 end
  end
  if gameinput:getOnce(JOY_A) > 0 then
    gamestate:useWeapon(self)
  end
end

function player:updateInputCrouch(dt)
  if gameinput:get(JOY_DOWN) == 0 then
    self.can_crouch = true
  end
  if gameinput:get(JOY_DOWN) > 0 and self.can_crouch then
    self:crouch(true)
  end
end

function player:updateInputClimb(dt)
  if gameinput:get(JOY_UP) > 0 and self:checkLadderCenter() then
    self.x_speed, self.y_speed = 0, 0
    self.state = 'climbing'
  end
  if gameinput:get(JOY_DOWN) > 0 and self:checkLadderDown() then
    self.x_speed, self.y_speed = 0, 0
    self.state = 'climbing'
    self.can_crouch = false
  end
end

function player:updateAnimation(dt)
  if self.state == 'climbing' then
    self.sprite:setAnimation('climb')
    self.sprite:setFrameDuration(1/9)
  elseif self.attack_timer > 0 then
    if self.state == 'crouching' then
      self.sprite:setAnimation('crouch_knife', 'once')
    else
      self.sprite:setAnimation('knife', 'once')
    end
    self.sprite:setFrameDuration(1/18)
  elseif self.state == 'crouching' then
    self.sprite:setAnimation('crouch')
    self.sprite:setFrameDuration(1/9)
  elseif self.state == 'landed' then
    if self.dead then
      self.sprite:setAnimation('death', 'once')
      self.sprite:setFrameDuration(1/5)
    else
      if self.x_speed ~= 0 then
        self.sprite:setAnimation('walk')
      else
        self.sprite:setAnimation('stand')
      end
      self.sprite:setFrameDuration(1/9)
    end
  elseif self.state == 'jumping' then
    self.sprite:setAnimation('jump')
    self.sprite:setFrameDuration(1/9)
  elseif self.state == 'falling' then
    self.sprite:setAnimation('fall')
    self.sprite:setFrameDuration(1/9)
  end
  self.sprite:update(dt)
end

function player:draw()
  love.graphics.push('all')
  if self.recover_timer > 0 then
    love.graphics.setBlendMode('add')
    love.graphics.setColor(1, 1, 1, 0.5 )
  end
  local dx, dy = math.floor(self.x), math.floor(self.y)
  self.sprite:draw(dx, dy, self.sprite_angle, self.sprite_flip, 1)
  local x = self.sprite_flip * (self.wall_sensor + 6)
  collision.draw_hitbox(self)
  if self.attack_timer > 0 then
    collision.draw_hitbox(self.attack_rect)
  end
  love.graphics.pop()
end

function player:checkCollision()
  if self.y_speed >= 0 and self.state ~= 'climbing' then
    self:checkFloorCollision()
  end
  --self:checkWallRight()
  --self:checkWallLeft()
end

local function get_floor_type(tx, ty)
  local tile_id = gameroom:getTileID(tx, ty, 'tiles')
  return gameroom:getTileProperty(tile_id, 'type')
end

function player:crouch(f)
  if f then
    self.x_speed = 0
    self.state = 'crouching'
    self.y = self.y + 6
    self.floor_sensor = 6
    self.wall_sensor = 12
    self.width, self.height = 12, 4
  else
    self.state = 'landed'
    self.y = self.y - 6
    self.floor_sensor = 12
    self.wall_sensor = 4
    self.width, self.height = 5, 9
  end
end

function player:checkFloorCollision()
  local y = self:hasFloorCollision()
  if y then
    self.y = y - self.floor_sensor
    if self.state ~= 'crouching' then
      self.state = 'landed'
    end
    self.y_speed = 0
  else
    self.state = 'falling'
  end
end

function player:checkLadderUp()
  local tx, ty = gameroom:positionToGrid(self.x, self.y - self.floor_sensor)
  return get_floor_type(tx, ty) == 'ladder'
end

function player:checkLadderDown()
  local tx, ty = gameroom:positionToGrid(self.x, self.y + self.floor_sensor)
  return get_floor_type(tx, ty) == 'ladder'
end

function player:checkLadderCenter()
  local tx, ty = gameroom:positionToGrid(self.x, self.y)
  return get_floor_type(tx, ty) == 'ladder'
end

function player:checkLadder()
  return self:checkLadderUp() or self:checkLadderDown() or self:checkLadderCenter()
end

function player:checkFloor()
  local tx, ty = gameroom:positionToGrid(self.x, self.y + self.floor_sensor)
  local floor_type = get_floor_type(tx, ty)
  return floor_type ~= 'ladder'
end

function player:checkWallLeft()
  local tx, ty = gameroom:positionToGrid(self.x - self.wall_sensor, self.y)
  local ftype = get_floor_type(tx, ty)
  if ftype == 'solid' then
    if self.x_speed < 0 and self.state == 'landed' then self.x_speed = 0 end
    tx, ty = gameroom:gridToPosition(tx + 1, ty, 'tiles')
    self.x = tx + self.wall_sensor
  end
  tx, ty = gameroom:positionToGrid(self.x - self.wall_sensor, self.y + self.floor_sensor / 2)
  ftype = get_floor_type(tx, ty)
  if ftype == 'solid' then
    if self.x_speed < 0 and self.state == 'landed'  then self.x_speed = 0 end
    tx, ty = gameroom:gridToPosition(tx + 1, ty, 'tiles')
    self.x = tx + self.wall_sensor
  end
  tx, ty = gameroom:positionToGrid(self.x - self.wall_sensor, self.y - self.floor_sensor / 2)
  ftype = get_floor_type(tx, ty)
  if ftype == 'solid' then
    if self.x_speed < 0 and self.state == 'landed'  then self.x_speed = 0 end
    tx, ty = gameroom:gridToPosition(tx + 1, ty, 'tiles')
    self.x = tx + self.wall_sensor
  end
end

function player:checkWallRight()
  local tx, ty = gameroom:positionToGrid(self.x + self.wall_sensor, self.y)
  local ftype = get_floor_type(tx, ty)
  if ftype == 'solid' then
    if self.x_speed > 0 and self.state == 'landed'  then self.x_speed = 0 end
    tx, ty = gameroom:gridToPosition(tx, ty, 'tiles')
    self.x = tx - self.wall_sensor - 1e-20
  end
  tx, ty = gameroom:positionToGrid(self.x + self.wall_sensor, self.y + self.floor_sensor / 2)
  ftype = get_floor_type(tx, ty)
  if ftype == 'solid' then
    if self.x_speed > 0 and self.state == 'landed'  then self.x_speed = 0 end
    tx, ty = gameroom:gridToPosition(tx, ty, 'tiles')
    self.x = tx - self.wall_sensor - 1e-20
  end
  tx, ty = gameroom:positionToGrid(self.x + self.wall_sensor, self.y - self.floor_sensor / 2)
  ftype = get_floor_type(tx, ty)
  if ftype == 'solid' then
    if self.x_speed > 0 and self.state == 'landed'  then self.x_speed = 0 end
    tx, ty = gameroom:gridToPosition(tx, ty, 'tiles')
    self.x = tx - self.wall_sensor - 1e-20
  end
end

function player:checkAttack()
  if self.attack_timer <= 0 then return end
  local rect
  if self.state == 'crouching' then
    local x = self.sprite_flip * 22
    self.attack_rect = { x = self.x + x, y = self.y + 2, width = 8, height = 5 }
  else
    local x = self.sprite_flip * 12
    self.attack_rect = { x = self.x + x, y = self.y, width = 6, height = 7 }
  end
  for other in gameroom:eachFromGroup('enemy') do
    if collision.test(self.attack_rect, other) then other:damage(true) end
  end
end

function player:kill()
  if self.dead then return end
  if self.recover_timer > 0 then return end
  gameaudio:playSFX('hit.wav')
  gameaudio:playME('death.wav', 0.75)
  self.dead = true
  self.y_speed = -jump_force/2
  self.attack_timer = 0
  if self.state == 'crouching' then
    self:crouch(false)
  end
  self.state = 'jumping'
  self.respawn_timer = 2
  if gamestate.lifes <= 1 then
    gameaudio:stopBGM()
  end
end

function player:checkEnemies()
  if self.dead then return end
  for other in gameroom:eachFromGroup('enemy') do
    if collision.test(self, other) and other.state ~= 'dead' and not other.no_damage then
      if self.recover_timer > 0 then
        other:damage()
      else
        self:kill()
      end
    end
  end
end

function player:checkItems()
  if self.dead then return end
  for other in gameroom:eachFromGroup('item') do
    if collision.test(self, other) then
      other:pick()
    end
  end
end


return player
