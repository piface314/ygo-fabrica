local GameConst = require 'scripts.game-const'


local Parser = {}

local types = GameConst.code.type

function Parser.bcheck(a, b)
  return bit.band(a, b) ~= 0
end

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

function Parser.match_lsb(a, b)
  local n = bit.band(a, b)
  return bit.band(n, -n)
end

function Parser.bits(n)
  return coroutine.wrap(function()
    local b = 1
    while n > 0 do
      if Parser.bcheck(n, 1) then
        coroutine.yield(b)
      end
      n = bit.rshift(n, 1)
      b = bit.lshift(b, 1)
    end
  end)
end

function Parser.get_scales(data)
  local sc = data.level
  local lsc = bit.rshift(bit.band(sc, 0xFF000000), 24)
  local rsc = bit.rshift(bit.band(sc, 0x00FF0000), 16)
  return lsc, rsc
end

function Parser.get_levelrank(data)
  local lvlrank = bit.band(data.level, 0x0000FFFF)
  return lvlrank > 0 and lvlrank <= 12 and lvlrank or nil
end

function Parser.get_link_rating(data)
  return bit.band(data.level, 0x0000FFFF)
end

function Parser.get_link_arrows(data)
  return bit.band(data.def, GameConst.code.link.ALL)
end

local effect_pattern = "^.*%[%s*[pP]endulum%s+[eE]ffect%s*%]%s*(.-)%s*[-_][-_][-_]+%s*"
  ..  "%[%s*%a+%s+%a+%s*%]%s*(.-)%s*$"
local na_pattern = "^%s*[-_]%s*[nN]%s*/%s*[aA]%s*[-_]%s*$"
function Parser.get_effects(data)
  if Parser.bcheck(data.type, types.PENDULUM) then
    local pe, me = data.desc:match(effect_pattern)
    if not pe then return data.desc end
    if pe:match(na_pattern) then pe = "" end
    if me:match(na_pattern) then me = "" end
    return me, pe
  else
    return data.desc
  end
end

function Parser.get_race(data)
  local race = Parser.match_lsb(data.race, GameConst.code.race.ALL)
  return GameConst.name.race[race]
end

local sumtypes = types.FUSION + types.LINK + types.RITUAL + types.SYNCHRO + types.XYZ
function Parser.get_sumtype(data)
  local sumtype = Parser.match_lsb(data.type, sumtypes)
  return GameConst.name.type[sumtype]
end

local abilities = types.FLIP + types.GEMINI + types.SPIRIT + types.TOON + types.UNION
function Parser.get_ability(data)
  local ability = Parser.match_lsb(data.type, abilities)
  return GameConst.name.type[ability]
end

return Parser
