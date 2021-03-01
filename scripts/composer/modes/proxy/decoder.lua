local Shapes = require 'scripts.composer.modes.proxy.shapes'
local Decoder = require 'scripts.composer.decoder'
local Layer = require 'scripts.composer.layer'
local Parser = require 'scripts.composer.parser'
local Codes = require 'lib.codes'
local fun = require 'lib.fun'

local types = Codes.const.type
local agtypes = {
  SUMMON = types.FUSION + types.LINK + types.RITUAL + types.SYNCHRO + types.XYZ,
  SPELLTRAP = types.SPELL + types.TRAP,
  ST_TYPES = types.CONTINUOUS + types.COUNTER + types.EQUIP + types.FIELD
    + types.QUICKPLAY + types.RITUAL,
  MONSTER = types.NORMAL + types.EFFECT + types.FUSION + types.RITUAL + types.SYNCHRO
    + types.TOKEN + types.XYZ + types.LINK
}
agtypes.FRAMES = agtypes.SPELLTRAP + agtypes.MONSTER

local BLACK, WHITE = '#000000', '#ffffff'
local default_colors = {
  [types.NORMAL] = {'color-normal', BLACK},
  [types.EFFECT] = {'color-effect', BLACK},
  [types.FUSION] = {'color-fusion', WHITE},
  [types.RITUAL] = {'color-ritual', WHITE},
  [types.SYNCHRO] = {'color-synchro', BLACK},
  [types.TOKEN] = {'color-token', BLACK},
  [types.XYZ] = {'color-xyz', WHITE},
  [types.LINK] = {'color-link', WHITE},
  [types.SPELL] = {'color-spell', WHITE},
  [types.TRAP] = {'color-trap', WHITE}
}

local function get_race(card)
  local race = Parser.match_lsb(card.race, Codes.const.race.ALL)
  return Codes.i18n('race', race)
end

local function get_sumtype(card)
  local sumtype = Parser.match_lsb(card.type, agtypes.SUMMON)
  return Codes.i18n('type', sumtype)
end

local function get_desc_label(card, t)
  return Parser.bcheck(card.type, t) and Codes.i18n('type', t) or nil
end

