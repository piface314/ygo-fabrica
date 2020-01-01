local vips = require 'vips'


local TypeWriter = {}

local dpi = 300

function TypeWriter.print(text, base, color, args)
  local x, y, w, h, f, ff, a = args.x, args.y, args.w, args.h, args.f, args.ff, args.a
  local t = vips.Image.text(text, { font = f, fontfile = ff, dpi = dpi })
  if h then t = t:resize(1, { vscale = h / t:height() }) end
  if w and t:width() > w then
    t = t:resize(w / t:width(), { vscale = 1 })
  end
  local tw, th = t:width(), t:height()
  x, y = x or 0, y or 0
  if a == 'right' then
    x = x - tw
  elseif a == 'center' then
    x = x - tw / 2
  end
  if not color then color = { 0, 0, 0 } end
  t = t:bandjoin(color)
  local alpha = t:extract_band(0)
  t = t:extract_band(1, { n = 3 }):bandjoin(alpha):colourspace("yxy")
  local ov = base:crop(x, y, tw, th):composite(t, 'over')
  return base:insert(ov, x, y)
end

function TypeWriter.printf(text, base)

end

return TypeWriter
