local gamescreen = { }

local function centralize(canvas, target)
  local ww, wh = love.graphics.getDimensions()
  if target then
    ww, wh = target:getDimensions()
  end
  local sw, sh = canvas:getDimensions()
  local mt = math.min(ww/sw, wh/sh)
  return ww/2, wh/2, 0, mt, mt, sw/2, sh/2
end

function gamescreen:initialize(width, height)
  self:setup(width, height)
end

function gamescreen:setup(width, height, filter)
  self.screen  = love.graphics.newCanvas(width, height)
  self.stencil = love.graphics.newCanvas(width, height, { format = 'stencil8' })
  self.canvas  = love.graphics.newCanvas(width, height)
  self.pre_shader  = love.graphics.newShader('shaders/palette.glsl')
  self.post_shader = love.graphics.newShader('shaders/pixelscale.glsl')
  self.palette_set = love.graphics.newImage('assets/system/palette_set.png')
  self.palette_index = 0
  self.brightness  = 1
  self.fade_proc   = { from = 1, to = 1, time = 0, count = 0 }
  self.flashing_time  = 0
end

function gamescreen:update(dt)
  local f = self.fade_proc
  f.count = f.count + dt
  self.brightness = mathx.lerp(f.from, f.to, f.count / f.time)
  local a, b = math.min(f.from, f.to), math.max(f.from, f.to)
  self.brightness = mathx.clamp(self.brightness, a, b)
  self.flashing_time = math.max(self.flashing_time - dt, 0)
end

function gamescreen:getDimensions()
  return self.canvas:getDimensions()
end

function gamescreen:getWidth()
  return self.canvas:getWidth()
end

function gamescreen:getHeight()
  return self.canvas:getHeight()
end

function gamescreen:setPalette(index)
  self.palette_index = (math.floor(index) + 0.5) / self.palette_set:getHeight()
end

function gamescreen:fadeout(time)
  self.brightness = 1
  self.fade_proc = { from = 1, to = 0, time = time, count = 0 }
end

function gamescreen:fadein(time)
  self.brightness = 0
  self.fade_proc = { from = 0, to = 1, time = time, count = 0 }
end

function gamescreen:isFading()
  return self.brightness ~= self.fade_proc.to
end

function gamescreen:flash(time)
  self.flashing_time = time
end

function gamescreen:isFlashing()
  return self.flashing.time > 0
end

function gamescreen:render(func, ...)
  love.graphics.push('all')
  love.graphics.setCanvas({ self.screen, depth = self.depth, stencil = self.stencil })
    love.graphics.push('all')
    func(...)
    love.graphics.pop()
  if self.flashing_time > 0 then
    love.graphics.setColor(0, 0, 0, math.floor( (self.flashing_time * 60 + 1) % 2) )
    love.graphics.rectangle( 'fill', 0, 0, self.screen:getDimensions() )
  end
  love.graphics.pop()
end

function gamescreen:draw()
  love.graphics.push('all')
  love.graphics.setCanvas(self.canvas)
  love.graphics.setBlendMode('replace')
  love.graphics.setShader(self.pre_shader)
  self.pre_shader:send('palette', self.palette_set)
  self.pre_shader:send('offset', self.palette_index)
  love.graphics.setColor(self.brightness, self.brightness, self.brightness)
  love.graphics.draw(self.screen)
  love.graphics.pop()

  love.graphics.push('all')
  local x, y, r, sx, sy, ox, oy = centralize(self.canvas)
  if self.enable_filter then
    love.graphics.setShader(self.post_shader)
    self.post_shader:send('sharpness', math.floor(sx))
    self.post_shader:send('resolution', { self.canvas:getDimensions() })
    self.canvas:setFilter('linear')
  else
    self.canvas:setFilter('nearest')
  end
  love.graphics.draw(self.canvas, x, y, r, math.floor(sx), math.floor(sy), ox, oy)
  love.graphics.pop()
end

function gamescreen:fromDisplay(x, y)
  local w, h = love.graphics.getDimensions()
  local _, _, _, sx, sy, ox, oy = centralize(self.canvas)
  x = (x - w / 2) / sx + ox
  y = (y - h / 2) / sy + oy
  return x, y
end

return gamescreen
