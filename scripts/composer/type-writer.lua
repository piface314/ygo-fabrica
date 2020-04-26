local vips = require 'vips'


local TypeWriter = {}

local DPI = 300

local function is_empty(text)
  return text:match("^%s*$")
end

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
  if is_empty(text) then return base end 
  local x, y, w, h, f, ff, a = args.x, args.y, args.w, args.h, args.f, args.ff, args.a
  local t = vips.Image.text(text, { font = f, fontfile = ff, dpi = DPI })
  if h then
    t = t:resize(1, { vscale = h / t:height() })
  end
  if w and t:width() > w then
    t = t:resize(w / t:width(), { vscale = 1 })
  end
  local tw = t:width()
  x, y = x or 0, y or 0
  if a == 'high' then
    x = x - tw
  elseif a == 'centre' then
    x = x - tw / 2
  end
  return paint_insert(t, base, color, x, y)
end

local function fit_in_ratio(text, opt, h, ft, fs)
  local t
  for _, size in ipairs(fs) do
    opt.font = ("%s %s"):format(ft, size)
    t = vips.Image.text(text, opt)
    if t:height() <= h then
      return t
    end
  end
  return nil
end

local function fit_relaxing_width(text, opt, h, w, i)
  local scale, t = 1
  local initial_wd = opt.width
  repeat
    opt.width = opt.width + i
    scale = w / opt.width
    if scale <= 0.5 then
      opt.width = initial_wd
      return nil
    end
    t = vips.Image.text(text, opt)
  until t:height() <= h
  return t:resize(scale, { vscale = 1 })
end

local function fit_relaxing_width_and_font(text, opt, h, w, i, ft, fs)
  local r, scale, t = 1, 1
  local relax = {
    function() fs = fs - 0.2 end,
    function() opt.width = opt.width + i end
  }
  repeat
    relax[r]()
    scale = w / opt.width
    if scale <= 0.5 then
      return nil
    end
    opt.font = ("%s %s"):format(ft, fs)
    r, t = 3 - r, vips.Image.text(text, opt)
  until t:height() <= h
  return t:resize(scale, { vscale = 1 })
end

function TypeWriter.printf(text, base, color, args)
  if is_empty(text) then return base end 
  local x, y, w, h, ft, fs, ff, a, j, i = args.x, args.y, args.w, args.h, args.ft,
    args.fs, args.ff, args.a or 'low', args.j, args.i or 16
  local opt = { width = w, fontfile = ff, dpi = DPI, justify = j, align = a }
  local t = fit_in_ratio(text, opt, h, ft, fs)
    or fit_relaxing_width(text, opt, h, w, i)
    or fit_relaxing_width_and_font(text, opt, h, w, i, ft, fs[#fs])
  return t and paint_insert(t, base, color, x, y) or base
end

return TypeWriter
