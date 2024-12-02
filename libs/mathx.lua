local mathx = { }
local min, max, abs, sqrt, log   = math.min, math.max, math.abs, math.sqrt, math.log
local sin, cos, atan2, floor, pi = math.sin, math.cos, math.atan2, math.floor, math.pi

function mathx.clamp(x, a, b)
  return min(max(x, a), b)
end

function mathx.revclamp(x, a, b)
  return (x < (a + b) / 2) and min(x, a) or max(x, b)
end

function mathx.round(value)
  return floor(value + 0.5)
end

function mathx.wrap(x, a, b)
  local i, l = min(a, b), max(a, b)
  return ((x - i) % (l - i + 1)) + i
end

function mathx.sign(x)
  return min(max(x * 1e200 * 1e200, -1), 1)
end

function mathx.between(v, a, b)
  local i, l = min(a, b), max(a, b)
  return v >= min(i, l) and v <= max(i, l)
end

function mathx.lerp(a, b, s)
  return a + (b - a) * s
end

function mathx.herp(a, b, s)
  local t = mathx.clamp( (s - a) / (b - a), 0, 1)
  return t * t * (3 - 2 * t)
end

function mathx.approach(a, b, s)
  return a < b and min(a + s, b) or max(a - s, b)
end

function mathx.angleApproach(a, b, s, ...)
  return mathx.approach(a, a + mathx.angleDifference(a, b), s, ...)
end

function mathx.smoothApproach(a, b, s, ...)
  return mathx.approach(a, b, abs(b - a) * s, ...)
end

function mathx.smoothAngleApproach(a, b, s, ...)
  return mathx.smoothApproach(a, a + mathx.angleDifference(a, b), s, ...)
end

function mathx.angleDifference(a, b)
  return atan2( sin(b - a), cos(b - a) )
end

function mathx.normalize(x, y)
  local m = sqrt(x * x + y * y)
  if m == 0 then return 0, 0 end
  return x/m, y/m
end

function mathx.vector(a)
  return cos(a), sin(a)
end

function mathx.angle(x, y)
  return atan2(y, x) % (pi * 2)
end

function mathx.rotate(x, y, r)
  local c, s = cos(r), sin(r)
  return x * c - y * s, x * s + y * c
end

function mathx.away(x, y, radius, angle)
  return x + radius * cos(angle), y + radius * sin(angle)
end

function mathx.direction(x1, y1, x2, y2)
  return mathx.wrap(atan2(y2 - y1, x2 - x1), -pi, pi)
end

function mathx.distance(x1, y1, x2, y2)
  return sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

function mathx.center(x1, y1, x2, y2)
  return (x1 + x2) / 2, (y1 + y2) / 2
end

function mathx.cross(x1, y1, x2, y2)
  return x1 * y2 - y1 * x2
end

function mathx.variation(x)
  return (love.math.random() * 2 - 1) * x
end

return mathx
