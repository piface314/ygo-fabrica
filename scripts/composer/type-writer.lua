local vips = require 'vips'


local TypeWriter = {}

local DPI = 300

local function paint_insert(t, base, color, x, y)
  local tw, th = t:width(), t:height()
  if not color then color = { 0, 0, 0 } end
  t = t:bandjoin(color)
  local alpha = t:extract_band(0)
  t = t:extract_band(1, { n = 3 }):bandjoin(alpha):colourspace("yxy")
  local ov = base:crop(x, y, tw, th):composite(t, 'over')
  return base:insert(ov, x, y)
end

function TypeWriter.print(text, base, color, args)
  local x, y, w, h, f, ff, a = args.x, args.y, args.w, args.h, args.f, args.ff, args.a
  local t = vips.Image.text(text, { font = f, fontfile = ff, dpi = DPI })
  if h then
    t = t:resize(1, { vscale = h / t:height() })
  end
  if w and t:width() > w then
    t = t:resize(w / t:width(), { vscale = 1 })
  end
  local tw, th = t:width(), t:height()
  x, y = x or 0, y or 0
  if a == 'high' then
    x = x - tw
  elseif a == 'centre' then
    x = x - tw / 2
  end
  return paint_insert(t, base, color, x, y)
end

function TypeWriter.printf(text, base, color, args)
  local x, y, w, h, ft, fs, ff, a, j, i = args.x, args.y, args.w, args.h, args.ft,
    args.fs, args.ff, args.a or 'low', args.j, args.i or 16
  local opt, t = { width = w, fontfile = ff, dpi = DPI, justify = j, align = a }
  for _, size in ipairs(fs) do
    opt.font = ("%s %s"):format(ft, size)
    t = vips.Image.text(text, opt)
    if t:height() <= h then
      return paint_insert(t, base, color, x, y)
    end
  end
  repeat
    opt.width = opt.width + i
    t = vips.Image.text(text, opt)
  until t:height() <= h
  local scale = w / opt.width
  return paint_insert(t:resize(scale, { vscale = 1 }), base, color, x, y)
end

return TypeWriter
