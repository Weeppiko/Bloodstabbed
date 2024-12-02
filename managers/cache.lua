local cache = { }

local images = { }
local sounds = { }

function cache.getImage(filename)
  images[filename] = images[filename] or love.graphics.newImage(filename)
  return images[filename]
end

function cache.getSound(filename)
  sounds[filename] = sounds[filename] or love.audio.newSource(filename, 'static')
  return sounds[filename]
end


return cache
