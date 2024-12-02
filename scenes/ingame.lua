-- ingame.lua
local ingame = { }

local function init_objects(object)
  if object.properties._module then
    local otype = object.properties._module
    gameroom:addInstance(otype, object.layerid, object.x, object.y, object.properties, object)
  end
end

function ingame:enter(level_name)
  self._paused = false
  gameaudio:stop()
  gamescreen:fadein(1)
  gameroom:load(level_name, init_objects)
  gamecamera:reset( gamescreen:getDimensions() )
  self:_load_script()
  self:_load_music()
  gamescreen:setPalette( gameroom:getProperty('palette_index') )
end

function ingame:_load_script()
  local _env = { dt = 0, self = { } }
  setmetatable(_env, { __index = _G })
  local script = gameroom:getProperty('script')
  if script then
    self._running = true
    self._script = loadstring(script)
    setfenv(self._script, _env)
  end
end

function ingame:_load_music()
  local music = gameroom:getProperty('music_filename')
  local loopstart = gameroom:getProperty('music_loopstart')
  if music then gameaudio:playBGM(music, 0.75, loopstart) end
end

function ingame:stopScript()
  self._running = false
end

function ingame:update(dt)
  if gameinput:getOnce(JOY_START) > 0 then
    self._paused = not self._paused
  end
  if self._paused then return end
  gameroom:update(dt)
  gamestate:update(dt)
  if self._script and self._running then
    getfenv(self._script).dt = dt
    self._script()
  end
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

function ingame:draw()
  love.graphics.push('all')
  love.graphics.clear(0, 0, 0, 1)
  gameroom:draw()
  love.graphics.pop()
  love.graphics.push('all')
  gamestate:draw()
  if self._paused then
    love.graphics.setFont( require('fonts').normal )
    bprintf('PAUSED', 0, 64, 160, 'center')
  end
  love.graphics.pop()
end

function ingame:gameover(...)
  gamescene.switch('scenes.gameover', ...)
  gamescreen:setPalette(4)
  gamescreen:fadeout(2)
end

return ingame
