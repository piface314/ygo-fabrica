local Codes = require 'scripts.make.codes'


local Encoder = {}

local insert = table.insert

local generics = {
  number = function(key)
      return function(entry, card)
        entry[key] = tonumber(card[key]) or 0
      end
    end,
  number_q = function(key)
      return function(entry, card)
        if card[key] == "?" then
          entry[key] = -2
        else
          entry[key] = tonumber(card[key]) or 0
        end
      end
    end,
  combined = function(key)
      return function(entry, card)
        local v = card[key]
        local t = type(v)
        if t == 'number' then
          entry[key] = v
        elseif t == 'string' then
          entry[key] = Codes.combine(key, v)
        else
          entry[key] = 0
        end
      end
    end
}

local encode = {
  id = generics.number('id'),
  ot = generics.combined('ot'),
  alias = generics.number('alias'),
  type = generics.combined('type'),
  atk = generics.number_q('atk'),
  race = generics.combined('race'),
  attribute = generics.combined('attribute'),
  category = generics.combined('category'),
}

function encode.name(entry, card)
  entry.name = card.name or ""
end

local p_text = "[ Pendulum Effect ]\n%s\n-------------------\n[ %s ]\n%s"
function encode.desc(entry, card)
  local p_effect = card['pendulum-effect']
  local effect, flavor_t = card.effect, card['flavor-text']
  local text, tag = "", ""
  if effect then
    text, tag = effect, "Monster Effect"
  elseif flavor_t then
    text, tag = flavor_t, "Flavor Text"
  end
  entry.desc = p_effect and p_text:format(p_effect, tag, text) or text
end

function encode.strings(entry, card)
  local strings = card.strings or {}
  for i = 1, 16 do
    entry['str' .. i] = strings[i] or ""
  end
end

function encode.setcode(entry, card, sets)
  if tonumber(card.setcode) then
    entry.setcode = tonumber(card.setcode)
    return
  end
  local setcode = 0
  local cardset = type(card.set) == 'string' and card.set or ""
  for setid in cardset:gmatch("[%w-_]+") do
    local set = sets[setid]
    local code = tonumber(set and set.code or "")
    if code then
      setcode = setcode * 0x10000 + set.code % 0x10000
    end
  end
  entry.setcode = setcode
end

local generic_def = generics.number_q('def')
function encode.def(entry, card)
  local arrows = card['link-arrows']
  if type(arrows) == 'string' then
    entry.def = Codes.combine('link', arrows)
  else
    generic_def(entry, card)
  end
end

function encode.level(entry, card)
  local scales = card['pendulum-scale']
  local level = tonumber(card['link-rating'] or card.rank or card.level or "") or 0
  local lsc, rsc = 0, 0
  if tonumber(scales) then
    scales = tonumber(scales)
    lsc, rsc = scales, scales
  elseif type(scales) == 'table' then
    lsc = tonumber(scales[1]) or 0
    rsc = tonumber(scales[2]) or 0
  end
  entry.level = bit.bor(bit.lshift(lsc, 24), bit.lshift(rsc, 16), level)
end

function Encoder.encode(sets, cards)
  local entries = {}
  for _, card in pairs(cards) do
    local entry = {}
    for _, f in pairs(encode) do
      f(entry, card, sets)
    end
    insert(entries, entry)
  end
  return entries
end

return Encoder
