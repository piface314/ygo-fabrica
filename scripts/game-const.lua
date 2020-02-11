

local GameConst = {}

GameConst.code = {
  attribute = {
    EARTH = 0x1, WATER = 0x2, FIRE = 0x4, WIND = 0x8,
    LIGHT = 0x10, DARK = 0x20, DIVINE = 0x40, ALL = 0x7F
  },
  race = {
    WARRIOR = 0x1, SPELLCASTER = 0x2, FAIRY = 0x4, FIEND = 0x8, ZOMBIE = 0x10,
    MACHINE = 0x20, AQUA = 0x40, PYRO = 0x80, ROCK = 0x100, WINGED_BEAST = 0x200,
    PLANT = 0x400, INSECT = 0x800, THUNDER = 0x1000, DRAGON = 0x2000, BEAST = 0x4000,
    BEAST_WARRIOR = 0x8000, DINOSAUR = 0x10000, FISH = 0x20000, SEA_SERPENT = 0x40000,
    REPTILE = 0x80000, PSYCHIC = 0x100000, DIVINE_BEAST = 0x200000,
    CREATOR_GOD = 0x400000, WYRM = 0x800000, CYBERSE = 0x1000000,
    ALL = 0x1FFFFFF
  },
  type = {
    MONSTER = 0x1, SPELL = 0x2, TRAP = 0x4, NORMAL = 0x10, EFFECT = 0x20, FUSION = 0x40,
    RITUAL = 0x80, SPIRIT = 0x200, UNION = 0x400, GEMINI = 0x800, TUNER = 0x1000,
    SYNCHRO = 0x2000, TOKEN = 0x4000, QUICKPLAY = 0x10000, CONTINUOUS = 0x20000,
    EQUIP = 0x40000, FIELD = 0x80000, COUNTER = 0x100000, FLIP = 0x200000,
    TOON = 0x400000, XYZ = 0x800000, PENDULUM = 0x1000000, NOMI = 0x2000000,
    LINK = 0x4000000
  },
  link = {
    TOP_LEFT    = 0x040, TOP    = 0x080, TOP_RIGHT    = 0x100,
    LEFT        = 0x008,                 RIGHT        = 0x020,
    BOTTOM_LEFT = 0x001, BOTTOM = 0x002, BOTTOM_RIGHT = 0x004,
    ALL = 0x1EF
  },
  ot = { OCG = 0x1, TCG = 0x2, ANIME = 0x4, ILLEGAL = 0x8,
    VIDEOGAME = 0x10, VG = 0x10, CUSTOM = 0x20 },
  category = {
    DESTROY_ST = 0x1, DESTROY_MONSTER = 0x2, BANISH = 0x4, GRAVEYARD = 0x8,
    TO_HAND = 0x10, TO_DECK = 0x20, DESTROY_HAND = 0x40, DESTROY_DECK = 0x80,
    DRAW = 0x100, SEARCH = 0x200, RECOVERY = 0x400, POSITION = 0x800,
    CONTROL = 0x1000, CHANGE_ATKDEF = 0x2000, PIERCING = 0x4000, REPEAT_ATTACK = 0x8000,
    LIMIT_ATTACK = 0x10000, DIRECT_ATTACK = 0x20000, SP_SUMMON = 0x40000, TOKEN = 0x80000,
    TYPE = 0x100000, PROPERTY = 0x200000, DAMAGE = 0x400000, GAIN_LP = 0x800000,
    DESTROY = 0x1000000, TARGET = 0x2000000, COUNTER = 0x4000000, GAMBLE = 0x8000000,
    FUSION = 0x10000000, TUNER = 0x20000000, XYZ = 0x40000000, NEGATE = 0x80000000
  }
}

local races = GameConst.code.race
local types = GameConst.code.type
GameConst.name = {
  race = {
    [races.WARRIOR] = "Warrior", [races.SPELLCASTER] = "Spellcaster",
    [races.FAIRY] = "Fairy", [races.FIEND] = "Fiend", [races.ZOMBIE] = "Zombie",
    [races.MACHINE] = "Machine", [races.AQUA] = "Aqua", [races.PYRO] = "Pyro",
    [races.ROCK] = "Rock", [races.WINGED_BEAST] = "Winged Beast",
    [races.PLANT] = "Plant", [races.INSECT] = "Insect", [races.THUNDER] = "Thunder",
    [races.DRAGON] = "Dragon", [races.BEAST] = "Beast",
    [races.BEAST_WARRIOR] = "Beast-Warrior", [races.DINOSAUR] = "Dinosaur",
    [races.FISH] = "Fish", [races.SEA_SERPENT] = "Sea Serpent",
    [races.REPTILE] = "Reptile", [races.PSYCHIC] = "Psychic",
    [races.DIVINE_BEAST] = "Divine-Beast", [races.CREATOR_GOD] = "Creator God",
    [races.WYRM] = "Wyrm", [races.CYBERSE] = "Cyberse"
  },
  type = {
    [types.MONSTER] = "Monster", [types.SPELL] = "Spell", [types.TRAP] = "Trap",
    [types.NORMAL] = "Normal", [types.EFFECT] = "Effect", [types.FUSION] = "Fusion",
    [types.RITUAL] = "Ritual", [types.SPIRIT] = "Spirit", [types.UNION] = "Union",
    [types.GEMINI] = "Gemini", [types.TUNER] = "Tuner", [types.SYNCHRO] = "Synchro",
    [types.TOKEN] = "Token", [types.FLIP] = "Flip", [types.TOON] = "Toon",
    [types.XYZ] = "Xyz", [types.PENDULUM] = "Pendulum", [types.LINK] = "Link"
  }
}

return GameConst
