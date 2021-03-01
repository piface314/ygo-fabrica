local vips = require 'vips'

--- Provides text printing functions.
local TypeWriter = {}

local DPI = 300

local BLACK = {0, 0, 0}
local min, max, ceil = math.min, math.max, math.ceil
local function byte_clamp(v) return min(max(ceil(tonumber(v, 16)), 0), 255) end
local function color_clamp(color)
  if type(color) ~= 'string' then return nil end
  local r, g, b = color:match('^%s*#(%x%x)(%x%x)(%x%x)%s*$')
  if not r then return nil end
  return {byte_clamp(r), byte_clamp(g), byte_clamp(b)}
end

local function is_empty(text)
  return text:gsub('%b<>', ''):match('^%s*$')
end

local markup = {
  r = function(v) return ('rise="%d"'):format(v * 1000) end,
  s = function(v) return ('size="%d"'):format(v * 1000) end,
  t = function(v) return ('letter_spacing="%d"'):format(v * 512) end
}
local function apply_markup(k, v) return markup[k](tonumber(v)) end
local function expand_markup(text)
  return text:gsub('%b<>', function(s)
    if s == '</>' then return '</span>' end
    return (s:gsub('^<', '<span '):gsub('(.)=(%-?%d+%.?%d*)', apply_markup))
  end)
end

local function prepare_text(text)
  if not text then return nil end
  if type(text) ~= 'string' then text = tostring(text) end
  if is_empty(text) then return nil end
  return expand_markup(text)
end

local function paint_insert(t, base, color, x, y)
  local tw, th = t:width(), t:height()
  if not color then color = BLACK end
  t = t:bandjoin(color)
  local alpha = t:extract_band(0)
  t = t:extract_band(1, {n = 3}):bandjoin(alpha):colourspace('yxy')
  local ov = base:crop(x, y, tw, th):composite(t, 'over')
  return base:insert(ov, x, y)
end

local function fit_in_ratio(text, opt, h, ft, fs)
  local t
  for _, size in ipairs(fs) do
    opt.font = ('%s %s'):format(ft, size)
    t = vips.Image.text(text, opt)
    if t:height() <= h then return t end
  end
  return nil
end

local function fit_relaxing_width(text, opt, h, w, i)
  local scale, t = 1, nil
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
  return t:resize(scale, {vscale = 1})
end

local function fit_relaxing_width_and_font(text, opt, h, w, i, ft, fs)
  local r, scale, t = 1, 1, nil
  local relax = {
    function() fs = fs - 0.2 end,
    function() opt.width = opt.width + i end
  }
  repeat
    relax[r]()
    scale = w / opt.width
    if scale <= 0.5 then return nil end
    opt.font = ('%s %s'):format(ft, fs)
    r, t = 3 - r, vips.Image.text(text, opt)
  until t:height() <= h
  return t:resize(scale, {vscale = 1})
end

local align = {left = 'low', center = 'centre', right = 'high'}
--- Prints formatted `text` in an area to a background image (`base`).
--- This function supports word wrapping and tries to fit the text in
--- the specified area as best as possible.
--- `args` specify multiple layout parameters.
--- `color` must be a string in hex format (e.g. '#ffffff' -> white).
--- If none is specified, black ('#000000') is used to print that text.
--- @param text string
--- @param base Image
--- @param args table
--- @param color? string
--- @return any
function TypeWriter.printf(text, base, args, color)
  text = prepare_text(text)
  color = color_clamp(color)
  if not text then return base end
  text = '<span insert_hyphens="false">' .. text .. '</span>'
  local x, y, w, h, ft, fs = args.x, args.y, args.w, args.h, args.ft, args.fs
  local ff, a, j, i = args.ff, align[args.a] or 'low', args.j, args.i or 16
  local opt = {width = w, fontfile = ff, dpi = DPI, justify = j, align = a}
  local t = fit_in_ratio(text, opt, h, ft, fs)
    or fit_relaxing_width(text, opt, h, w, i)
    or fit_relaxing_width_and_font(text, opt, h, w, i, ft, fs[#fs])
  return t and paint_insert(t, base, color, x, y) or base
end

--- Prints `text` in a single line to a background image (`base`).
--- `args` specify multiple layout parameters.
--- `color` must be a string in hex format (e.g. '#ffffff' -> white).
--- If none is specified, black ('#000000') is used to print that text.
--- @param text string
--- @param base Image
--- @param args table
--- @param color? string
--- @return any
function TypeWriter.print(text, base, args, color)
  text = prepare_text(text)
  color = color_clamp(color)
  if not text then return base end
  local x, y, w, h = args.x, args.y, args.w, args.h
  local f, ff, a = args.f, args.ff, args.a
  local t = vips.Image.text(text, {font = f, fontfile = ff, dpi = DPI})
  if h then t = t:resize(1, {vscale = h / t:height()}) end
  if w and t:width() > w then
    t = t:resize(w / t:width(), {vscale = 1})
  end
  local tw = t:width()
  x, y = x or 0, y or 0
  if a == 'right' then
    x = x - tw
  elseif a == 'center' then
    x = x - tw / 2
  end
  return paint_insert(t, base, color, x, y)
end

return TypeWriter
