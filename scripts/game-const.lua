

local GameConst = {}

GameConst.code = {
  att = {
    EARTH = 0x1, WATER = 0x2, FIRE = 0x4, WIND = 0x8,
    LIGHT = 0x10, DARK = 0x20, DIVINE = 0x40
  },
  race = {
    WARRIOR = 0x1, SPELLCASTER = 0x2, FAIRY = 0x4, FIEND = 0x8, ZOMBIE = 0x10,
    MACHINE = 0x20, AQUA = 0x40, PYRO = 0x80, ROCK = 0x100, WINGED_BEAST = 0x200,
    PLANT = 0x400, INSECT = 0x800, THUNDER = 0x1000, DRAGON = 0x2000, BEAST = 0x4000,
    BEAST_WARRIOR = 0x8000, DINOSAUR = 0x10000, FISH = 0x20000, SEA_SERPENT = 0x40000,
    REPTILE = 0x80000, PSYCHIC = 0x100000, DIVINE_BEAST = 0x200000,
    CREATOR_GOD = 0x400000, WYRM = 0x800000, CYBERSE = 0x1000000
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
  }
}

GameConst.name = {
  race = {
    WARRIOR = "Warrior", SPELLCASTER = "Spellcaster", FAIRY = "Fairy", FIEND = "Fiend",
    ZOMBIE = "Zombie", MACHINE = "Machine", AQUA = "Aqua", PYRO = "Pyro", ROCK = "Rock",
    WINGED_BEAST = "Winged Beast", PLANT = "Plant", INSECT = "Insect",
    THUNDER = "Thunder", DRAGON = "Dragon", BEAST = "Beast",
    BEAST_WARRIOR = "Beast-Warrior", DINOSAUR = "Dinosaur", FISH = "Fish",
    SEA_SERPENT = "Sea Serpent", REPTILE = "Reptile", PSYCHIC = "Psychic",
    DIVINE_BEAST = "Divine-Beast", CREATOR_GOD = "Creator God", WYRM = "Wyrm",
    CYBERSE = "Cyberse"
  },
  type = {
    MONSTER = "Monster", SPELL = "Spell", TRAP = "Trap", NORMAL = "Normal",
    EFFECT = "Effect", FUSION = "Fusion", RITUAL = "Ritual", SPIRIT = "Spirit",
    UNION = "Union", GEMINI = "Gemini", TUNER = "Tuner", SYNCHRO = "Synchro",
    TOKEN = "Token", FLIP = "Flip", TOON = "Toon", XYZ = "Xyz", PENDULUM = "Pendulum",
    LINK = "Link"
  }
}

return GameConst