return Decoder('proxy', Shapes.BASE, 'frame', {
  frame = function(card)
    local is_st = Parser.bcheck(card.type, agtypes.SPELLTRAP)
    local frame_types = is_st and agtypes.SPELLTRAP or agtypes.MONSTER
    local frame = Parser.match_msb(card.type, frame_types)
    if frame == 0 then return nil, 'compose.modes.proxy.no_card_type' end
    local layer = Layer(Shapes.OVERLAY, 'type', frame)
    if Parser.bcheck(card.type, types.PENDULUM) then
      return 'pendulum', layer
    else
      return 'art', layer
    end
  end,
  pendulum = function(card, opt)
    local me, pe = Parser.get_effects(card)
    local lsc, rsc = Parser.get_scales(card)
    local psize = pe and #pe > 176 and 'm' or 's'
    card.desc = me
    local frame = Layer(Shapes.PEND_FRAME, card.art, psize, opt.artsize)
    local scale = Layer(Shapes.PEND_SCALE, lsc, rsc, psize)
    local effect = pe and Layer(Shapes.PEND_EFFECT, pe, psize) or nil
    if Parser.bcheck(card.type, types.LINK) then
      local bits = Parser.bits(Parser.get_link_arrows(card))
      local arrows = Layer(Shapes.LINK_ARROWS, bits, psize)
      return 'link_rating', frame, scale, arrows, effect
    elseif Parser.bcheck(card.type, types.XYZ) then
      return 'rank', frame, scale, effect
    else
      return 'level', frame, scale, effect
    end
  end,
  art = function(card)
    local layer = Layer(Shapes.ART, card.art)
    if Parser.bcheck(card.type, agtypes.SPELLTRAP) then
      return 'spelltrap', layer
    elseif Parser.bcheck(card.type, types.LINK) then
      return 'link_arrows', layer
    elseif Parser.bcheck(card.type, types.XYZ) then
      return 'rank', layer
    else
      return 'level', layer
    end
  end,
  link_arrows = function(card)
    local bits = Parser.bits(Parser.get_link_arrows(card))
    local arrows = Layer(Shapes.LINK_ARROWS, bits)
    return 'link_rating', arrows
  end,
  link_rating = function(card)
    return 'atk', Layer(Shapes.LINK_RATING, Parser.get_level(card))
  end,
  spelltrap = function(card)
    local st = Parser.match_lsb(card.type, agtypes.SPELLTRAP)
    local st_type = Parser.match_lsb(card.type, agtypes.ST_TYPES)
    local effect = Layer(Shapes.ST_EFFECT, card.desc)
    local label = Layer(Shapes.ST_LABEL, st, st_type)
    local icon = Layer(Shapes.ATTRIBUTE, st, true)
    return 'name', effect, label, icon
  end,
  level = function(card)
    local lvl = Parser.get_level(card)
    local layer = lvl > 0 and lvl <= 12 and Layer(Shapes.OVERLAY, 'l', lvl) or nil
    return 'def', layer
  end,
  rank = function(card)
    local r = Parser.get_level(card)
    local layer = r > 0 and r <= 13 and Layer(Shapes.OVERLAY, 'r', r) or nil
    return 'def', layer
  end,
  def = function(card) return 'atk', Layer(Shapes.DEF, card.def) end,
  atk = function(card) return 'monster_desc', Layer(Shapes.ATK, card.atk) end,
  monster_desc = function(card)
    local is_token = Parser.bcheck(card.type, types.TOKEN)
    local normal = not is_token and types.NORMAL or nil
    local prefix = fun.iter(pairs {get_race(card), get_sumtype(card)}):map(function(_, v) return v end)
    local typedesc = fun.iter {
      types.PENDULUM, types.FLIP, types.GEMINI, types.GEMINI, types.SPIRIT,
      types.TOON, types.UNION, types.TUNER, types.EFFECT, normal
    }:map(function(t) return get_desc_label(card, t) end):filter(function(v) return v end)
    local desc = fun.chain(prefix, typedesc):totable()
    return 'monster_text', Layer(Shapes.MONSTER_DESC, desc)
  end,
  monster_text = function(card)
    local layer = Parser.bcheck(card.type, types.NORMAL)
      and not Parser.bcheck(card.type, types.TOKEN)
      and Layer(Shapes.FLAVOR_TEXT, card.desc)
      or Layer(Shapes.MONSTER_EFFECT, card.desc)
    return 'attribute', layer
  end,
  attribute = function(card)
    local att = Parser.match_lsb(card.attribute, Codes.const.attribute.ALL)
    local layer = att > 0 and Layer(Shapes.ATTRIBUTE, att)
    return 'name', layer or nil
  end,
  name = function(card, opts)
    local frame = Parser.match_msb(card.type, agtypes.FRAMES)
    local conf, default_color = unpack(default_colors[frame])
    local color = opts[conf] or default_color
    local layer = Layer(Shapes.NAME, card.name, color)
    if Parser.bcheck(card.type, types.TOKEN) then
      return 'forbidden', layer
    else
      return 'serial_code', layer
    end
  end,
  forbidden = function()
    return 'setnumber', Layer(Shapes.FORBIDDEN)
  end,
  serial_code = function(card)
    local is_darkbg = Parser.bcheck(card.type, types.XYZ)
      and not Parser.bcheck(card.type, types.PENDULUM)
    local color = is_darkbg and WHITE or BLACK
    return 'setnumber', Layer(Shapes.SERIAL_CODE, card.id, color)
  end,
  setnumber = function(card)
    local is_darkbg = Parser.bcheck(card.type, types.XYZ)
      and not Parser.bcheck(card.type, types.PENDULUM)
    local color = is_darkbg and WHITE or BLACK
    local mtype = Parser.match_lsb(card.type, types.PENDULUM + types.LINK)
    local set = card.setnumber and Layer(Shapes.SETNUMBER, card.setnumber, mtype, color)
    return 'seal', set or nil
  end,
  seal = function(card, opts)
    local is_darkbg = Parser.bcheck(card.type, types.XYZ)
      and not Parser.bcheck(card.type, types.PENDULUM)
    local pos = Parser.bcheck(card.type, types.TOKEN) and 'high' or 'low'
    local color = is_darkbg and WHITE or BLACK
    local year = card.year or opts.year
    local author = card.author or opts.author
    local edition = Layer(Shapes.EDITION, pos, color)
    local bevel = Layer(Shapes.OVERLAY, 'bevel')
    local copyright = Layer(Shapes.COPYRIGHT, color, year, author)
    local holo = card.holo ~= 0 and opts.holo ~= 0
      and Layer(Shapes.OVERLAY, 'holo') or nil
    return nil, edition, bevel, copyright, holo
  end
})
