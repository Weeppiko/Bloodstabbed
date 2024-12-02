-- inboot.lua
local inboot = { }

local intro_sprite = love.graphics.newImage('assets/system/intro.png')
local intro_quad   = love.graphics.newQuad(0, 0, 1, 1, intro_sprite)
local intro_anim   = json.decode( love.filesystem.read('assets/system/intro.json') )
local cache = require 'managers.cache'

function inboot:enter()
  gamescreen:setPalette(1)
  gamescreen:fadein(0)
  self.frame = 1
  self.timer = 0
end

function inboot:update(dt)
  local frame = intro_anim.frames[self.frame]
  self.timer = self.timer + dt
  if self.timer >= frame.duration / 1000 then
    self.timer = self.timer - frame.duration / 1000
    self.frame = self.frame + 1
    if self.frame == 21 then
      gameaudio:playSFX('intro.wav')
    end
  end
  if self.frame > #intro_anim.frames or gameinput:get(JOY_START) > 0 then
    gamescene.switch('scenes.intitle')
    self.frame = #intro_anim.frames
  end
end

function inboot:draw()
  local frame = intro_anim.frames[self.frame].frame
  intro_quad:setViewport(frame.x, frame.y, frame.w, frame.h)
  love.graphics.draw(intro_sprite, intro_quad)
end

return inboot
