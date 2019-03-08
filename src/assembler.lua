--- LuaVips image manipulation library
local vips = require "vips"

local Assembler = {}
Assembler.define = {
    anime = {
        pic = { wd = 570, ht = 831 },
        img = { x = 13, y = 14, wd = 544, ht = 582 },
        atk = {},
        def = {},
        lkr = {},
        lsc = {},
        rsc = {}
    }
}

local base = {}
--- Loads a transparent base Image
--  @param mode Mode for the base (`anime` or `proxy`)
--  @return Base Image
function Assembler.loadBase(mode)
    if not base[mode] then
        base[mode] = vips.Image.new_from_file("res/layers/" .. mode .. "/_base.png")
    end
    return base[mode]
end

--- Opens an image and prepares it to be used as the image for a card
--  @param mode Generator mode (`anime` or `proxy`)
--  @param imgPath Path to the image file
--  @return The loaded image, ready to be overlaid
function Assembler.prepareCardImg(mode, imgPath)
    local def = Assembler.define[mode]
    local bg = Assembler.loadBase(mode)
    local img = vips.Image.new_from_file(imgPath)
    local iw, ih = img:width(), img:height()
    img = img:resize(def.img.wd / iw, {vscale = def.img.ht / ih})
    local ov = bg:crop(def.img.x, def.img.y, def.img.wd, def.img.ht)
        :composite(img, "over")
    return bg:insert(ov, def.img.x, def.img.y)
end

--- Takes all the data required for a card and overlays all of its layers
--  to form its complete card pic.
--  @param mode Generator mode (`anime` or `proxy`)
--  @param data Card data
--  @param imgPath Path for the card image
--  @param Array of layers
--  @return VIPS Image for the card pic
function Assembler.overlay(mode, data, imgPath, layers)
    local def = Assembler.define[mode]
    local pic = Assembler.loadBase(mode)
    local img = Assembler.prepareCardImg(mode, imgPath)
    for i, layer in ipairs(layers) do
        local tag, v1, v2 = string.match(layer, "^@(%w+)%s*(%d*)%s*(%d*)")
        if tag then
            if tag == 'img' then
                pic = pic:composite(img, 'over')
            elseif tag == 'atk' then

            elseif tag == 'def' then

            elseif tag == 'link' then

            elseif tag == 'scales' then

            end
        else
            pic = pic:composite(vips.Image.new_from_file(layer), 'over')
        end
    end
    return pic
end

return Assembler
