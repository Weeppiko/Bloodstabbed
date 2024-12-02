-- gameover.lua
local gameover = { }

function gameover:enter()
  gamescreen:setPalette(4)
  gamescreen:fadein(1)
  gameaudio:stop()
  gameaudio:playME('gameover.ogg', 0.75)
end

function gameover:update(dt)
  if not gameaudio:isPlayingME() then
    gamescreen:fadeout(1)
    gamescene.set('scenes.inboot')
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

function gameover:draw()
  love.graphics.push('all')
  love.graphics.setFont( require('fonts').normal )
  bprintf('GAME OVER', 0, 64, 160, 'center')
  love.graphics.pop()
end

return gameover
