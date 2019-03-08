--- Defines constant values for the database
local Const = {}

Const.attributes = { EARTH = 0x1, WATER = 0x2, FIRE = 0x4, WIND = 0x8,
    LIGHT = 0x10, DARK = 0x20, DIVINE = 0x40 }

Const.races = {
    Warrior = 0x1, Spellcaster = 0x2, Fairy = 0x4, Fiend = 0x8, Zombie = 0x10,
    Machine = 0x20, Aqua = 0x40, Pyro = 0x80, Rock = 0x100, WingedBeast = 0x200,
    Plant = 0x400, Insect = 0x800, Thunder = 0x1000, Dragon = 0x2000, Beast = 0x4000,
    BeastWarrior = 0x8000, Dinosaur = 0x10000, Fish = 0x20000, SeaSerpent = 0x40000,
    Reptile = 0x80000, Psychic = 0x100000, DivineBeast = 0x200000, CreatorGod = 0x400000,
    Wyrm = 0x800000, Cyberse = 0x1000000
}

Const.types = {
    Monster = 0x1, Spell = 0x2, Trap = 0x4, Normal = 0x10, Effect = 0x20, Fusion = 0x40,
    Ritual = 0x80, Spirit = 0x200, Union = 0x400, Gemini = 0x800, Tuner = 0x1000,
    Synchro = 0x2000, Token = 0x4000, QuickPlay = 0x10000, Continuous = 0x20000,
    Equip = 0x40000, Field = 0x80000, Counter = 0x100000, Flip = 0x200000,
    Toon = 0x400000, Xyz = 0x800000, Pendulum = 0x1000000, Nomi = 0x2000000,
    Link = 0x4000000,
}

return Const
