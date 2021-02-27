local i18n = require 'i18n'
local fun = require 'lib.fun'

local Codes = {
  const = {
    attribute = {
      EARTH = 0x1,
      WATER = 0x2,
      FIRE = 0x4,
      WIND = 0x8,
      LIGHT = 0x10,
      DARK = 0x20,
      DIVINE = 0x40,
      ALL = 0x7F
    },
    race = {
      WARRIOR = 0x1,
      SPELLCASTER = 0x2,
      FAIRY = 0x4,
      FIEND = 0x8,
      ZOMBIE = 0x10,
      MACHINE = 0x20,
      AQUA = 0x40,
      PYRO = 0x80,
      ROCK = 0x100,
      WINGED_BEAST = 0x200,
      PLANT = 0x400,
      INSECT = 0x800,
      THUNDER = 0x1000,
      DRAGON = 0x2000,
      BEAST = 0x4000,
      BEAST_WARRIOR = 0x8000,
      DINOSAUR = 0x10000,
      FISH = 0x20000,
      SEA_SERPENT = 0x40000,
      REPTILE = 0x80000,
      PSYCHIC = 0x100000,
      DIVINE_BEAST = 0x200000,
      CREATOR_GOD = 0x400000,
      WYRM = 0x800000,
      CYBERSE = 0x1000000,
      ALL = 0x1FFFFFF
    },
    type = {
      MONSTER = 0x1,
      SPELL = 0x2,
      TRAP = 0x4,
      NORMAL = 0x10,
      EFFECT = 0x20,
      FUSION = 0x40,
      RITUAL = 0x80,
      SPIRIT = 0x200,
      UNION = 0x400,
      GEMINI = 0x800,
      TUNER = 0x1000,
      SYNCHRO = 0x2000,
      TOKEN = 0x4000,
      QUICKPLAY = 0x10000,
      CONTINUOUS = 0x20000,
      EQUIP = 0x40000,
      FIELD = 0x80000,
      COUNTER = 0x100000,
      FLIP = 0x200000,
      TOON = 0x400000,
      XYZ = 0x800000,
      PENDULUM = 0x1000000,
      NOMI = 0x2000000,
      LINK = 0x4000000
    },
    link = {
      TOP_LEFT = 0x040,
      TOP = 0x080,
      TOP_RIGHT = 0x100,
      LEFT = 0x008,
      RIGHT = 0x020,
      BOTTOM_LEFT = 0x001,
      BOTTOM = 0x002,
      BOTTOM_RIGHT = 0x004,
      ALL = 0x1EF
    },
    ot = {
      OCG = 0x1,
      TCG = 0x2,
      ANIME = 0x4,
      ILLEGAL = 0x8,
      VIDEOGAME = 0x10,
      VG = 0x10,
      CUSTOM = 0x20,
      SPEED = 0x40,
      PRE_RELEASE = 0x100,
      RUSH = 0x200,
      LEGEND = 0x400,
      HIDDEN = 0x1000
    },
    category = {
      DESTROY_MONSTER = 0x1,
      DESTROY_ST = 0x2,
      DESTROY_DECK = 0x4,
      DESTROY_HAND = 0x8,
      SEND_TO_GY = 0x10,
      SEND_TO_HAND = 0x20,
      SEND_TO_DECK = 0x40,
      BANISH = 0x80,
      DRAW = 0x100,
      SEARCH = 0x200,
      CHANGE_ATK_DEF = 0x400,
      CHANGE_LEVEL_RANK = 0x800,
      POSITION = 0x1000,
      PIERCING = 0x2000,
      DIRECT_ATTACK = 0x4000,
      MULTI_ATTACK = 0x8000,
      NEGATE_ACTIVATION = 0x10000,
      NEGATE_EFFECT = 0x20000,
      DAMAGE_LP = 0x40000,
      RECOVER_LP = 0x80000,
      SPECIAL_SUMMON = 0x100000,
      NON_EFFECT_RELATED = 0x200000,
      TOKEN_RELATED = 0x400000,
      FUSION_RELATED = 0x800000,
      RITUAL_RELATED = 0x1000000,
      SYNCHRO_RELATED = 0x2000000,
      XYZ_RELATED = 0x4000000,
      LINK_RELATED = 0x8000000,
      COUNTER_RELATED = 0x10000000,
      GAMBLE = 0x20000000,
      CONTROL = 0x40000000,
      MOVE_ZONES = 0x80000000
    }
  }
}

local normalize = function(s) return s:gsub('[-_]', ''):lower() end

local rev_index = fun.iter(Codes.const):map(function(k, group)
  return k, fun.iter(group):map(function(k, v) return v, k end):tomap()
end):tomap()

local norm_index = fun.iter(Codes.const):map(function(k, group)
  return k, fun.iter(group):map(function(k, v) return normalize(k), v end):tomap()
end):tomap()

--- @alias CodeGroupKey "'attribute'"|"'category'"|"'link'"|"'ot'"|"'race'"|"'type'"

--- Returns internationalized string from a `code`. Additional sub keys
--- can be specified after `code` with `sub`.
--- E.g. if locale is `en`, `Codes.i18n('type', 0x10)` -> `'Normal'`,
--- `Codes.i18n('type', 0x2, 'attribute'')` -> `'SPELL'`
--- @param group_key CodeGroupKey
--- @param code number
--- @param sub? string
--- @return string|nil
function Codes.i18n(group_key, code, sub)
  local group = rev_index[group_key]
  if not group then return end
  local partial_key = group[code]
  if not partial_key then return end
  sub = sub and '.' .. sub or ''
  return i18n('codes.' .. group_key .. '.' .. partial_key .. sub)
end

--- Combines keys from a group into a single value, doing a
--- bitwise or among them.
--- @param group_key CodeGroupKey
--- @param keys string
--- @return number
function Codes.combine(group_key, keys)
  local group = norm_index[group_key]
  if not group then return 0 end
  return fun.iter(keys:gmatch '[%a-_]+'):map(normalize):reduce(0, function(c, key)
    return bit.bor(c, group[key] or 0)
  end)
end

return Codes
