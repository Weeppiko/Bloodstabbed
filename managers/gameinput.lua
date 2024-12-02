-- gameinput.lua
local gameinput = { }
local lshift = bit.lshift
local bor, band = bit.bor, bit.band
local bxor, bnot = bit.bxor, bit.bnot
local function define(k, v) rawset(_G, k, v) end

define( 'JOY_UP'     , lshift(1, 0) )
define( 'JOY_DOWN'   , lshift(1, 1) )
define( 'JOY_LEFT'   , lshift(1, 2) )
define( 'JOY_RIGHT'  , lshift(1, 3) )
define( 'JOY_A'      , lshift(1, 4) )
define( 'JOY_B'      , lshift(1, 5) )
define( 'JOY_START'  , lshift(1, 6) )
define( 'JOY_SELECT' , lshift(1, 7) )
define( 'JOY_MASK'   , 0b1111111111 )

local GAMEPAD_MAP = {
  dpup          = JOY_UP,
  dpdown        = JOY_DOWN,
  dpleft        = JOY_LEFT,
  dpright       = JOY_RIGHT,
  a             = JOY_A,
  b             = JOY_B,
  x             = JOY_B,
  y             = JOY_A,
  start         = JOY_START,
  back          = JOY_SELECT,
}

local GAMEPAD_AXIS = {
  ['lefty-'] = JOY_UP,
  ['lefty+'] = JOY_DOWN,
  ['leftx-'] = JOY_LEFT,
  ['leftx+'] = JOY_RIGHT,
}

local KEYBOARD_MAP = {
  up         = JOY_UP,
  down       = JOY_DOWN,
  left       = JOY_LEFT,
  right      = JOY_RIGHT,
  z          = JOY_A,
  x          = JOY_B,
  ['return'] = JOY_START,
  backspace  = JOY_SELECT,
}

function gameinput:clear()
  self.last    = 0
  self.press   = 0
  self.release = 0
end

function gameinput:step()
  self.last = self.press
  self.press = band( bnot(self.release), self.press )
  self.release = 0
end

function gameinput:pressed(mask)
  self.press = bor( self.press, mask )
  self.release = band( bnot(mask), self.release )
end

function gameinput:released(mask)
  self.release = bor( self.release, mask )
end

function gameinput:axis(value, lo, hi)
  if math.abs(value) < 0.1 then
    if self:get(hi) > 0 then
      self.release = bor( self.release, hi)
    end
    if self:get(lo) > 0 then
      self.release = bor( self.release, lo)
    end
  elseif value < 0 then
    self.press = bor( self.press, lo)
    self.release = band( bnot(lo), self.release )
    if self:get(hi) > 0 then
      self.release = bor( self.release, hi)
    end
  else
    self.press = bor( self.press, hi)
    self.release = band( bnot(hi), self.release )
    if self:get(lo) > 0 then
      self.release = bor( self.release, lo)
    end
  end
end

function gameinput:gamepadpressed(button)
  self:pressed( GAMEPAD_MAP[button] or 0 )
end

function gameinput:gamepadreleased(button)
  self:released( GAMEPAD_MAP[button] or 0 )
end

function gameinput:gamepadaxis(axis, value)
  local hi = GAMEPAD_AXIS[axis .. '+'] or 0
  local lo = GAMEPAD_AXIS[axis .. '-'] or 0
  self:axis(value, lo, hi)
end

function gameinput:keypressed(scancode)
  self:pressed( KEYBOARD_MAP[scancode] or 0 )
end

function gameinput:keyreleased(scancode)
  self:released( KEYBOARD_MAP[scancode] or 0 )
end

function gameinput:get(mask)
  return band( self.press, mask )
end

function gameinput:getOnce(mask)
  return band( band( self.press, mask ), bnot(self.last) )
end

return gameinput
