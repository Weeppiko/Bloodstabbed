local collision = { }
local max, abs, pi = math.max, math.abs, math.pi
local function rect_overlap(ax, ay, aw, ah, bx, by, bw, bh)
  return max(abs(ax - bx) - aw - bw, abs(ay - by) - ah - bh) < 0
end

local function rect_resolve(ax, ay, aw, ah, bx, by, bw, bh)
  local cw, ch = aw + bw, ah + bh
  local x_diff, y_diff = ax - bx, ay - by
  if abs(x_diff) - cw > abs(y_diff) - ch then
    return x_diff > 0 and (bx + cw) or (bx - cw), nil
  else
    return nil, y_diff > 0 and (by + ch) or (by - ch)
  end
end

local function horz_overlap(ax, aw, bx, bw)
  return (abs(ax - bx) - aw - bw) < 0
end

local function vert_overlap(ay, ah, by, bh)
  return (abs(ay - by) - ah - bh) < 0
end

function collision.test(a, b)
  return rect_overlap(a.x, a.y, a.width, a.height, b.x, b.y, b.width, b.height)
end

function collision.camera_test(a, b)
  local x, y, w, h = require('managers.gamecamera'):getBoundingBox(true)
  return rect_overlap(a.x, a.y, a.width, a.height, x, y, w + 16 + (b or 0), h + 16 + (b or 0))
end

function collision.test_horizontal(a, b)
  return horz_overlap(a.x, a.width, b.x, b.width)
end

function collision.test_vertical(a, b)
  return vert_overlap(a.y, a.height, b.y, b.height)
end

local function draw_hitbox(x, y, width, height)
  --local dx, dy = math.floor(x), math.floor(y)
  --love.graphics.rectangle('line', dx-width+0.5, dy-height+0.5, width*2-0.5,height*2-0.5)
end

function collision.draw_hitbox(x, ...)
  if select('#', ...) > 0 then
    draw_hitbox(x, ...)
  else
    draw_hitbox(x.x, x.y, x.width, x.height)
  end
end

return collision
