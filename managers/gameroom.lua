-- gameroom:lua
local gameroom = { }
local tiled = require 'classes.tilemap'
local table_new   = require 'table.new'
local table_clear = require 'table.clear'
local class_cache = { }

local function table_shuffle(tbl)
  for i = #tbl, 2, -1 do
    local j = love.math.random(i)
    tbl[i], tbl[j] = tbl[j], tbl[i]
  end
  return tbl
end

local function isfunc(func)
  return type(func) == 'function'
end

local function updatesort(a, b)
  return a.update_priority > b.update_priority
end

local function drawsort(a, b)
  return a.draw_priority < b.draw_priority
end

local function assert_exist(self, instance)
  if self._instances.list[instance] then return true end
  error('<instance>: ' .. tostring(instance) .. ' does not exists!')
end

local function get_layer_id(self, id)
  if type(id) == 'string' then
    return self._tilemap:findLayerID(id)
  else
    return id
  end
end

local function insert_to_group(self, instance)
  local group = getmetatable(instance)._group_
  if not group then return end
  self._groups[group] = self._groups[group] or { }
  self._groups[group][instance] = instance
end

local function remove_from_group(self, instance)
  local group = getmetatable(instance)._group_
  if not (group and self._groups[group]) then return end
  self._groups[group][instance] = nil
end

local function insert_instance(self, instance)
  self._instances[instance] = instance
  insert_to_group(self, instance)
end

local function free_instance(self, instance)
  self._instances[instance] = nil
  remove_from_group(self, instance)
end

