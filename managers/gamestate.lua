local gamestate = { }

local hud_image = love.graphics.newImage('assets/sprite/hud.png')
local hud_quad = love.graphics.newQuad(0, 0, 8, 8, hud_image)

function gamestate:reset()
  self.score = 0
  self.lifes = 10
  self.timer = 0
  self.power = 0
  self.weapon = nil
  self.iconwp = 0
  self.delay = 0
end

function gamestate:addScore(value)
  self.score = self.score + value
end

function gamestate:addLife(value)
  self.lifes = self.lifes + value
end

function gamestate:setTimer(value)
  self.timer = value
end

function gamestate:setWeapon(weapon, icon)
  self.power = 4
  self.weapon = weapon
  self.iconwp = icon or 0
end

function gamestate:chargeWeapon(val)
  self.power = mathx.clamp(self.power + val, 0, 4)
end

function gamestate:useWeapon(...)
  if self.power <= 0 or self.delay > 0 then return end
  if self.weapon then
    local delay = self.weapon(...)
    if delay then
      gameaudio:playSFX('power.wav')
      self.power = self.power - 1
      self.delay = delay
    end
  end
end

function gamestate:update(dt)
  self.timer = self.timer + dt
  self.delay = self.delay - dt
end

function gamestate:getTimerf()
  local t = math.ceil(self.timer)
  local s, m = t % 60, math.floor(t / 60)
  return ('%02d:%02d'):format(m, s)
end

local function bprint(text, x, y, ...)
  local r, g, b, a = love.graphics.getColor()
  love.graphics.setColor( COLOR_A )
  love.graphics.print(text, x + 1, y, ...)
  love.graphics.print(text, x + 1, y + 1, ...)
  love.graphics.print(text, x,     y + 1, ...)

  love.graphics.print(text, x - 1, y, ...)
  love.graphics.print(text, x - 1, y - 1, ...)
  love.graphics.print(text, x,     y - 1, ...)

  love.graphics.print(text, x - 1, y + 1, ...)
  love.graphics.print(text, x + 1, y - 1, ...)

  love.graphics.print(text, x + 1, y + 2, ...)
  love.graphics.print(text, x,     y + 2, ...)
  love.graphics.print(text, x - 1, y + 2, ...)

  love.graphics.setColor(r, g, b, a)
  love.graphics.print(text, x,     y, ...)
end

local function bprintf(text, x, y, ...)
  local r, g, b, a = love.graphics.getColor()
  love.graphics.setColor( COLOR_A )
  love.graphics.printf(text, x + 1, y, ...)
  love.graphics.printf(text, x + 1, y + 1, ...)
  love.graphics.printf(text, x,     y + 1, ...)

  love.graphics.printf(text, x - 1, y, ...)
  love.graphics.printf(text, x - 1, y - 1, ...)
  love.graphics.printf(text, x,     y - 1, ...)

  love.graphics.printf(text, x - 1, y + 1, ...)
  love.graphics.printf(text, x + 1, y - 1, ...)

  love.graphics.printf(text, x + 1, y + 2, ...)
  love.graphics.printf(text, x,     y + 2, ...)
  love.graphics.printf(text, x - 1, y + 2, ...)

  love.graphics.setColor(r, g, b, a)
  love.graphics.printf(text, x,     y, ...)
end

function gamestate:draw()
  love.graphics.push('all')
  love.graphics.setFont( require('fonts').small )
  love.graphics.setColor( COLOR_B )
  love.graphics.rectangle('fill', 0, 0, gamescreen:getWidth(), 16)
  love.graphics.setColor( COLOR_D )
  hud_quad:setViewport(0, 0, 8, 8)
  for i = 0, self.lifes - 1 do
    local x = i % 5
    local y = math.floor(i / 5)
    love.graphics.draw(hud_image, hud_quad, 1 + x * 8, 1 + y * 6)
  end

  hud_quad:setViewport(32, 0, 8, 8)
  love.graphics.draw(hud_image, hud_quad, 119, 3)
  bprint( self:getTimerf() , 129, 4)

  bprint('POWER', 49, 2)
  hud_quad:setViewport(self.iconwp * 8, 0, 8, 8)
  for i = 0, self.power - 1 do
    love.graphics.draw(hud_image, hud_quad, 49 + i * 7, 7)
  end

  bprint('SCORE', 82, 2)
  bprint( ('%05d'):format(self.score), 82, 8 )

  love.graphics.pop()
end


return gamestate
