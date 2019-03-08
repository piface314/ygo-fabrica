--- LuaVips image manipulation library
local vips = require "vips"

local Assembler = {}

function Assembler.anime(imgPath, data)
    
end

return function (mode, imgPath, data)
    return Assembler[mode](imgPath, data)
end
