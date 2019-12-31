local path = require 'path'
local GameConst = require 'scripts.game-const'
local Logs = require 'scripts.logs'
local MetaLayer = require 'scripts.composer.metalayer'
local Parser = require 'scripts.composer.parser'


local Decoder = {}

local insert = table.insert

local types = GameConst.code.type
local monster_types = types.NORMAL + types.EFFECT + types.FUSION + types.RITUAL
  + types.SYNCHRO + types.TOKEN + types.XYZ + types.LINK
local spellortrap = types.SPELL + types.TRAP
local spelltrap_types = types.CONTINUOUS + types.COUNTER + types.EQUIP
  + types.FIELD + types.QUICKPLAY + types.RITUAL
local frame_types = monster_types + spellortrap

local function typef_ov(n) return ("type%u.png"):format(n) end
local function st_ov(n, sfx) return ("st%u%s.png"):format(n, sfx or "") end
local function linka_ov(n) return ("lka%u.png"):format(n) end
local function rank_ov(n) return ("r%u.png"):format(n) end
local function level_ov(n) return ("l%u.png"):format(n) end
local function attr_ov(n) return ("att%u.png"):format(n) end

local automatons = {}

function automatons.anime(data)
  local states, inital = {}, 'art'
  local layers = {}

  function states.art()
    insert(layers, MetaLayer("art", data.img))
    if Parser.bcheck(data.type, spellortrap) then
      return states.spelltrap()
    elseif Parser.bcheck(data.type, types.MONSTER) then
      return states.monster()
    else
      return nil, "Not a monster nor a spell/trap"
    end
  end

  function states.spelltrap()
    local st = Parser.match_lsb(data.type, spellortrap)
    insert(layers, MetaLayer("overlay", typef_ov(st)))
    return layers
  end

  function states.monster()
    local mtype = Parser.match_msb(data.type, monster_types)
    if mtype == 0 then
      return nil, "Missing monster type"
    end
    insert(layers, MetaLayer("overlay", typef_ov(mtype)))
    if Parser.bcheck(data.type, types.PENDULUM) then
      return states.pendulum()
    elseif Parser.bcheck(data.type, types.LINK) then
      return states.link()
    elseif Parser.bcheck(data.type, types.XYZ) then
      return states.rank()
    else
      return states.level()
    end
  end

  function states.pendulum()
    local lsc, rsc = Parser.get_scales(data)
    insert(layers, MetaLayer("overlay", typef_ov(types.PENDULUM)))
    insert(layers, MetaLayer("scales", lsc, rsc))
    if Parser.bcheck(data.type, types.LINK) then
      return states.link()
    elseif Parser.bcheck(data.type, types.XYZ) then
      return states.rank()
    else
      return states.level()
    end
  end

  function states.link()
    insert(layers, MetaLayer("overlay", "lka-base.png"))
    for b in Parser.bits(Parser.get_link_arrows(data)) do
      insert(layers, MetaLayer("overlay", linka_ov(b)))
    end
    insert(layers, MetaLayer("overlay", "link.png"))
    insert(layers, MetaLayer("link_rating", Parser.get_link_rating(data)))
    return states.atk()
  end

  function states.rank()
    local rank = Parser.get_levelrank(data)
    if rank then
      insert(layers, MetaLayer("overlay", rank_ov(rank)))
    end
    return states.def()
  end

  function states.level()
    local level = Parser.get_levelrank(data)
    if level then
      insert(layers, MetaLayer("overlay", level_ov(level)))
    end
    return states.def()
  end

  function states.def()
    insert(layers, MetaLayer("def", data.def))
    return states.atk()
  end

  function states.atk()
    insert(layers, MetaLayer("atk", data.atk))
    return states.attribute()
  end

  function states.attribute()
    local att = Parser.match_lsb(data.attribute, GameConst.code.att.ALL)
    if att == 0 then
      return nil, "No attribute"
    end
    insert(layers, MetaLayer("overlay", attr_ov(data.attribute)))
    return layers
  end

  return states[inital]()
end

