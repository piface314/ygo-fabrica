local path = require 'path'
local GameConst = require 'scripts.game-const'
local Logs = require 'scripts.logs'
local MetaLayer = require 'scripts.composer.metalayer'


local Decoder = {}

local insert = table.insert

local function inverse(t)
  local u = {}
  for k, v in pairs(t) do u[v] = k end
  return u
end

local function bcheck(a, b)
  return bit.band(a, b) ~= 0
end

local function msb(a, b)
  local n = bit.band(a, b)
  if n == 0 then return 0 end
  local msb = 1
  while n > 1 do
    n = bit.rshift(n, 1)
    msb = bit.lshift(msb, 1)
  end
  return msb
end

local function bits(n)
  return coroutine.wrap(function()
    local b = 1
    while n > 0 do
      if bcheck(n, 1) then
        coroutine.yield(b)
      end
      n = bit.rshift(n, 1)
      b = bit.lshift(b, 1)
    end
  end)
end

local function get_scales(data)
  local sc = data.level
  local lsc = bit.rshift(bit.band(sc, 0xFF000000), 24)
  local rsc = bit.rshift(bit.band(sc, 0x00FF0000), 16)
  return lsc, rsc
end

local function get_levelrank(data)
  return bit.band(data.level, 0x0000FFFF)
end

local types = GameConst.code.type
local monster_types = types.NORMAL + types.EFFECT + types.FUSION + types.RITUAL
  + types.SYNCHRO + types.TOKEN + types.XYZ + types.LINK
local spelltrap_type = types.SPELL + types.TRAP
local atts = inverse(GameConst.code.att)

local function typef_ov(n) return ("type%d.png"):format(n) end
local function linkm_ov(n) return ("lkm%d.png"):format(n) end
local function rank_ov(n) return ("r%d.png"):format(n) end
local function level_ov(n) return ("l%d.png"):format(n) end
local function attr_ov(n) return ("att%d.png"):format(n) end

local automatons = {}

function automatons.anime(data)
  local states, inital = {}, 'img'
  local layers = {}

  function states.img()
    insert(layers, MetaLayer("art", data.img))
    if bcheck(data.type, spelltrap_type) then
      return states.spelltrap()
    elseif bcheck(data.type, types.MONSTER) then
      return states.monster()
    end
  end

  function states.spelltrap()
    local st = msb(data.type, spelltrap_type)
    insert(layers, MetaLayer("overlay", typef_ov(st)))
    return layers
  end

  function states.monster()
    local mtype = msb(data.type, monster_types)
    if mtype == 0 then return nil end
    insert(layers, MetaLayer("overlay", typef_ov(mtype)))
    if bcheck(data.type, types.PENDULUM) then
      return states.pendulum()
    elseif bcheck(data.type, types.LINK) then
      return states.link()
    elseif bcheck(data.type, types.XYZ) then
      return states.rank()
    else
      return states.level()
    end
  end

  function states.pendulum()
    local lsc, rsc = get_scales(data)
    insert(layers, MetaLayer("overlay", typef_ov(types.PENDULUM)))
    insert(layers, MetaLayer("scales", lsc, rsc))
    if bcheck(data.type, types.LINK) then
      return states.link()
    elseif bcheck(data.type, types.XYZ) then
      return states.rank()
    else
      return states.level()
    end
  end

  function states.link()
    insert(layers, MetaLayer("overlay", "lkm-base.png"))
    for b in bits(data.def) do
      insert(layers, MetaLayer("overlay", linkm_ov(b)))
    end
    insert(layers, MetaLayer("linkrate", get_levelrank(data)))
    return states.atk()
  end

  function states.rank()
    local rank = get_levelrank(data)
    insert(layers, MetaLayer("overlay", rank_ov(rank)))
    return states.def()
  end

  function states.level()
    local level = get_levelrank(data)
    insert(layers, MetaLayer("overlay", level_ov(level)))
    return states.def()
  end

  function states.def()
    insert(layers, MetaLayer("def", data.def))
    return states.atk()
  end

  function states.atk()
    insert(layers, MetaLayer("atk", data.atk))
    return states.attr()
  end

  function states.attr()
    if atts[data.attribute] then
      insert(layers, MetaLayer("attr", data.attribute))
      return layers
    end
  end
  
  return states[inital]()
end

function automatons.proxy(data)
  return {}
end

function Decoder.decode(data, mode)
  local automaton = automatons[mode]
  Logs.assert(automaton, 1, "Unknown mode \"", mode, '"')
  return automaton(data)
end

return Decoder
