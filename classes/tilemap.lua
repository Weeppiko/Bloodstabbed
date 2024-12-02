local tilemap = require('classes.class')()
local band, bor, bnot = bit.band, bit.bor, bit.bnot
local _defs = love.filesystem.read('levels/propertytypes.json')
local _definitions = _defs and require('libs.json').decode(_defs) or { }

local FLIPPED_HORIZONTALLY_FLAG  = 0x80000000
local FLIPPED_VERTICALLY_FLAG    = 0x40000000
local FLIPPED_DIAGONALLY_FLAG    = 0x20000000
local ROTATED_HEXAGONAL_120_FLAG = 0x10000000
local FILTER_FLAG                = 0x0fffffff

local function make_bbox(object)
  if object.shape == 'polyline' or object.shape == 'polygon' then
    local points = object.polygon or object.polyline
    local x1, y1 = math.huge, math.huge
    local x2, y2 = -x1, -y1
    for i, point in ipairs(points) do
      point.x = point.x + object.x
      point.y = point.y + object.y
      x1 = math.min(x1, point.x)
      y1 = math.min(y1, point.y)
      x2 = math.max(x2, point.x)
      y2 = math.max(y2, point.y)
    end
    for i, point in ipairs(points) do
      point.x = point.x - x1
      point.y = point.y - y1
    end
    object.x = x1
    object.y = y1
    object.width = x2 - x1
    object.height = y2 - y1
  end
end

local function color_from_bytes(color)
  local r, g, b, a = love.math.colorFromBytes(unpack(color))
  return { r, g, b, a or 1 }
end

local function get_layer_color(layer)
  local r1, g1, b1, a1 = 1, 1, 1, 1
  if layer.parent then r1, g1, b1, a1 = get_layer_color(layer.parent) end
  local r2, g2, b2, a2 = unpack(layer.tintcolor)
  return r1 * r2, g1 * g2, b1 * b2, a1 * a2
end

local function tint_color(layer)
  local r1, g1, b1, a1 = love.graphics.getColor()
  local r2, g2, b2, a2 = get_layer_color(layer)
  return r1 * r2, g1 * g2, b1 * b2, a1 * a2 * layer.opacity
end

local function is_layer_visible(layer)
  return layer.visible and ( (not layer.parent) or is_layer_visible(layer.parent) )
end

local function get_layer_offset(layer)
  local ox, oy = 0, 0
  if layer.parent then ox, oy = get_layer_offset(layer.parent) end
  return layer.offsetx + ox, layer.offsety + oy
end

local function get_layer_parallax(layer)
  local px, py = 1, 1
  if layer.parent then px, py = get_layer_parallax(layer.parent) end
  return layer.parallaxx * px, layer.parallaxy * py
end

local function get_tile_quad_image(tilesets, tile_id)
  for i = #tilesets, 1, -1 do
    local tileset = tilesets[i]
    local fgid = tileset.firstgid or 1
    if tile_id >= fgid then
      return tileset.image, tileset.quads[tile_id - fgid + 1]
    end
  end
end

local function process_layer_metaobjects(layer, ...)
  if layer._metaobjects and layer._metacallback then
    for _, object in ipairs(layer._metaobjects) do
      layer._metacallback(object, ...)
    end
  end
end

local function parse_tile_id(tile_id)
  local flip_horz = band(tile_id, FLIPPED_HORIZONTALLY_FLAG) ~= 0
  local flip_vert = band(tile_id, FLIPPED_VERTICALLY_FLAG) ~= 0
  local flip_diag = band(tile_id, FLIPPED_DIAGONALLY_FLAG) ~= 0
  local rt_hex120 = band(tile_id, ROTATED_HEXAGONAL_120_FLAG) ~= 0
  local tile_id = band(tile_id, FILTER_FLAG)
  return tile_id, flip_horz, flip_vert, flip_diag, rt_hex120
end

local function draw_quad(image, quad, x, y, flip_x, flip_y, flip_d)
  local _, _, tw, th = quad:getViewport()
  x, y = x + tw / 2, y + th / 2
  local ox, oy = tw / 2, th / 2
  local sx, sy = 1, 1
  local r = flip_d and math.rad(90) or 0
  if flip_d then
    if not flip_x then sy = -1 end
    if flip_y then sx = -1 end
  else
    if flip_x then sx = -1 end
    if flip_y then sy = -1 end
  end
  love.graphics.draw(image, quad, x, y, r, sx, sy, ox, oy)
end

