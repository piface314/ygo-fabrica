local GameConst = require 'scripts.game-const'
local Logs = require 'lib.logs'
local MetaLayer = require 'scripts.composer.metalayer'
local Parser = require 'scripts.composer.parser'
local Transformer = require 'scripts.composer.transformer'


local Decoder = {}

local insert = table.insert
local mode, options = 'proxy', {}

local types = GameConst.code.type
local monster_types = types.NORMAL + types.EFFECT + types.FUSION + types.RITUAL
  + types.SYNCHRO + types.TOKEN + types.XYZ + types.LINK
local spellortrap = types.SPELL + types.TRAP
local spelltrap_types = types.CONTINUOUS + types.COUNTER + types.EQUIP
  + types.FIELD + types.QUICKPLAY + types.RITUAL
local frame_types = monster_types + spellortrap

local function typef_ov(n, sfx) return ("type%u%s.png"):format(n, sfx or "") end
local function st_ov(n, sfx) return ("st%u%s.png"):format(n, sfx or "") end
local function linka_ov(n, sfx) return ("lka%u%s.png"):format(n, sfx or "") end
local function rank_ov(n) return ("r%u.png"):format(n) end
local function level_ov(n) return ("l%u.png"):format(n) end
local function attr_ov(n) return ("att%u.png"):format(n) end

local min, max, ceil = math.min, math.max, math.ceil
local function clamp(v) return min(max(ceil(tonumber(v, 16)), 0), 255) end
local function color_clamp(color)
  if type(color) ~= 'string' then return nil end
  local r, g, b = color:match("^#(%x%x)(%x%x)(%x%x)$")
  if not r then return nil end
  return { clamp(r), clamp(g), clamp(b) }
end
local black, white = { 0, 0, 0 }, { 255, 255, 255 }
local name_colors = {
  [types.NORMAL] = {"color-normal", black},
  [types.EFFECT] = {"color-effect", black},
  [types.FUSION] = {"color-fusion", white},
  [types.RITUAL] = {"color-ritual", white},
  [types.SYNCHRO] = {"color-synchro", black},
  [types.TOKEN] = {"color-token", black},
  [types.XYZ] = {"color-xyz", white},
  [types.LINK] = {"color-link", white},
  [types.SPELL] = {"color-spell", white},
  [types.TRAP] = {"color-trap", white}
}

local automatons = {}

function automatons.anime(data)
  local states, inital = {}, 'art'
  local layers = {}

  function states.art()
    insert(layers, MetaLayer.new("art", data.img))
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
    insert(layers, MetaLayer.new("overlay", typef_ov(st)))
    return layers
  end

  function states.monster()
    local mtype = Parser.match_msb(data.type, monster_types)
    if mtype == 0 then
      return nil, "Missing monster type"
    end
    insert(layers, MetaLayer.new("overlay", typef_ov(mtype)))
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
    insert(layers, MetaLayer.new("overlay", typef_ov(types.PENDULUM)))
    insert(layers, MetaLayer.new("scales", lsc, rsc))
    if Parser.bcheck(data.type, types.LINK) then
      return states.link()
    elseif Parser.bcheck(data.type, types.XYZ) then
      return states.rank()
    else
      return states.level()
    end
  end

  function states.link()
    insert(layers, MetaLayer.new("overlay", "lka-base.png"))
    for b in Parser.bits(Parser.get_link_arrows(data)) do
      insert(layers, MetaLayer.new("overlay", linka_ov(b)))
    end
    insert(layers, MetaLayer.new("overlay", "link.png"))
    insert(layers, MetaLayer.new("link_rating", Parser.get_link_rating(data)))
    return states.atk()
  end

  function states.rank()
    local rank = Parser.get_levelrank(data)
    if rank then
      insert(layers, MetaLayer.new("overlay", rank_ov(rank)))
    end
    return states.def()
  end

  function states.level()
    local level = Parser.get_levelrank(data)
    if level then
      insert(layers, MetaLayer.new("overlay", level_ov(level)))
    end
    return states.def()
  end

  function states.def()
    insert(layers, MetaLayer.new("def", data.def))
    return states.atk()
  end

  function states.atk()
    insert(layers, MetaLayer.new("atk", data.atk))
    return states.attribute()
  end

  function states.attribute()
    local att = Parser.match_lsb(data.attribute, GameConst.code.attribute.ALL)
    if att == 0 then
      return nil, "No attribute"
    end
    insert(layers, MetaLayer.new("overlay", attr_ov(data.attribute)))
    return layers
  end

  return states[inital]()
end