function automatons.proxy(data)
  local states, inital = {}, 'baseframe'
  local layers = {}

  function states.baseframe()
    local frame = Parser.match_msb(data.type, frame_types)
    if frame == 0 then
      return nil, "Missing card type"
    end
    insert(layers, MetaLayer("overlay", typef_ov(frame)))
    if Parser.bcheck(data.type, types.PENDULUM) then
      return states.pendulum()
    else
      return states.art()
    end
  end

  local monster_effect
  function states.pendulum()
    insert(layers, MetaLayer("pendulum_art", data.img))
    insert(layers, MetaLayer("pendulum_frame"))
    insert(layers, MetaLayer("pendulum_scales", Parser.get_scales(data)))
    local me, pe = Parser.get_effects(data)
    monster_effect = me
    if pe then
      insert(layers, MetaLayer("pendulum_effect", pe))
    end
    if Parser.bcheck(data.type, types.LINK) then
      return states.pendulum_link()
    elseif Parser.bcheck(data.type, types.XYZ) then
      return states.rank()
    else
      return states.level()
    end
  end

  function states.pendulum_link()
    insert(layers, MetaLayer("pendulum_lkabase"))
    for b in Parser.bits(Parser.get_link_arrows(data)) do
      insert(layers, MetaLayer("pendulum_lka", b))
    end
    return states.link_rating()
  end

  function states.art()
    insert(layers, MetaLayer("art", data.img))
    if Parser.bcheck(data.type, spellortrap) then
      return states.spelltrap()
    elseif Parser.bcheck(data.type, types.LINK) then
      return states.link_arrows()
    elseif Parser.bcheck(data.type, types.XYZ) then
      return states.rank()
    else
      return states.level()
    end
  end

  function states.spelltrap()
    local st_type = Parser.match_lsb(data.type, spelltrap_types)
    if st_type == 0 then
      insert(layers, MetaLayer("overlay", st_ov(data.type)))
    else
      local st = Parser.match_lsb(data.type, spellortrap)
      insert(layers, MetaLayer("overlay", st_ov(st, "p")))
      insert(layers, MetaLayer("overlay", st_ov(st_type)))
    end
    insert(layers, MetaLayer("spelltrap_effect", data.desc))
    return states.name()
  end

  function states.link_arrows()
    insert(layers, MetaLayer("overlay", "lka-base.png"))
    for b in Parser.bits(Parser.get_link_arrows(data)) do
      insert(layers, MetaLayer("overlay", linka_ov(b)))
    end
    return states.link_rating()
  end

  function states.link_rating()
    insert(layers, MetaLayer("overlay", "link.png"))
    local link_rating = Parser.get_link_rating(data)
    insert(layers, MetaLayer("link_rating", link_rating))
    return states.atk()
  end

  function states.rank()
    local rank = Parser.get_levelrank(data)
    if rank then
      insert(layers, MetaLayer("overlay", rank_ov(rank)))
    end
    return states.def()
  end

  function states.level()
    local level = Parser.get_levelrank(data)
    if level then
      insert(layers, MetaLayer("overlay", level_ov(level)))
    end
    return states.def()
  end

  function states.def()
    insert(layers, MetaLayer("def", data.def))
    return states.atk()
  end

  function states.atk()
    insert(layers, MetaLayer("atk", data.atk))
    return states.monster_desc()
  end

  function states.monster_desc()
    local race = Parser.get_race(data)
    local sumtype = Parser.get_sumtype(data); sumtype = sumtype and "/" .. sumtype or ""
    local pend = Parser.bcheck(data.type, types.PENDULUM) and "/Pendulum" or ""
    local ability = Parser.get_ability(data); ability = ability and "/" .. ability or ""
    local tuner = Parser.bcheck(data.type, types.TUNER) and "/Tuner" or ""
    local effnorm = (Parser.bcheck(data.type, types.EFFECT) and "/Effect")
      or (Parser.bcheck(data.type, types.NORMAL) and "/Normal") or ""
    local desc = ("%s%s%s%s%s%s"):format(race, sumtype, pend, ability, tuner, effnorm)
    insert(layers, MetaLayer("monster_desc", desc))
    return states.monster_text()
  end

  function states.monster_text()
    local me = monster_effect or Parser.get_effects(data)
    if Parser.bcheck(data.type, types.NORMAL)
      and not Parser.bcheck(data.type, types.TOKEN) then
      insert(layers, MetaLayer("flavor_text", me))
    else
      insert(layers, MetaLayer("monster_effect", me))
    end
    return states.attribute()
  end

  function states.attribute()
    local att = Parser.match_lsb(data.attribute, GameConst.code.att.ALL)
    if att == 0 then
      return nil, "No attribute"
    end
    insert(layers, MetaLayer("overlay", attr_ov(data.attribute)))
    return states.name()
  end

  function states.name()
    local lightbg = Parser.bcheck(data.type, types.SYNCHRO)
    insert(layers, MetaLayer("name", data.name, lightbg and { 0, 0, 0 }))
    if Parser.bcheck(data.type, types.TOKEN) then
      return states.finishing()
    else
      return states.serial_code()
    end
  end

  function states.serial_code()
    local darkbg = Parser.bcheck(data.type, types.XYZ)
      and not Parser.bcheck(data.type, types.PENDULUM)
    insert(layers, MetaLayer("serial_code", data.id, darkbg and { 255, 255, 255 }))
    return states.finishing()
  end

  function states.finishing()
    local darkbg = Parser.bcheck(data.type, types.XYZ)
      and not Parser.bcheck(data.type, types.PENDULUM)
    insert(layers, MetaLayer("copyright", darkbg and { 255, 255, 255 }))
    insert(layers, MetaLayer("overlay", "bevel.png"))
    insert(layers, MetaLayer("overlay", "holo.png"))
    return layers
  end

  return states[inital]()
end

function Decoder.decode(mode, data)
  local automaton = automatons[mode]
  Logs.assert(automaton, 1, "Unknown mode \"", mode, '"')
  return automaton(data)
end

return Decoder
