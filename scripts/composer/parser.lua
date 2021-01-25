local Codes = require 'lib.codes'
local fun = require 'lib.fun'

--- Groups helper functions to parse card data
local Parser = {}

local types = Codes.const.type

--- Checks if numbers `a` and `b` have at least one common bit set.
--- @param a number
--- @param b number
--- @return boolean
function Parser.bcheck(a, b)
  return bit.band(a, b) ~= 0
end

--- Returns the commmon most significant bit between `a` and `b`
--- @param a number
--- @param b number
--- @return number
function Parser.match_msb(a, b)
  local n = bit.band(a, b)
  if n == 0 then return 0 end
  local msb = 1
  while n > 1 do
    n = bit.rshift(n, 1)
    msb = bit.lshift(msb, 1)
  end
  return msb
end

--- Returns the commmon least significant bit between `a` and `b`
--- @param a number
--- @param b number
--- @return number
function Parser.match_lsb(a, b)
  local n = bit.band(a, b)
  return bit.band(n, -n)
end

--- Returns a list with each set bit in `n`
--- @param n number
--- @return Fun
function Parser.bits(n)
  local bits = fun {}
  local b = 1
  while n > 0 do
    if Parser.bcheck(n, 1) then
      bits:push(b)
    end
    n = bit.rshift(n, 1)
    b = bit.lshift(b, 1)
  end
  return bits
end

---Returns the left and right Pendulum Scales of a card
---@param card CardData
---@return number
---@return number
function Parser.get_scales(card)
  local sc = card.level
  local lsc = bit.rshift(bit.band(sc, 0xFF000000), 24)
  local rsc = bit.rshift(bit.band(sc, 0x00FF0000), 16)
  return lsc, rsc
end

--- Returns card Level/Rank/Link Rating
--- @param card CardData
--- @return any
function Parser.get_level(card) return bit.band(card.level, 0x0000FFFF) end

--- Returns card Link Arrows
--- @param card CardData
--- @return any
function Parser.get_link_arrows(card) return bit.band(card.def, Codes.const.link.ALL) end

local effect_pattern =
  '^.*%[%s*[pP]endulum%s+[eE]ffect%s*%]%s*(.-)%s*[-_][-_][-_]+%s*'
    .. '%[%s*%a+%s+%a+%s*%]%s*(.-)%s*$'
local na_pattern = '^%s*[-_]%s*[nN]%s*/%s*[aA]%s*[-_]%s*$'
--- Returns card effect, taking into account that `desc` field in the
--- database can contain Pendulum Effect/Monster Effect/Flavor Text.
---@param card CardData
---@return string effect_or_flavor
---@return string pendulum_effect
function Parser.get_effects(card)
  if Parser.bcheck(card.type, types.PENDULUM) then
    local pe, me = card.desc:match(effect_pattern)
    if not pe then return card.desc end
    if pe:match(na_pattern) then pe = '' end
    if me:match(na_pattern) then me = '' end
    return me, pe
  else
    return card.desc
  end
end

return Parser
