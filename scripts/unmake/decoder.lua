local Codes = require 'lib.codes'
local Parser = require 'scripts.composer.parser'
local i18n = require 'i18n'
local fun = require 'lib.fun'

local Decoder = {}

local function is_monster(card) return Parser.bcheck(card.type, Codes.const.type.MONSTER) end
local function is_normal(card) return is_monster(card) and Parser.bcheck(card.type, Codes.const.type.NORMAL) end
local function is_pendulum(card) return is_monster(card) and Parser.bcheck(card.type, Codes.const.type.PENDULUM) end
local function is_link(card) return is_monster(card) and Parser.bcheck(card.type, Codes.const.type.LINK) end
local function is_xyz(card) return is_monster(card) and Parser.bcheck(card.type, Codes.const.type.XYZ) end

local generics = {
  number = function(key, monster)
    return function(card)
      local m = monster and is_monster(card) and 0 or nil
      local v = tonumber(card[key])
      return v ~= 0 and v or m
    end
  end,
  number_q = function(key, monster)
    return function(card)
      local m = monster and is_monster(card) and 0 or nil
      local v = tonumber(card[key])
      if v == -2 then return '?' end
      return v ~= 0 and v or m
    end
  end,
  combined = function(key, monster)
    return function(card)
      local v = card[key]
      local m = monster and is_monster(card) and "" or nil
      local s = Codes.uncombine(key, v)
      return #s > 0 and s or m
    end
  end,
  string = function(key)
    return function(card)
      return card[key] or ""
    end
  end
}

local decode = {
  id = generics.number('id'),
  ot = generics.combined('ot'),
  alias = generics.number('alias'),
  name = generics.string('name'),
  type = generics.combined('type'),
  atk = generics.number_q('atk', true),
  race = generics.combined('race', true),
  attribute = generics.combined('attribute', true),
  category = generics.combined('category')
}

function decode.strings(card)
  local s = {}
  local default = nil
  for i = 16, 1, -1 do
    local v = card["str" .. i] and card["str" .. i]:match("^%s*(.-)%s*$") or ""
    if #v > 0 then
      s[i] = v
      default = ""
    else
      s[i] = default
    end
  end
  return #s > 0 and s or nil
end

function decode.effect(card)
  if is_normal(card) then return nil end
  local me, _ = Parser.get_effects(card)
  return me
end

decode['flavor-text'] = function(card)
  if not is_normal(card) then return nil end
  local me, _ = Parser.get_effects(card)
  return me
end

decode['pendulum-effect'] = function(card)
  local _, pe = Parser.get_effects(card)
  return pe
end

decode['pendulum-scale'] = function(card)
  if not is_pendulum(card) then return nil end
  local lsc, rsc = Parser.get_scales(card)
  return lsc == rsc and lsc or { lsc, rsc }
end

function decode.def(card)
  if is_link(card) then return nil end
  local default = is_monster(card) and 0 or nil
  if card.def == -2 then return '?' end
  return card.def ~= 0 and card.def or default
end

function decode.level(card)
  if not is_monster(card) or is_xyz(card) or is_link(card) then return nil end
  return Parser.get_level(card)
end

function decode.rank(card)
  if not is_xyz(card) then return nil end
  return Parser.get_level(card)
end

decode['link-rating'] = function(card)
  if not is_link(card) then return nil end
  return Parser.get_level(card)
end

decode['link-arrows'] = function(card)
  if not is_link(card) then return nil end
  return Codes.uncombine('link', Parser.get_link_arrows(card))
end

function decode.setcode(card)
  return card.setcode and card.setcode > 0 and card.setcode or nil
end

local holo = {'none', 'gold', 'silver'}
function decode.holo(card)
  if card.holo ~= nil then return holo[card.holo + 1] or holo[1] end
end

function decode.setnumber(card)
  if card.setnumber then return tostring(card.setnumber) end
end

function decode.author(card)
  if card.author then return tostring(card.author) end
end

function decode.year(card)
  return tonumber(card.year)
end

function Decoder.decode(data)
  return fun.iter(data):map(function(card)
    return fun.iter(decode):map(function(k, f) return k, f(card) end):tomap()
  end):totable()
end

return Decoder
