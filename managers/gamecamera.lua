local gamecamera = require('classes.class')()
local mathx = require 'libs.mathx'

function gamecamera:reset(width, height)
  self.x, self.y = 0, 0
  self.width, self.height = width, height
  self.center_x, self.center_y = 0, 0
  self.offset_x, self.offset_y = 0, 0
  self.window = { width = 0, height = 24 }
  self.pan_speed, self.pan_distance = 60, 0
  self:resetToMapBounds()
  self:_adjust_()
end

function gamecamera:resetToMapBounds()
  self.bounds = { x = 0, y = 0 }
  self.bounds.width, self.bounds.height = require('managers.gameroom'):getPixelDimensions()
end

function gamecamera:setPosition(x, y)
  self.center_x, self.center_y = x, y
  self.offset_x, self.offset_y = 0, 0
  self:_adjust_()
end

function gamecamera:setBounds(x, y, w, h)
  self.bounds.x, self.bounds.y, self.bounds.width, self.bounds.height = x, y, w, h
  self.offset_x, self.offset_y = 0, 0
  self:_adjust_()
end

function gamecamera:setWindow(w, h)
  self.window.width, self.window.height = w, h
  self:_adjust_()
end

function gamecamera:setPanning(speed, distance)
  self.pan_speed, self.pan_distance = speed, distance
end

function gamecamera:follow(dt, x, y, landed)
  local wx, wy = self.window.width, self.window.height
  if x > self.center_x + wx then
    self.center_x = x - wx
    self.offset_x = mathx.approach(self.offset_x, wx + self.pan_distance, dt * self.pan_speed)
  elseif x < self.center_x - wx then
    self.center_x = x + wx
    self.offset_x = mathx.approach(self.offset_x, -(wx + self.pan_distance), dt * self.pan_speed)
  end
  if landed then
    self.center_y = mathx.approach(self.center_y, y, dt * self.pan_speed)
  elseif y > self.center_y + wy then
    self.center_y = y - wy
  elseif y < self.center_y - wy then
    self.center_y = y + wy
  end
  self:_adjust_()
end

function gamecamera:getBoundingBox(centred)
  if centred then
    local w, h = self.width / 2, self.height / 2
    return self.x + w, self.y + h, w, h
  else
    return self.x, self.y, self.width, self.height
  end
end

function gamecamera:getBoundaries()
  return self.x, self.y, self.x + self.width, self.y + self.height
end

function gamecamera:_adjust_()
  local cam_w, cam_h, bnds = self.width, self.height, self.bounds

  local x, w = bnds.x + cam_w / 2, bnds.x + bnds.width  - cam_w / 2
  local y, h = bnds.y + cam_h / 2, bnds.y + bnds.height - cam_h / 2
  self.center_x = mathx.clamp(self.center_x, x, w)
  self.center_y = mathx.clamp(self.center_y, y, h)

  x = self.center_x + self.offset_x - cam_w / 2
  y = self.center_y + self.offset_y - cam_h / 2
  self.x = math.floor( mathx.clamp(x, bnds.x, bnds.x + bnds.width  - cam_w) )
  self.y = math.floor( mathx.clamp(y, bnds.y, bnds.y + bnds.height - cam_h) )
end

return gamecamera
