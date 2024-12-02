local chain = require('classes.class')()
local mathx = require 'libs.mathx'

function chain:initialize(segcount, image, quad)
  self.segcount = segcount
  self.image = image
  self.quad = quad
  self.positions = { { x = 0, y = 0 }, { x = 0, y = 0 } }
end

function chain:setPositions(x1, y1, x2, y2)
  self.positions[1].x = x1
  self.positions[1].y = y1
  self.positions[2].x = x2
  self.positions[2].y = y2
end

function chain:draw()
  for i = 0, self.segcount - 1 do
    local t = i / (self.segcount - 1)
    local x = mathx.lerp( self.positions[1].x, self.positions[2].x, t )
    local y = mathx.lerp( self.positions[1].y, self.positions[2].y, t )
    local _, _, w, h = self.quad:getViewport()
    love.graphics.draw(self.image, self.quad, math.floor(x), math.floor(y), 0, 1, 1, w / 2, h / 2)
  end
end

return chain
