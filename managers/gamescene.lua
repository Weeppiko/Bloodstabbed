-- gamescene.lua
local gamescene = { }
local handler = { }
local stack = { }
local request

local function _assert(v, msg)
  if not v then return error(msg, 2) end
end

local function _assert_state(state)
  if not (type(state) == 'table' or type(state) == 'string') then
    error('invalid state entry!', 2)
  end
end

local function _forced_unpack_(tbl, size, index)
  if index < size then
    return tbl[index], _forced_unpack_(tbl, size, index + 1)
  else
    return tbl[index]
  end
end

local function forced_unpack(tbl, size)
  return _forced_unpack_(tbl, size, 1)
end

function handler.push(newstate, ...)
  local laststate = stack[#stack]
  table.insert(stack, newstate)
  if laststate and laststate.change then laststate:change(...) end
  if newstate.enter then newstate:enter(...) end
end

function handler.pop(_, ...)
  local laststate = table.remove(stack)
  local newstate = stack[#stack]
  if laststate.leave then laststate:leave(...) end
  if newstate and newstate.resume then newstate:resume(...) end
end

function handler.switch(newstate, ...)
  local laststate = table.remove(stack)
  table.insert(stack, newstate)
  if laststate and laststate.leave then laststate:leave(...) end
  if newstate.enter then newstate:enter(...) end
end

function handler.set(newstate, ...)
  gamescene.clear(...)
  table.insert(stack, newstate)
  if newstate.enter then newstate:enter(...) end
end

function gamescene.poll()
  if request then
    handler[request.event]( request.state, forced_unpack(request.args, request.args.size) )
  end
  request = nil
end

function gamescene.clear(...)
  if #stack > 0 then
    local laststate = table.remove(stack)
    stack, request = { }
    if laststate and laststate.leave then laststate:leave(...) end
  end
end

function gamescene.push(new, ...)
  _assert_state(new);
  _assert(not request, 'A state change has already been requested on this frame!')
  if type(new) == 'string' then new = require(new) end
  local newstate = setmetatable({ }, { __index = new })
  request = { event = 'push', state = newstate, args = { size = select('#', ...), ... } }
end

function gamescene.pop(...)
  _assert(not request, 'A state change has already been requested on this frame!')
  request = { event = 'pop', args = { size = select('#', ...), ... } }
end

function gamescene.switch(new, ...)
  _assert_state(new);
  _assert(not request, 'A state change has already been requested on this frame!')
  if type(new) == 'string' then new = require(new) end
  local newstate = setmetatable({ }, { __index = new })
  local event = #stack > 0 and 'switch' or 'push'
  request = { event = event, state = newstate, args = { size = select('#', ...), ... } }
end

function gamescene.set(new, ...)
  _assert_state(new);
  _assert(not request, 'A state change has already been requested on this frame!')
  if type(new) == 'string' then new = require(new) end
  local newstate = setmetatable({ }, { __index = new })
  request = { event = 'set', state = newstate, args = { size = select('#', ...), ... } }
end

function gamescene.has(event)
  return stack[#stack] and not not stack[#stack][event]
end

function gamescene.call(event, ...)
  _assert(#stack > 0, 'there is no active state yet!')
  _assert(stack[#stack][event], 'event "' .. event .. '" do not exists on the current state!')
  return stack[#stack][event](stack[#stack], ...)
end

function gamescene.scall(event, ...)
  if gamescene.has(event) then
    return gamescene.call(event, ...)
  end
end

function gamescene.get(index)
  return stack[index or #stack]
end

function gamescene.getStackCount()
  return #stack
end

function gamescene.isChanging()
  return not not request
end

return gamescene