local function draw_rect(mode, x, y, w, h, flip_x, flip_y, flip_d, rx, ry, tw, th)
  x, y = x + w / 2, y + h / 2
  if flip_d then
    x, y, w, h = y, x, h, w
    if flip_x then x = -x + tw end
    if flip_y then y = -y + th end
  else
    if flip_x then x = -x + tw end
    if flip_y then y = -y + th end
  end
  x, y = x - w / 2, y - h / 2
  love.graphics.rectangle(mode, rx + x, ry + y, w, h)
end

function tilemap:initialize(...)
  self:load(...)
end

function tilemap:load(filename)
  local data = love.filesystem.load(filename)()
  self._objects = { }
  self._properties = data.properties or { }
  self._width = data.width
  self._height = data.height
  self._tilewidth = data.tilewidth
  self._tileheight = data.tileheight
  self._backgroundcolor = color_from_bytes(data.backgroundcolor or { 0, 0, 0, 0 })
  self._layers = { }
  self._layerlist = { }
  self._metaobjects = { }
  self:_loadLayers(data.layers)
  self:_loadTilesets(data.tilesets)
end

function tilemap:_loadLayers(layers)
  for _, layer in ipairs(layers) do
    self._layers[layer.id]   = layer
    self._layers[layer.name] = layer
    if layer.type == 'group' then
      error('layer groups are not supported!')
    elseif layer.type == 'tilelayer' then
      if layer.encoding == 'xml' then
        error('xml encoding is not supported!')
      elseif layer.encoding == 'base64' then
        local newdata = love.data.decode('string', 'base64', layer.data)
        if layer.compression == 'zstd' then
          error('zstd compression is not supported!')
        elseif layer.compression then
          newdata = love.data.decompress('string', layer.compression, newdata)
        end
        layer.data = { }
        for i = 1, #newdata, 4 do
          local id = love.data.unpack('I4', newdata, i)
          table.insert(layer.data, id)
        end
      end
    elseif layer.type == 'objectgroup' then
      for _, object in ipairs(layer.objects) do
        object.layerid = layer.id
        make_bbox(object)
        table.insert(self._objects, object)
      end
    elseif layer.type == 'imagelayer' then
      local layer_image = layer.image:gsub('%..[\\/]', '')
      layer.image = love.graphics.newImage(layer_image)
      local w, h = layer.image:getDimensions()
      layer.quad = love.graphics.newQuad(0, 0, w, h, w, h)
      layer.image:setWrap('repeat')
    end
    for _, property in pairs(layer.properties) do
      if type(property) == 'table' and _definitions[property] then
        setmetatable(property, { __index = _definitions[property] })
      end
    end
    table.insert(self._layerlist, layer)
  end
end

function tilemap:_loadTilesets(tilesets)
  self._tiles = { }
  self._tilesets = { }
  self._tileanim = { }
  for _, tileset in ipairs(tilesets) do
    local fgid = tileset.firstgid or 1
    for _, tile in ipairs(tileset.tiles) do
      if tile.animation then
        tile.animation.frame = 0
        tile.animation.timer = tile.animation[1].duration
        table.insert(self._tileanim, tile)
      end
      self._tiles[tile.id + fgid] = tile
    end
    tileset.quads = { }
    local tileset_file = tileset.image:gsub('%..[\\/]', '')
    tileset.image = love.graphics.newImage(tileset_file)
    for y = 0, (tileset.imageheight / tileset.tileheight) - 1 do
      for x = 0, (tileset.imagewidth / tileset.tilewidth) - 1 do
        table.insert(tileset.quads, love.graphics.newQuad(
          x * tileset.tilewidth, y * tileset.tileheight,
          tileset.tilewidth, tileset.tileheight,
          tileset.imagewidth, tileset.imageheight
        ))
      end
    end
    table.insert(self._tilesets, tileset)
  end
end

function tilemap:update(dt)
  for _, tile in ipairs(self._tileanim) do
    local anim = tile.animation
    anim.timer = anim.timer - (dt * 1000)
    if anim.timer <= 0 then
      anim.frame = (anim.frame + 1) % #tile.animation
      anim.timer = anim.timer + anim[anim.frame + 1].duration
    end
  end
end

