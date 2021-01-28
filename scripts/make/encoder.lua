local Codes = require 'lib.codes'
local i18n = require 'lib.i18n'
local fun = require 'lib.fun'

local Encoder = {}

local expansion_locale = 'en'

local generics = {
  number = function(key)
    return function(card) return tonumber(card[key]) or 0 end
  end,
  number_q = function(key)
    return function(card)
      return card[key] == '?' and -2 or tonumber(card[key]) or 0
    end
  end,
  combined = function(key)
    return function(card)
      local v = card[key]
      local t = type(v)
      if t == 'number' then
        return v
      elseif t == 'string' then
        return Codes.combine(key, v)
      else
        return 0
      end
    end
  end
}

local encode = fun {
  id = generics.number('id'),
  ot = generics.combined('ot'),
  alias = generics.number('alias'),
  type = generics.combined('type'),
  atk = generics.number_q('atk'),
  race = generics.combined('race'),
  attribute = generics.combined('attribute'),
  category = generics.combined('category')
}

for i = 1, 16 do
  encode['str' .. i] = function(card)
    local strings = card.strings
    return strings and strings[i] or ''
  end
end

function encode.name(card)
  return card.name or ''
end

local PEND_TEMPLATE = '[ %s ]\n%%s\n-------------------\n[ %%s ]\n%%s'
function encode.desc(card)
  local p_effect = card['pendulum-effect']
  local effect, flavor_t = card.effect, card['flavor-text']
  local text, tag = '', ''
  local general_locale = i18n.getLocale()
  i18n.setLocale(expansion_locale)
  local p_text = PEND_TEMPLATE:format(i18n 'make.encoder.pendulum_effect')
  if effect then
    text, tag = effect, i18n 'make.encoder.monster_effect'
  elseif flavor_t then
    text, tag = flavor_t, i18n 'make.encoder.flavor_text'
  end
  i18n.setLocale(general_locale)
  return p_effect and p_text:format(p_effect, tag, text) or text
end

function encode.setcode(card, sets)
  if tonumber(card.setcode) then return tonumber(card.setcode) end
  local setcode = 0
  local cardset = type(card.set) == 'string' and card.set or ''
  for setid in cardset:gmatch('[%w-_]+') do
    local set = sets[setid]
    local code = tonumber(set and set.code)
    if code then setcode = setcode * 0x10000 + set.code % 0x10000 end
  end
  return setcode
end

local generic_def = generics.number_q('def')
function encode.def(card)
  local arrows = card['link-arrows']
  if type(arrows) == 'string' then
    return Codes.combine('link', arrows)
  else
    return generic_def(card)
  end
end

function encode.level(card)
  local scales = card['pendulum-scale']
  local level = tonumber(card['link-rating'] or card.rank or card.level) or 0
  local lsc, rsc = 0, 0
  if tonumber(scales) then
    scales = tonumber(scales)
    lsc, rsc = scales, scales
  elseif type(scales) == 'table' then
    lsc = tonumber(scales[1]) or 0
    rsc = tonumber(scales[2]) or 0
  end
  return bit.bor(bit.lshift(lsc, 24), bit.lshift(rsc, 16), level)
end

function encode.holo(card)
  if card.holo ~= nil then return card.holo and 1 or 0 end
end

function encode.setnumber(card)
  if card.setnumber then return tostring(card.setnumber) end
end

function encode.author(card)
  if card.author then return tostring(card.author) end
end

function encode.year(card)
  return tonumber(card.year)
end

function Encoder.set_locale(locale)
  expansion_locale = locale
end

--- Encodes card data from .toml into .cdb entries
--- @param cards table
--- @param sets table
--- @return Fun
function Encoder.encode(cards, sets)
  return fun(cards):vals():map(function(card)
    return encode:map(function(e) return e(card, sets) end)
  end)
end

return Encoder
