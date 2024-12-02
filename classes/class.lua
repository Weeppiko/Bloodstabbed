local class = { }; class.__index = class

local function _call(self, ...)
  local new = setmetatable({ }, self)
  if new.initialize then new:initialize(...) end
  return new
end

function class.type(val)
  local lua_type = type(val)
  if lua_type ~= 'table' then return lua_type end
  local meta = getmetatable(val)
  return meta and meta.__index or lua_type
end

local metaclass = { }; metaclass.__index = metaclass
function metaclass:__call(parent)
  local newclass = { }; newclass.__index = newclass
  return setmetatable(newclass, { __index = parent or class, __call = _call })
end

return setmetatable(class, metaclass)
