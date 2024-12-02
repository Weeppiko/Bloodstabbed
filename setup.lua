local _os = love.system.getOS()
IS_DEVMODE = not love.filesystem.isFused()

local settings = {
  screen_width  = 160,
  screen_height = 144,
  fullscreen    = false,
  vertical_sync = 1,
  window_scale  = 3,
  audio_volume  = 1,
}

if not IS_DEVMODE then
  local json = require 'libs.json'
  local mathx = require 'libs.mathx'
  local data, ok = love.filesystem.read('settings.json')
  if data then ok, data = pcall(json.decode, data) end
  if data and not IS_DEVMODE then for k, v in pairs(data) do settings[k] = v end end
  love.filesystem.write( 'settings.json', json.encode(settings) )
end
love.window.setMode(
  settings.screen_width  * settings.window_scale,
  settings.screen_height * settings.window_scale,
  {
    highdpi        = false,
    usedpiscale    = false,
    vsync          = settings.vertical_sync,
    fullscreen     = settings.fullscreen,
  }
)

SETTINGS = settings
love.window.setTitle('Bloodstabbed')
love.keyboard.setKeyRepeat(true)
love.graphics.setDefaultFilter('nearest', 'nearest', 0)
love.graphics.setLineStyle('rough')
love.graphics.setFont( require('fonts').normal )
love.mouse.setVisible(false)

if not love.filesystem.isFused() then
  setmetatable(_G, {
    __newindex = function(t, k, v)
      error('Tried to create a global variable ' .. "'" .. k .. "'", 2)
    end,
    __index = function(t, k)
      if nil == rawget(t, k) then
        error('Global variable ' .. k .. " doesn't exist!", 2)
      end
      return rawget(t, k)
    end,
  })
end

function love.run()
  local threshold, dt = 1/60, 0
  if love.load then love.load(love.arg.parseGameArguments(arg), arg, settings) end
  if love.timer then
    love.timer.step()
    love.timer.getDelta = function() return math.min(dt, threshold)  end
  end
  return function()
    if love.event then
      love.event.pump()
      for name, a,b,c,d,e,f in love.event.poll() do
        if name == "quit" then
          if not love.quit or not love.quit() then
            return a or 0
          end
        end
        love.handlers[name](a,b,c,d,e,f)
      end
    end
    if love.timer then dt = love.timer.step() end
    if love.update then love.update( math.min(dt, threshold) ) end
    if love.graphics and love.graphics.isActive() then
      love.graphics.origin()
      love.graphics.clear(love.graphics.getBackgroundColor())
      if love.draw then love.draw() end
      love.graphics.present()
    end
    if love.timer then love.timer.sleep(0.001) end
  end
end

