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
        link = function (lka) return string.format("lka%d.png", lka) end,
        rank = function (rk) return string.format("r%d.png", rk) end,
        linkBase = "lka-base.png",
    },
    proxy = {

    }
}

--- Generates the full layer path name
--  @param mode Generator mode (either `anime` or `proxy`)
--  @param layer Either a function that returns a string or a string, indicating a layer
--  @return Full layer path name
local function getLayerPath(mode, layer, ...)
    return "res/layers/" .. mode .. "/"
        .. (type(layer) == "function" and layer(...) or layer)
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

--- Decodes information from the database and transforms it into more usable
--  information to the assembler module
local Decoder = {}

function Decoder.anime(imgPath, data)
    local f, p = getFrame(data)

end

return function (mode, imgPath, data)
    return Decoder[mode](imgPath, data)
end
