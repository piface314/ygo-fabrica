--- Bitwise operations
local bit = require "bit"
--- Constants
local Const = require "src.const"

--- Name generators for each layer
local layers = {
    anime = {
        attributes = function (att) return string.format("att%d.png", att) end,
        frame = function (t) return string.format("type%d.png", t) end,
        level = function (lvl) return string.format("l%d.png", lvl) end,
        link = function (lkm) return string.format("lkm%d.png", lkm) end,
        rank = function (rk) return string.format("r%d.png", rk) end,
        linkBase = "lkm-base.png",
    },
    proxy = {

    }
}

--- Generates the full layer path name
--  @param mode Generator mode (either `anime` or `proxy`)
--  @param layer A string indicating a layer
--  @return Full layer path name
local function getLayerPath(mode, layer)
    return "res/layers/" .. mode .. "/" .. layer
end

--- Checks if a 32-bit number contains a certain bit
--  @param a 32-bit number to be checked
--  @param b 32-bit number to be checked
--  @return If `a` contains `b`
local function bcheck(a, b)
    return bit.band(a, b) ~= 0
end

--- Detects what is the attribute code for the card
--  @param data Card data
--  @return Attribute code for the card
local function getAttribute(data)
    local att = data.attribute
    local isOneHot = att ~= 0 and bit.band(att, att - 1) == 0
    return isOneHot and att or nil
end

--- Detects what is the frame code for the card
--  @param data Card data
--  @return Frame code(s) for the card
local function getFrame(data)
    local t = data.type
    if not bcheck(t, Const.types.Monster) then
        if bcheck(t, Const.types.Spell) then
            return Const.types.Spell
        elseif bcheck(t, Const.types.Trap) then
            return Const.types.Trap
        end
    else
        local mtype
        if bcheck(t, Const.types.Fusion) then
            mtype = Const.types.Fusion
        elseif bcheck(t, Const.types.Link) then
            mtype = Const.types.Link
        elseif bcheck(t, Const.types.Ritual) then
            mtype = Const.types.Ritual
        elseif bcheck(t, Const.types.Synchro) then
            mtype = Const.types.Synchro
        elseif bcheck(t, Const.types.Token) then
            mtype = Const.types.Token
        elseif bcheck(t, Const.types.Xyz) then
            mtype = Const.types.Xyz
        elseif bcheck(t, Const.types.Normal) then
            mtype = Const.types.Normal
        elseif bcheck(t, Const.types.Effect) then
            mtype = Const.types.Effect
        else
            return nil
        end
        return mtype, bcheck(t, Const.types.Pendulum) and Const.types.Pendulum or nil
    end
end

--- Calculates Level/Rank/Link Rating and Pendulum Scales
--  @param data Card data
--  @return Card Level/Rank/Link Rating, Left and Right Pendulum Scales
local function getLevel(data)
    local lv = data.level
    return bit.band(lv, 0xFFFF),
        bit.band(lv, 0xFF000000) / 0x1000000,
        bit.band(lv, 0xFF0000) / 0x10000
end

--- Detects which Link Markers are used
--  @param data Card data
--  @return A table with each Link Marker code
local function getLinkMarkers(data)
    local lm = 1
    local lms = {}
    local lmval = data.def
    for n = 0, 8 do
        if lmval % 2 == 1 then table.insert(lms, lm) end
        lm = lm * 2
        lmval = bit.rshift(lmval, 1)
    end
    return lms
end

--- Decodes information from the database and transforms it into more usable
--  information to the assembler module
local Decoder = {}

--- Decodes card data according to the anime format
--  @param data Card data
--  @return An array of layers, that are either labels or paths to resources, in the order they should be placed
function Decoder.anime(data)
    local mode = 'anime'
    local att = getAttribute(data)
    local f, p = getFrame(data)
    local lvl, lsc, rsc = getLevel(data)

    local decoded = { "@img" }
    table.insert(decoded, getLayerPath(mode, layers.anime.frame(f)))
    if bcheck(data.type, Const.types.Monster) then
        if p then
            table.insert(decoded, getLayerPath(mode, layers.anime.frame(p)))
            table.insert(decoded, ("@scales %d/%d"):format(lsc, rsc))
        end
        table.insert(decoded, getLayerPath(mode, layers.anime.attributes(att)))
        table.insert(decoded, "@atk")
        if f == Const.types.Link then
            table.insert(decoded, "@link " .. lvl)
            table.insert(decoded, getLayerPath(mode, layers.anime.linkBase))
            for _, lm in pairs(getLinkMarkers(data)) do
                table.insert(decoded, getLayerPath(mode, layers.anime.link(lm)))
            end
        else
            table.insert(decoded, "@def")
            table.insert(decoded, f == Const.types.Xyz
                and getLayerPath(mode, layers.anime.rank(lvl))
                or getLayerPath(mode, layers.anime.level(lvl)))
        end
    end
    return decoded
end

return function (mode, data)
    return Decoder[mode](data)
end
