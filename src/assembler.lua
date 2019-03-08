--- LuaVips image manipulation library
local vips = require "vips"

local Assembler = {}
Assembler.defaultDim = {
    anime = { wd = 570, ht = 831 }
}

--- Creates an Image with the specified width and height, and transparent background
--  @param wd Width
--  @param ht Height
--  @return The desired transparent image
function Assembler.createEmpty(wd, ht)
    return vips.Image.black(wd, ht):bandjoin{ 0, 0, 0 }
end

function Assembler.anime(imgPath, data)

end

return Assembler
