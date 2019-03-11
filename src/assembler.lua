--- LuaVips image manipulation library
local vips = require "vips"
--- Text Renderer module
local TextRender = require "src.text-renderer"

--- Assembles a card pic in many different ways, making it ready to be printed
local Assembler = {}
Assembler.define = {
    anime = {
        pic = { wd = 570, ht = 831 },
        img = { x = 13, y = 14, wd = 544, ht = 582, blur = 4 },
        atk = { x = 234, y = 725, w = 157, h = 48,
            f = "MatrixBoldSmallCaps 18.7", ff = "res/fonts/matrix-bold-small-caps.ttf", a = 'right' },
        def = { x = 493, y = 725, w = 157, h = 48,
            f = "MatrixBoldSmallCaps 18.7", ff = "res/fonts/matrix-bold-small-caps.ttf", a = 'right' },
        lsc = { x = 180, y = 543, w = 75, h = 52,
            f = "MatrixBoldSmallCaps 20", ff = "res/fonts/matrix-bold-small-caps.ttf", a = 'center' },
        rsc = { x = 390, y = 543, w = 75, h = 52,
            f = "MatrixBoldSmallCaps 20", ff = "res/fonts/matrix-bold-small-caps.ttf", a = 'center' },
        lkr = { x = 441, y = 732, w = 52, h = 37, s = 1.4,
            f = "IDroid 13", ff = "res/fonts/idroid.otf", a = 'left' }
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

--- Applies a feather effecton the top and bottom edges of the image
--  @param img Image on which feather will be applied
--  @param sigma Feather factor
--  @return Feathered edge image
    local function featherEdges(img, sigma)
        local copy = img:copy()
            :resize(1, { vscale = (img:height() - sigma * 2) / img:height() })
            :embed(0, sigma, img:width(), img:height())
        local alpha = copy
            :extract_band(copy:bands() - 1)
            :gaussblur(sigma)
        return img
            :extract_band(0, { n = img:bands() - 1 })
            :bandjoin(alpha)
    end

--- Resizes a card image to best fit it into its canvas
--  @param mode Generator mode (`anime` or `proxy`)
--  @param img Image for the card
--  @return Resized (and sometimes adapted) image, in the correct size of the canvas
function Assembler.resizeCardImg(mode, img)
    if img:bands() == 3 then img = img:bandjoin{ 255 } end
    local def = Assembler.define[mode]
    local wd, ht = def.img.wd, def.img.ht
    local iw, ih = img:width(), img:height()
    if mode == 'anime' then
        if ih / iw < 0.9 then
            local bg = img:resize(ht / ih):gaussblur(def.img.blur)
            bg = bg:crop(bg:width() / 2 - wd / 2, 0, def.img.wd, def.img.ht)
            local fg = featherEdges(img:resize(wd / iw), def.img.blur * 2)
            fg = bg
                :crop(0, ht / 2 - fg:height() / 2, def.img.wd, fg:height())
                :composite(fg, 'over')
            return bg
                :insert(fg, 0, ht / 2 - fg:height() / 2)
        else
            return img:resize(wd / iw, { vscale = ht / ih })
        end
    else
        return img
    end
end

--- Opens an image and prepares it to be used as the image for a card
--  @param mode Generator mode (`anime` or `proxy`)
--  @param imgPath Path to the image file
--  @return The loaded image, ready to be overlaid
function Assembler.prepareCardImg(mode, imgPath)
    local def = Assembler.define[mode]
    local bg = Assembler.loadBase(mode)
    local img = Assembler.resizeCardImg(mode, vips.Image.new_from_file(imgPath))
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
                pic = TextRender.print(pic, tostring(data.atk), def.atk)
            elseif tag == 'def' then
                pic = TextRender.print(pic, tostring(data.def), def.def)
            elseif tag == 'link' then
                pic = TextRender.print(pic, v1, def.lkr)
            elseif tag == 'scales' then
                pic = TextRender.print(pic, v1, def.lsc)
                pic = TextRender.print(pic, v2, def.rsc)
            end
        else
            pic = pic:composite(vips.Image.new_from_file(layer), 'over')
        end
    end
    return pic
end

return function (mode, data, imgPath, layers)
    return Assembler.overlay(mode, data, imgPath, layers)
end