function automatons.proxy(data)
  local states, inital = {}, 'baseframe'
  local layers = {}
  local transformer = Transformer.new()

  function states.baseframe()
    local frame = Parser.match_msb(data.type, frame_types)
    if frame == 0 then
      return nil, "Missing card type"
    end
    insert(layers, MetaLayer.new("overlay", typef_ov(frame)))
    if Parser.bcheck(data.type, types.PENDULUM) then
      return states.pendulum()
    else
      return states.art()
    end
  end

  local monster_effect
  function states.pendulum()
    local p_frame_ml = MetaLayer.new("pendulum_frame", data.img,
      typef_ov(types.PENDULUM, "%s%s"))
    local p_scales_ml = MetaLayer.new("pendulum_scales", Parser.get_scales(data))
    p_frame_ml:add_transformation("pendulum")
    p_scales_ml:add_transformation("pendulum")
    insert(layers, p_frame_ml)
    insert(layers, p_scales_ml)
    local me, pe = Parser.get_effects(data)
    monster_effect = me
    transformer:add_value("pendulum", Transformer.pendulum_size(pe))
    if pe then
      local pe_ml = MetaLayer.new("pendulum_effect", pe)
      pe_ml:add_transformation("pendulum")
      insert(layers, pe_ml)
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
    local function p1(self, t) self:set_value(1, self:get_value(1):format(t)) end
    local lka_base_ml = MetaLayer.new("overlay", "lka-basep%s.png")
    lka_base_ml:add_transformation("pendulum", p1)
    insert(layers, lka_base_ml)
    for b in Parser.bits(Parser.get_link_arrows(data)) do
      local lka_ml = MetaLayer.new("overlay", linka_ov(b, "p%s"))
      lka_ml:add_transformation("pendulum", p1)
      insert(layers, lka_ml)
    end
    return states.link_rating()
  end

  function states.art()
    insert(layers, MetaLayer.new("art", data.img))
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
      insert(layers, MetaLayer.new("overlay", st_ov(data.type)))
    else
      local st = Parser.match_lsb(data.type, spellortrap)
      insert(layers, MetaLayer.new("overlay", st_ov(st, "p")))
      insert(layers, MetaLayer.new("overlay", st_ov(st_type)))
    end
    insert(layers, MetaLayer.new("spelltrap_effect", data.desc))
    return states.name()
  end

  function states.link_arrows()
    insert(layers, MetaLayer.new("overlay", "lka-base.png"))
    for b in Parser.bits(Parser.get_link_arrows(data)) do
      insert(layers, MetaLayer.new("overlay", linka_ov(b)))
    end
    return states.link_rating()
  end

  function states.link_rating()
    insert(layers, MetaLayer.new("overlay", "link.png"))
    local link_rating = Parser.get_link_rating(data)
    insert(layers, MetaLayer.new("link_rating", link_rating))
    return states.atk()
  end

  function states.rank()
    local rank = Parser.get_levelrank(data)
    if rank then
      insert(layers, MetaLayer.new("overlay", rank_ov(rank)))
    end
    return states.def()
  end

  function states.level()
    local level = Parser.get_levelrank(data)
    if level then
      insert(layers, MetaLayer.new("overlay", level_ov(level)))
    end
    return states.def()
  end

  function states.def()
    insert(layers, MetaLayer.new("def", data.def))
    return states.atk()
  end

  function states.atk()
    insert(layers, MetaLayer.new("atk", data.atk))
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
    insert(layers, MetaLayer.new("monster_desc", desc))
    return states.monster_text()
  end

  function states.monster_text()
    local me = monster_effect or Parser.get_effects(data)
    if Parser.bcheck(data.type, types.NORMAL)
      and not Parser.bcheck(data.type, types.TOKEN) then
      insert(layers, MetaLayer.new("flavor_text", me))
    else
      insert(layers, MetaLayer.new("monster_effect", me))
    end
    return states.attribute()
  end

  function states.attribute()
    local att = Parser.match_lsb(data.attribute, GameConst.code.attribute.ALL)
    if att == 0 then
      return nil, "No attribute"
    end
    insert(layers, MetaLayer.new("overlay", attr_ov(data.attribute)))
    return states.name()
  end

  function states.name()
    local frame = Parser.match_msb(data.type, frame_types)
    local conf, default_color = unpack(name_colors[frame])
    local color = color_clamp(options[conf])
    insert(layers, MetaLayer.new("name", data.name, color or default_color))
    if Parser.bcheck(data.type, types.TOKEN) then
      return states.finishing()
    else
      return states.serial_code()
    end
  end

  function states.serial_code()
    local darkbg = Parser.bcheck(data.type, types.XYZ)
      and not Parser.bcheck(data.type, types.PENDULUM)
    insert(layers, MetaLayer.new("serial_code", data.id, darkbg and { 255, 255, 255 }))
    return states.finishing()
  end

  function states.finishing()
    local darkbg = Parser.bcheck(data.type, types.XYZ)
      and not Parser.bcheck(data.type, types.PENDULUM)
    insert(layers, MetaLayer.new("copyright", darkbg and { 255, 255, 255 }))
    insert(layers, MetaLayer.new("overlay", "bevel.png"))
    insert(layers, MetaLayer.new("overlay", "holo.png"))
    return layers
  end

  local metalayers, err = states[inital]()
  if not metalayers then
    return nil, err
  end
  transformer:transform(metalayers)
  return metalayers
end

local function check_field(data)
  if options.field and Parser.bcheck(data.type, types.FIELD) then
    return MetaLayer.new("field", data.img)
  end
end

function Decoder.configure(m, opt)
  mode, options = m, opt
end

function Decoder.decode(data)
  local automaton = automatons[mode]
  Logs.assert(automaton, 1, "Unknown mode \"", mode, '"')
  local metalayers, errmsg = automaton(data)
  local field = check_field(data)
  if field then
    insert(metalayers, field)
  end
  return metalayers, errmsg
end

return Decoder