function tilemap:_drawTileLayer(layer, real_x, real_y, cols, rows, ...)
  local offsetx, offsety = get_layer_offset(layer)
  local parallaxx, parallaxy = get_layer_parallax(layer)
  local scr_x = math.floor(real_x * parallaxx - offsetx)
  local scr_y = math.floor(real_y * parallaxy - offsety)
  love.graphics.push('all')
  love.graphics.origin()
  love.graphics.setColor(1, 1, 1, layer.opacity)
  love.graphics.translate(-scr_x, -scr_y)
  local ix = math.floor( scr_x / self._tilewidth )
  local iy = math.floor( scr_y / self._tileheight )
  for y = 0, rows - 1 do
    for x = 0, cols - 1 do
      local t_x, t_y = ix + x, iy + y
      local index = ( t_x % layer.width ) + ( t_y % layer.height ) * layer.width + 1
      local tileid, fliph, flipv, flipd = parse_tile_id(layer.data[index])
      if tileid > 0 then
        if self._tiles[tileid] and self._tiles[tileid].animation then
          local tile = self._tiles[tileid]
          local index = tile.animation.frame % #tile.animation
          tileid = tile.animation[index + 1].tileid + 1
        end
        local image, quad = get_tile_quad_image(self._tilesets, tileid)
        local px = (ix + x) * self._tilewidth
        local py = (iy + y) * self._tileheight
        draw_quad(image, quad, px, py, fliph, flipv, flipd)
      end
    end
  end
  process_layer_metaobjects(layer, layer.id, real_x, real_y, cols, rows, ...)
  love.graphics.pop()
end

function tilemap:_drawImageLayer(layer, real_x, real_y, cols, rows, ...)
  local offsetx, offsety = get_layer_offset(layer)
  local parallaxx, parallaxy = get_layer_parallax(layer)
  local scr_x = math.floor(real_x * parallaxx - offsetx)
  local scr_y = math.floor(real_y * parallaxy - offsety)
  love.graphics.push('all')
  love.graphics.origin()
  love.graphics.translate(-scr_x, -scr_y)
  local _lwx, _lwy = layer.image:getWrap()
  local wx = layer.repeatx and 'repeat' or 'clampzero'
  local wy = layer.repeaty and 'repeat' or 'clampzero'
  layer.image:setWrap(wx, wy)
  local sw, sh = cols * self._tilewidth, rows * self._tileheight
  local iw, ih = layer.image:getDimensions()
  layer.quad:setViewport(scr_x, scr_y, sw, sh, iw, ih)
  love.graphics.draw(layer.image, layer.quad, scr_x, scr_y)
  layer.image:setWrap(_lwx, _lwy)
  process_layer_metaobjects(layer, layer.id, real_x, real_y, ...)
  love.graphics.pop()
end

function tilemap:_drawObjectLayer(layer, real_x, real_y, ...)
  local offsetx, offsety = get_layer_offset(layer)
  local parallaxx, parallaxy = get_layer_parallax(layer)
  local px = math.floor(-real_x * parallaxx - offsetx)
  local py = math.floor(-real_y * parallaxy - offsety)
  love.graphics.push('all')
  love.graphics.origin()
  love.graphics.translate(px, py)
  process_layer_metaobjects(layer, layer.id, real_x, real_y, ...)
  love.graphics.pop()
end

function tilemap:drawLayer(layer_id, ...)
  local layer = self._layers[layer_id]
  if not ( layer and is_layer_visible(layer) ) then return end
  if layer.type == 'tilelayer'  then
    self:_drawTileLayer(layer, ...)
  elseif layer.type == 'imagelayer' then
    self:_drawImageLayer(layer, ...)
  elseif layer.type == 'objectgroup' then
    self:_drawObjectLayer(layer, ...)
  end
end



function tilemap:getWidth()
  return self._width
end

function tilemap:getHeight()
  return self._height
end

function tilemap:getDimensions()
  return self._width, self._height
end

function tilemap:getTileWidth()
  return self._tilewidth
end

function tilemap:getTileHeight()
  return self._tileheight
end

function tilemap:getTileDimensions()
  return self._tilewidth, self._tileheight
end

function tilemap:getPixelWidth()
  return self._width * self._tilewidth
end

function tilemap:getPixelHeight()
  return self._height * self._tileheight
end

function tilemap:getPixelDimensions()
  return self:getPixelWidth(), self:getPixelHeight()
end

function tilemap:snapPosition(x, y)
  local x = math.floor(x / self._tilewidth) * self._tilewidth
  local y = math.floor(y / self._tileheight) * self._tileheight
  return x, y
end

function tilemap:positionToGrid(x, y, layer_id)
  if layer_id then
    local layer = self._layers[layer_id]
    x = math.floor((x + layer.offsetx) / self._tilewidth)
    y = math.floor((y + layer.offsety) / self._tilewidth)
  else
    x = math.floor(x / self._tilewidth)
    y = math.floor(y / self._tileheight)
  end
  return x, y
end

function tilemap:gridToPosition(x, y, layer_id)
  if layer_id then
    local layer = self._layers[layer_id]
    x = math.floor(x * self._tilewidth) + layer.offsetx
    y = math.floor(y * self._tilewidth) + layer.offsety
  else
    x = math.floor(x * self._tilewidth)
    y = math.floor(y * self._tileheight)
  end
  return x, y
