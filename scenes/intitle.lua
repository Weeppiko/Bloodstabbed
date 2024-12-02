-- intitle.lua
local intitle = { }
local shader  = love.graphics.newShader('shaders/wave.glsl')

function intitle:enter()
  gamescreen:setPalette(2)
  gamescreen:fadein(0.5)
  self.cycle = 0
end

function intitle:update(dt)
  self.cycle = self.cycle + dt
  if gameinput:get(JOY_START) > 0 then
    gameaudio:playSFX('power.wav')
    gamescreen:fadeout(2)
    gamestate:reset()
    if gameinput:get( bit.bor(JOY_A, JOY_B) ) > 0 then
      gamescene.set('scenes.ingame', 'stage2')
    else
      gamescene.set('scenes.ingame', 'stage1')
    end
  end
end

local function bprintf(text, x, y, ...)
  local r, g, b, a = love.graphics.getColor()
  love.graphics.setColor( COLOR_C )
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

function intitle:draw()
  love.graphics.push('all')
  shader:send('wave_precision', 4)
  shader:send('wave_division', 144/8)
  shader:send('wave_phase', self.cycle)
  shader:send('wave_strength', 0.02)
  shader:send('wave_length', 0.2)
  love.graphics.draw( require('managers.cache').getImage('assets/sprite/title_screen1.png') )
  love.graphics.setShader(shader)
  love.graphics.draw( require('managers.cache').getImage('assets/sprite/title_screen2.png') )
  love.graphics.setShader()
  love.graphics.draw( require('managers.cache').getImage('assets/sprite/title_screen3.png') )
  --bprintf('PRESS START', 64, 72 + math.sin(self.cycle * 4) * 2, 96, 'center')
  bprintf('PRESS START', 0, 100 + math.sin(self.cycle * 4) * 2, 160, 'center')
  love.graphics.setFont( require('fonts').small )
  bprintf('Weeppiko Dekaeru Laggy Machaach', 0, 118, 160, 'center')

  love.graphics.pop()
end

return intitle
