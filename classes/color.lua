local color = require('classes.class')()
local mathx = require 'libs.mathx'
local rshift, band = bit.rshift, bit.band
local lshift, bor  = bit.lshift, bit.bor
local toBytes      = love.math.colorToBytes
local fromBytes    = love.math.colorFromBytes

function color:initialize(...)
  self:set(...)
end

function color:set(...)
  local i = select('#', ...)
  if i >= 3 then
    self[1], self[2], self[3] = select(1, ...)
    self[4] = select(4, ...) or 1
  elseif i == 1 then
    local t = select(1, ...)
    if type( t ) == 'table' then
      self[1], self[2], self[3], self[4] = t[1], t[2], t[3], t[4] or 1
    else
      self[1], self[2], self[3], self[4] = color.fromInt(...)
    end
  else
    error('Wrong number of arguments')
  end
  return self
end

function color:get()
  return self[1], self[2], self[3], self[4]
end

function color:toInt()
  local r, g, b, a = toBytes(self[1], self[2], self[3], self[4])
  return bor( a, lshift(b, 8), lshift(g, 16), lshift(r, 24) )
end

function color:mix(other, t)
  for i = 1, 4 do self[i] = mathx.lerp(self[i], other[i], t) end
  return self
end

function color:RGBtoYUV()
  local y = self[1] + self[2] * 0        + self[3] * 1.28033
  local u = self[1] + self[2] * -0.21482 + self[3] * -0.38059
  local v = self[1] + self[2] * 2.12798  + self[3] * 0
  self[1], self[2], self[3] = y, u, v
  return self
end

function color:YUVtoRGB()
  local r = self[1] *  0.2126  + self[2] * 0.7152   + self[3] * 0.0722
  local g = self[1] * -0.09991 + self[2] * -0.33609 + self[3] * 0.436
  local b = self[1] * 0.615    + self[2] * -0.55861 + self[3] * -0.05639
  self[1], self[2], self[3] = r, g, b
  return self
end

function color:RGBtoYIQ()
  local y = self[1] * 0.299  + self[2] * 0.587  + self[3] * 0.114
  local i = self[1] * 0.5959 - self[2] * 0.2746 - self[3] * 0.3213
  local q = self[1] * 0.2115 - self[2] * 0.5227 + self[3] * 0.3112
  self[1], self[2], self[3] = y, i, q
  return self
end

function color:YIQtoRGB()
  local r = self[1] + self[2] * 0.956 + self[3] * 0.619
  local g = self[1] - self[2] * 0.272 - self[3] * 0.647
  local b = self[1] - self[2] * 1.106 + self[3] * 1.703
  self[1], self[2], self[3] = r, g, b
  return self
end

function color:YIQShift(val)
  self:RGBtoYIQ()
  local c = math.cos(val * math.pi * 2)
  local s = math.sin(val * math.pi * 2)
  local i = self[2] *  c + self[3] * s
  local q = self[2] * -s + self[3] * c
  self[2], self[3] = i, q
  return self:YIQtoRGB()
end

function color:__add(other)
  if class.type(other) == color then
    for i = 1, 4 do self[i] = self[i] + other[i] end
  else
    for i = 1, 4 do self[i] = self[i] + other end
  end
  return self
end

function color:__sub(other)
  if class.type(other) == color then
    for i = 1, 4 do self[i] = self[i] - other[i] end
  else
    for i = 1, 4 do self[i] = self[i] - other end
  end
  return self
end

function color:__mul(other)
  if class.type(other) == color then
    for i = 1, 4 do self[i] = self[i] * other[i] end
  else
    for i = 1, 4 do self[i] = self[i] * other end
  end
  return self
end

function color:__div(other)
  if class.type(other) == color then
    for i = 1, 4 do self[i] = self[i] / other[i] end
  else
    for i = 1, 4 do self[i] = self[i] / other end
  end
  return self
end

function color:__pow(other)
  if class.type(other) == color then
    for i = 1, 4 do self[i] = self[i] ^ other[i] end
  else
    for i = 1, 4 do self[i] = self[i] ^ other end
  end
  return self
end

function color.fromInt(int)
  return fromBytes(band(rshift(int,24),255),band(rshift(int,16),255),band(rshift(int,8),255),band(int,255))
end

return color
