local layersPath = "res/layers/"
local layers = {
    anime = {
        attributes = function (att) return string.format("att%d.png", att) end,
        frame = function (type) return string.format("type%d.png", type) end,
        level = function (lvl) return string.format("l%d.png", lvl) end,
        link = function (lka) return string.format("lka%d.png", lka) end,
        rank = function (rk) return string.format("r%d.png", rk) end,
        linkBase = "lka-base.png",
    },
    proxy = {

    }
}

--- Decodes information from the database and transforms it into more usable
--  information to the assembler module
local Decoder = {}

local function decode(_, mode, data, ...)
    print(...)
end

return setmetatable(Decoder, { __call = decode })
