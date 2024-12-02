-- ending.lua
local ending = { }

function ending:enter()
  gamescreen:setPalette(4)
  gamescreen:fadein(2)
end

function ending:update(dt)
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

function ending:draw()
  love.graphics.push('all')
  love.graphics.draw( require('managers.cache').getImage('assets/sprite/end_screen.png') )
  love.graphics.setFont( require('fonts').normal )
  bprintf('THE END', 0, 64, 160, 'center')
  love.graphics.pop()
end

return ending
