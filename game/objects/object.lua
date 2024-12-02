-- object.lua
local object = require('classes.class')()

function object:initialize(x, y, w, h)
  self.x, self.y = x, y
  self.width, self.height = w, h
end

function object:move(dx, dy)
  self.x = self.x + dx
  self.y = self.y + dy
end

function object:setPosition(x, y)
  self.x, self.y = x, y
end

function object:getType()
  return self._type_ or ''
end

function object:isTypeOf(otype)
  return self._types_[otype]
end

function object:isActive()
  return self._active_ and self:exist()
end

function object:canUpdate()
  return not not self.update
end

function object:canDraw()
  return not not self.draw
end

function object:exist()
  return gameroom:hasInstance(self)
end

local function get_floor_type(tx, ty)
  local tile_id = gameroom:getTileID(tx, ty, 'tiles')
  return gameroom:getTileProperty(tile_id, 'type')
end

function object:hasFloorCollision()
  local tx, ty = gameroom:positionToGrid(self.x, self.y + self.floor_sensor)
  local floor_type = get_floor_type(tx, ty)
  if floor_type then
    if floor_type == 'ladder' and get_floor_type(tx, ty - 1) ~= 'ladder' then
      tx, ty = gameroom:gridToPosition(tx, ty, 'tiles')
      return ty - 1e-20
    elseif floor_type ~= 'ladder' and get_floor_type(tx, ty - 1) ~= 'solid' then
      tx, ty = gameroom:gridToPosition(tx, ty, 'tiles')
      return ty - 1e-20
    end
  end
end


return object
