--- LuaVips image manipulation library
local vips = require "vips"

local dpi = 300

--- Defines utility functions to render text on a vips Image
local TextRender = {}

--- Prints plain text to an image
--  @param base Image to which text is printed
--  @param t Text to be printed
--  @param args Table of named optional arguments for the function
--  @returns Base image with text
function TextRender.print(base, t, args)
    local f, ff, a, x, y, w, h, s, c
        = args.f, args.ff, args.a, args.x, args.y, args.w, args.h, args.s, args.c
    local text = vips.Image.text(t, { font = f, fontfile = ff, dpi = dpi })
    if h then text = text:resize(h / text:height()) end
    if s then text = text:resize(s, { vscale = 1 }) end
    if w and text:width() > w then
        text = text:resize(w / text:width(), { vscale = 1 })
    end
    if a ~= 'left' and a ~= 'center' and a ~= 'right' then a = 'left' end
    x, y = x or 0, y or 0
    x = ({
        left = function (x) return x end,
        center = function (x) return x - text:width() / 2 end,
        right = function (x) return x - text:width() end
    })[a](x)
    if not c then c = { 0, 0, 0 } end
    text = text:bandjoin(c)
    local alpha = text:extract_band(0)
    text = text
        :extract_band(1, { n = 3 })
        :bandjoin(alpha)
        :colourspace("yxy")
    local ov = base:crop(x, y, text:width(), text:height()):composite(text, 'over')
    return base:insert(ov, x, y)
end

function TextRender.printf(base, t, font, fontPath, align, x, y, w, h)
    return base
end

return TextRender
