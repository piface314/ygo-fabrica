local Shapes = require 'scripts.composer.modes.anime.shapes'
local Decoder = require 'scripts.composer.decoder'
local Layer = require 'scripts.composer.layer'
local Parser = require 'scripts.composer.parser'
local Codes = require 'lib.codes'

local types = Codes.const.type
local agtypes = {
  SPELLTRAP = types.SPELL + types.TRAP,
  MONSTER = types.NORMAL + types.EFFECT + types.FUSION + types.RITUAL +
    types.SYNCHRO + types.TOKEN + types.XYZ + types.LINK
}

return Decoder('anime', Shapes.BASE, 'art', {
  art = function(card)
    local layer = Layer(Shapes.ART, card.art)
    if Parser.bcheck(card.type, agtypes.SPELLTRAP) then
      return 'spelltrap', layer
    elseif Parser.bcheck(card.type, types.MONSTER) then
      return 'monster', layer
    else
      return nil, 'compose.modes.anime.no_card_type'
    end
  end,
  spelltrap = function(card)
    local st = Parser.match_lsb(card.type, agtypes.SPELLTRAP)
    local frame = Layer(Shapes.OVERLAY, 'type', st)
    local icon = Layer(Shapes.ST_ICON, st)
    return nil, frame, icon
  end,
  monster = function(card)
    local mt = Parser.match_msb(card.type, agtypes.MONSTER)
    if mt == 0 then return nil, 'compose.modes.anime.no_card_type' end
    local layer = Layer(Shapes.OVERLAY, 'type', mt)
    if Parser.bcheck(card.type, types.PENDULUM) then
      return 'pendulum', layer
    elseif Parser.bcheck(card.type, types.LINK) then
      return 'link', layer
    elseif Parser.bcheck(card.type, types.XYZ) then
      return 'rank', layer
    else
      return 'level', layer
    end
  end,
  pendulum = function(card)
    local pendulum_frame = Layer(Shapes.OVERLAY, 'type', types.PENDULUM)
    local scales = Layer(Shapes.SCALES, Parser.get_scales(card))
    if Parser.bcheck(card.type, types.LINK) then
      return 'link', pendulum_frame, scales
    elseif Parser.bcheck(card.type, types.XYZ) then
      return 'rank', pendulum_frame, scales
    else
      return 'level', pendulum_frame, scales
    end
  end,
  link = function(card)
    local bits = Parser.bits(Parser.get_link_arrows(card))
    local arrows = Layer(Shapes.LINK_ARROWS, bits)
    local rating = Layer(Shapes.LINK_RATING, Parser.get_level(card))
    return 'atk', arrows, rating
  end,
  rank = function(card)
    local r = Parser.get_level(card)
    local layer = r > 0 and r <= 13 and Layer(Shapes.OVERLAY, 'r', r)
    return 'def', layer or nil
  end,
  level = function(card)
    local lvl = Parser.get_level(card)
    local layer = lvl > 0 and lvl <= 12 and Layer(Shapes.OVERLAY, 'l', lvl)
    return 'def', layer or nil
  end,
  def = function(card)
    return 'atk', Layer(Shapes.DEF, card.def)
  end,
  atk = function(card)
    return 'attribute', Layer(Shapes.ATK, card.atk)
  end,
  attribute = function(card)
    local att = Parser.match_lsb(card.attribute, Codes.const.attribute.ALL)
    if att > 0 then
      return nil, Layer(Shapes.ATT, att)
    end
  end
})