end

function tilemap:getProperty(property)
  return self._properties[property]
end

function tilemap:getBackgroundColor()
  return unpack(self._backgroundcolor)
end



function tilemap:getLayerCount()
  return #self._layerlist
end

function tilemap:findLayerID(layer_name)
  if not self._layers[layer_name] then return -1 end
  return self._layers[layer_name].id
end

function tilemap:hasLayer(layer_name)
  return not not self._layers[layer_name]
end

function tilemap:hasParentLayer(layer_id)
  return not not self._layers[layer_id].parent
end

function tilemap:getParentLayerID(layer_id)
  local parent = self._layers[layer_id].parent
  if not parent then return -1 end
  return parent.id
end

function tilemap:getLayerType(layer_id)
  return self._layers[layer_id].type
end

function tilemap:getLayerVisible(layer_id)
  return self._layers[layer_id].visible
end

function tilemap:setLayerVisible(layer_id, visible)
  self._layers[layer_id].visible = not not visible
end

function tilemap:getLayerProperty(layer_id, property)
  local layer = self._layers[layer_id]
  return layer.properties and layer.properties[property]
end

function tilemap:setLayerProperty(layer_id, property, value)
  local layer = self._layers[layer_id]
  if not layer.properties then layer.properties = { } end
  layer.properties[property] = value
end

function tilemap:setLayerMetaObjects(layer_id, metaobjs, callback)
  local layer = self._layers[layer_id]
  layer._metaobjects  = metaobjs
  layer._metacallback = callback
end

function tilemap:getLayerMetaObjects(layer_id)
  local layer = self._layers[layer_id]
  return layer._metaobjects, layer._metacallbak
end

function tilemap:eachLayer()
  local i = 0
  local n = #self._layerlist
  return function()
    i = i + 1
    if i <= n then
      return self._layerlist[i].id
    end
  end
end

function tilemap:eachObject()
  local i, o = 0
  local n = #self._objects
  return function()
    i = i + 1
    o = self._objects[i]
    if nil ~= o then
      return o
    end
  end
end


function tilemap:eachObjectInLayer(layerid)
  local layer = self._layers[layerid]
  local i = 0
  local n = #(layer.objects or { })
  return function()
    i = i + 1
    if i <= n then
      return i, layer.objects[i]
    end
  end
end

function tilemap:eachTile()
  local i = 0
  local n = #self._tilequads
  return function()
    i = i + 1
    if i <= n then
      return i - 1
    end
  end
end



function tilemap:getRealTileID(x, y, layerid)
  local layer = self._layers[layerid]
  if not layer then error('Undefined Layer') end
  if x < 0 or x >= layer.width or y < 0 or y >= layer.height then return end
  local index = x + y * layer.width + 1
  return layer.data[index]
end

function tilemap:setRealTileID(x, y, layerid, tileid)
  local layer = self._layers[layerid]
  if not layer then error('Undefined Layer') end
  if x < 0 or x >= layer.width or y < 0 or y >= layer.height then return end
  local index = x + y * layer.width + 1
  layer.data[index] = tonumber(tileid)
end

function tilemap:getTileID(x, y, layerid)
  local tileid = self:getRealTileID(x, y, layerid)
  if not tileid then return -1 end
  local tileid, fliph, flipv, flipd, rthex = parse_tile_id(tileid)
  if self._tiles[tileid] and self._tiles[tileid].animation then
    local tile = self._tiles[tileid]
    local anim = tile.animation
    local index = tile.frame % #tile.animation
    tileid = tile.animation[index + 1].tileid + 1
  end
  return tileid, fliph, flipv, flipd, rthex
end

function tilemap:setTileID(x, y, layerid, tileid)
  local layer = self._layers[layerid]
  if not layer then error('Undefined Layer') end
  if x < 0 or x >= layer.width or y < 0 or y >= layer.height then return end
  local index = x + y * layer.width + 1
  layer.data[index] = parse_tile_id(tonumber(tileid))
end

function tilemap:getTileObjects(tileid)
  if tileid <= 0 then return nil end
  return self._tileobjects[tileid] or { }
end

function tilemap:getTileProperty(tileid, property)
  if tileid <= 0 then return nil end
  if self._tiles[tileid] and self._tiles[tileid].properties then
    return self._tiles[tileid].properties[property]
  end
end

function tilemap:getTileType(tileid)
  if tileid < 0 then return nil end
  return self._tiletypes[tileid]
end

return tilemap
