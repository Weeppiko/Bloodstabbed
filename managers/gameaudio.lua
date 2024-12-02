local gameaudio = { }
local music_path = 'assets/music/'
local sound_path = 'assets/sound/'
local static = { }

function gameaudio:stop()
  love.audio.stop()
  self._source = nil
  self._decoder = nil
  self._musfx = nil
  self._fade = nil
end

function gameaudio:update(dt)
  if not self._playing then return end
  if not self._decoder then return end
  if self._source:getFreeBufferCount() > 0 then
    local buffer = self._decoder:decode()
    self._position = self._position + buffer:getSampleCount()
    if self._position >= self._length then
      self._decoder:seek(self._loop_point)
      self._position = ( self._loop_point / self._decoder:getDuration() ) * self._length
    end
    self._source:queue(buffer)
    buffer:release()
  end
  if not ( self._musfx and self._musfx:isPlaying() ) then
    if self._fade then
      local f = self._fade
      f.count = f.count + dt
      local vol = mathx.lerp(f.from, f.to, f.count / f.time)
      local a, b = math.min(f.from, f.to), math.max(f.from, f.to)
      self._source:setVolume( mathx.clamp(vol, a, b) )
    end
    self._source:play()
  end
end

function gameaudio:playBGM(name, volume, loop_point)
  self._fade = nil
  if self._musfx then self._musfx:stop() end
  if self._source then self._source:stop() end
  self._decoder = love.sound.newDecoder(music_path .. name)
  self._source  = love.audio.newQueueableSource(
    self._decoder:getSampleRate(),
    self._decoder:getBitDepth(),
    self._decoder:getChannelCount()
  )
  self._source:setVolume(volume or 1)
  self._loop_point = loop_point or 0
  self._position   = 0
  self._length     = self._decoder:getDuration() * self._decoder:getSampleRate()
  self._playing    = true
end

function gameaudio:pauseBGM()
  self._playing = false
  if self._source then self._source:pause() end
end

function gameaudio:resumeBGM()
  self._playing = true
  self._source:play()
  if self._musfx then self._musfx:stop() end
end

function gameaudio:stopBGM()
  self._playing = false
  if self._source then
    self._source:stop()
    self._decoder:seek(0)
  end
end

function gameaudio:fadeBGM(from, to, time)
  self._fade = { from = from, to = to, time = time, count = 0 }
end

function gameaudio:playME(name, volume)
  self._musfx = love.audio.newSource(music_path .. name, 'stream')
  self._musfx:setVolume(volume or 1)
  self._musfx:play()
  if self._source then self._source:pause() end
end

function gameaudio:isPlayingME()
  return self._musfx and self._musfx:isPlaying()
end

function gameaudio:playSFX(name, volume, pitch)
  static[name] = static[name] or love.audio.newSource(sound_path .. name, 'static')
  local sound = static[name]
  sound:stop()
  sound:setVolume(volume or 1)
  sound:setPitch(pitch or 1)
  sound:play()
end

return gameaudio
