require 'setup'

local color = require 'classes.color'
local function def(k, v) rawset(_G, k, v) end
def('COLOR_A', color(0x000000ff) )
def('COLOR_B', color(0x555555ff) )
def('COLOR_C', color(0xaaaaaaff) )
def('COLOR_D', color(0xffffffff) )
def( 'gameaudio',   require('managers.gameaudio')   )
def( 'gamecamera',  require('managers.gamecamera')  )
def( 'gameroom',    require('managers.gameroom')    )
def( 'gameinput',   require('managers.gameinput')   )
def( 'gamestate',   require('managers.gamestate')   )
def( 'gamescreen',  require('managers.gamescreen')  )
def( 'gamescene',   require('managers.gamescene')   )

def( 'json',  require('libs.json')  )
def( 'mathx', require('libs.mathx') )
def( 'tablx', require('libs.tablx') )

local settings
local function _reset()
  love.audio.setVolume(settings.audio_volume)
  --love.audio.setVolume(0)
  gameaudio:stop()
  gamescreen:initialize(settings.screen_width, settings.screen_height)
  gameinput:clear()
  gamescene.set('scenes.inboot')
  gamescene.poll()
end

function love.load(args, uargs, cfg)
  settings = cfg
  _reset()
end

function love.update(dt)
  gameaudio:update(dt)
  if not gamescreen:isFading() then
    gamescene.scall('update', dt)
  end
  gamescreen:update(dt)
  if not gamescreen:isFading() then
    gamescene.poll()
  end
  gameinput:step()
end

local function render()
  love.graphics.clear(0, 0, 0)
  gamescene.scall('draw')
end

function love.draw()
  gamescreen:render(render)
  gamescreen:draw()
end

function love.keypressed(key, scancode, isrepeat)
  if not isrepeat then
    if IS_DEVMODE then
      if key == 'f5' then return _reset() end
  	  if key == 'escape' then return love.event.quit() end
      if key == 'f7' then return love.event.quit('restart') end
    end
  	if key == 'f11' or key == 'return' and love.keyboard.isDown('lalt') then
      settings.fullscreen = not love.window.getFullscreen()
  		return love.window.setFullscreen(settings.fullscreen)
  	end
  end
  if not isrepeat then gameinput:keypressed(scancode) end
  gamescene.scall('keypressed', key, scancode, isrepeat)
end

function love.keyreleased(key, scancode)
  gameinput:keyreleased(scancode)
  gamescene.scall('keyreleased', key, scancode)
end

function love.joystickadded(joystick)
  gamescene.scall('joystickadded', joystick)
end

function love.joystickremoved(joystick)
  gamescene.scall('joystickremoved', joystick)
end

function love.gamepadpressed(joystick, button)
  gameinput:gamepadpressed(button)
  gamescene.scall('gamepadpressed', joystick, button)
end

function love.gamepadreleased(joystick, button)
  gameinput:gamepadreleased(button)
  gamescene.scall('gamepadreleased', joystick, button)
end

function love.gamepadaxis(joystick, axis, value)
  gameinput:gamepadaxis(axis, value)
  gamescene.scall('gamepadreleased', joystick, axis, value)
end

function love.quit()
  if not IS_DEVMODE then
    love.filesystem.write( 'settings.json', require('libs.json').encode(settings) )
  end
  return false
end

function love.threaderror(_, err)
  error(err)
end