local function find_map_file(path)
  for _, file in ipairs(love.filesystem.getDirectoryItems(path)) do
    if love.filesystem.getInfo(path .. '/' .. file, 'file') then
      if file:sub(#file - 3, #file) == '.lua' then
        return path .. '/' .. file
      end
    end
  end
end

function gameroom:clear()
  self._last_id     = 0
  self._tilemap     = nil
  self._objects     = { }
  self._instances   = { }
  self._groups      = { }
  self._insert_queue = table_new(100, 100)
  self._remove_queue = table_new(100, 100)
end

function gameroom:load(map_name, callback, ...)
  self:clear()
  local map_filename = find_map_file('levels/' .. map_name)
  self._tilemap = tiled(map_filename, gamescreen:getDimensions())
  for layer_id in self._tilemap:eachLayer() do
    for object_id, object in self._tilemap:eachObjectInLayer(layer_id) do
      if callback then callback(object, ...) end
    end
  end
  self:flush()
end

function gameroom:update(dt, ...)
  self._tilemap:update(dt)
  local pool = { }
  for instance in pairs(self._instances) do
    instance._active_ = instance:canUpdate()
    if instance._active_ then
      table.insert(pool, instance)
    end
  end
  table.sort(pool, updatesort)
  for _, instance in ipairs(pool) do
    if self._instances[instance] then
      instance:update(dt, ...)
    end
  end
  self:flush()
end

function gameroom:flush()
  for _, instance in ipairs(self._remove_queue) do
    free_instance(self, instance)
  end
  for _, instance in ipairs(self._insert_queue) do
    insert_instance(self, instance)
  end
  table_clear(self._remove_queue)
  table_clear(self._insert_queue)
end

local function draw_instance(instance, ...)
  love.graphics.setColor(1, 1, 1)
  instance:draw(...)
end

local function draw_hash_cells(self)
  love.graphics.push('all')
  love.graphics.setLineWidth(1)
  local view_x = math.floor(gamecamera.x)
  local view_y = math.floor(gamecamera.y)
  love.graphics.translate(-view_x, -view_y)
  local cellsize = self._hash:getCellSize()
  for x, y, count in self._hash:eachCell() do
    local _x = x * cellsize
    local _y = y * cellsize
    love.graphics.setColor(1, 1, 1, 0.1)
    love.graphics.rectangle('fill', _x, _y, cellsize, cellsize)
    love.graphics.setColor(1, 1, 1, 0.2)
    love.graphics.rectangle('line', _x, _y, cellsize, cellsize)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(('%d x %d\n%d'):format(x, y, count), _x, _y)
  end
  love.graphics.pop()
end

function gameroom:draw(...)
  local pool = { }
  for instance in pairs(self._instances) do
    local layer_id = self._tilemap:findLayerID(instance.layer_id)
    if instance:canDraw() and self._tilemap:hasLayer(layer_id) then
      if not pool[layer_id] then pool[layer_id] = { } end
      table.insert(pool[layer_id], instance)
    end
  end
  local view_x, view_y, view_w, view_h = gamecamera:getBoundingBox()
  view_x, view_y = math.floor(view_x), math.floor(view_y)
  local tilx = math.floor(view_x / self._tilemap:getTileWidth())
  local tily = math.floor(view_y / self._tilemap:getTileHeight())
  local cols = math.ceil(view_w / self._tilemap:getTileWidth()) + 1
  local rows = math.ceil(view_h / self._tilemap:getTileHeight()) + 1
  love.graphics.push('all')
  love.graphics.setColor(self._tilemap:getBackgroundColor())
  love.graphics.rectangle('fill', 0, 0, view_w, view_h)
  love.graphics.setColor(1, 1, 1)
  for layer_id in self._tilemap:eachLayer() do
    love.graphics.push('all')
    if pool[layer_id] then table.sort(table_shuffle(pool[layer_id]), drawsort) end
    self._tilemap:setLayerMetaObjects(layer_id, pool[layer_id], draw_instance)
    self._tilemap:drawLayer(layer_id, view_x, view_y, cols, rows, ...)
    self._tilemap:setLayerMetaObjects(layer_id)
    love.graphics.pop()
  end
  --draw_hash_cells(self)
  love.graphics.pop()
end

function gameroom:getLayerID(layer_name)
  return get_layer_id(self, layer_name)
end

-- instance control
function gameroom:addInstance(_type_, layer_id, ...)
  class_cache[_type_] = class_cache[_type_] or require('game.objects.' .. _type_)
  local instance = setmetatable({
    _type_          = _type_,
    layer_id        = get_layer_id(self, layer_id),
    update_priority = 0,
    draw_priority   = 0,
    x = 0, y = 0, width = 0, height = 0,
  }, class_cache[_type_])
  instance:initialize(...)
  table.insert(self._insert_queue, instance)
  return instance
end

function gameroom:destroyInstance(instance, ...)
  --if self._remove_queue[instance]  then return end
  if not self._instances[instance] then return end
  if isfunc(instance.onDestroy) then instance:onDestroy(...) end
  gameroom:releaseInstance(instance, ...)
end

function gameroom:releaseInstance(instance, ...)
  --if self._remove_queue[instance]  then return end
  if not self._instances[instance] then return end
  if isfunc(instance.onRelease) then instance:onRelease(...) end
  --self._remove_queue[instance] = true
  --table.insert(self._remove_queue, instance)
  free_instance(self, instance)
end

function gameroom:hasInstance(instance)
  return not not self._instances[instance]
end

local _empty = { }
function gameroom:eachFromGroup(group)
  local t = self._groups[group] or _empty
  return next, t, nil
end

function gameroom:chooseFromGroup(group, compare)
  local _chosen
  for e in self:eachFromGroup(group) do
    if not _chosen then
      _chosen = e
    else
      if compare(e, _chosen) then
        _chosen = e
      end
    end
  end
  return _chosen
end

function gameroom:eachInstance()
  return next, self._instances, nil
end

-- forward tilemap functions
function gameroom:getProperty(...)
  return self._tilemap:getProperty(...)
end

function gameroom:getLayerObjects(...)
  return self._tilemap:getLayerObjects(...)
end

function gameroom:getLayerCount()
  return self._tilemap:getLayerCount()
end

function gameroom:getWidth()
  return self._tilemap:getWidth()
end

function gameroom:getHeight()
  return self._tilemap:getHeight()
end

function gameroom:getDimensions()
  return self._tilemap:getDimensions()
end

function gameroom:getTileWidth()
  return self._tilemap:getTileWidth()
end

function gameroom:getTileHeight()
  return self._tilemap:getTileHeight()
end

function gameroom:getTileDimensions()
  return self._tilemap:getTileDimensions()
end

function gameroom:getPixelWidth()
  return self._tilemap:getPixelWidth()
end

function gameroom:getPixelHeight()
  return self._tilemap:getPixelHeight()
end

function gameroom:getPixelDimensions()
  return self._tilemap:getPixelDimensions()
end

function gameroom:getProperties()
  return self._tilemap:getProperties()
end

function gameroom:getLayerProperties(...)
  return self._tilemap:getLayerProperties(...)
end

function gameroom:getObjects()
  return self._tilemap:getObjects()
end

function gameroom:getTileID(...)
  return self._tilemap:getTileID(...)
end

function gameroom:setTileID(...)
  return self._tilemap:setTileID(...)
end

function gameroom:getTileObjects(...)
  return self._tilemap:getTileObjects(...)
end

function gameroom:getTileProperty(...)
  return self._tilemap:getTileProperty(...)
end

function gameroom:getTileType(...)
  return self._tilemap:getTileType(...)
end

function gameroom:snapPosition(...)
  return self._tilemap:snapPosition(...)
end

function gameroom:positionToGrid(...)
  return self._tilemap:positionToGrid(...)
end

function gameroom:gridToPosition(...)
  return self._tilemap:gridToPosition(...)
end

function gameroom:getLayer(...)
  return self._tilemap:getLayer(...)
end

function gameroom:getBackgroundColor()
  return self._tilemap:getBackgroundColor()
end

function gameroom:setTilesetImage(...)
  return self._tilemap:setTilesetImage(...)
end

function gameroom:eachLayer(...)
  return self._tilemap:eachLayer(...)
end

function gameroom:eachObjectInLayer(...)
  return self._tilemap:eachObjectInLayer(...)
end

function gameroom:eachTile(...)
  return self._tilemap:eachTile(...)
end

function gameroom:getLayerType(...)
  return self._tilemap:getLayerType(...)
end

function gameroom:hasLayer(...)
  return self._tilemap:hasLayer(...)
end

function gameroom:getTilePixel(...)
  return self._tilemap:getTilePixel(...)
end

function gameroom:setTilePixel(...)
  return self._tilemap:setTilePixel(...)
end

function gameroom:getTileQuad(...)
  return self._tilemap:getTileQuad(...)
end

function gameroom:getTilesetImage()
  return self._tilemap:getTilesetImage()
end

return gameroom
