local Layout = require 'scripts.composer.modes.anime.layout'
local Shape = require 'scripts.composer.shape'
local Fitter = require 'scripts.composer.fitter'
local TypeWriter = require 'scripts.composer.type-writer'
local Codes = require 'lib.codes'
local vips = require 'vips'
local path = require 'lib.path'
local fun = require 'lib.fun'

local cache = {}
local ov_fp = path.prjoin('res', 'composer', 'layers', 'anime')
local base_fp = path.prjoin('res', 'composer', 'layers', 'anime', '_base.png')
local base = vips.Image.new_from_file(base_fp)
local function ov(prefix, code)
  local file = ('%s%s.png'):format(prefix, code or '')
  if not cache[file] then
    cache[file] = vips.Image.new_from_file(path.join(ov_fp, file))
  end
  return cache[file]
end

return {
  BASE = base,
  OVERLAY = Shape('overlay', ov),
  ART = Shape('art', function(fp, artsize)
    local art = vips.Image.new_from_file(fp)
    if art:bands() == 3 then art = art:bandjoin{255} end
    local fit = Fitter[artsize] or Fitter.cover
    return fit(base, art, Layout.art)
  end),
  SCALES = Shape('pendulum-scale', function(lsc, rsc)
    local lt = TypeWriter.print(tostring(lsc), base, Layout.lsc)
    return TypeWriter.print(tostring(rsc), lt, Layout.rsc)
  end),
  ATT = Shape('attribute', function (att)
    local icon = ov('att', att)
    local label = Codes.i18n('attribute', att)
    label = '<t=-1>' .. label .. '</>'
    return TypeWriter.print(label, icon, Layout.att, '#ffffff')
  end),
  ST_ICON = Shape('attribute', function(st)
    local icon = ov('st', st)
    local label = Codes.i18n('type', st, 'attribute')
    label = '<t=-1>' .. label .. '</>'
    return TypeWriter.print(label, icon, Layout.st_icon, '#ffffff')
  end),
  LINK_RATING = Shape('link-rating', function(lkr)
    return TypeWriter.print(tostring(lkr), ov('link'), Layout.lkr)
  end),
  LINK_ARROWS = Shape('link-arrows', function(arrows)
    return fun.iter(arrows):map(function(a) return ov('lka', a) end)
      :reduce(ov('lka-base'), function(img, a)
        return img:composite(a, 'over')
      end)
  end),
  ATK = Shape('atk', function(atk)
    atk = atk < 0 and '?' or tostring(atk)
    return TypeWriter.print(atk, base, Layout.atk)
  end),
  DEF = Shape('def', function(def)
    def = def < 0 and '?' or tostring(def)
    return TypeWriter.print(def, base, Layout.def)
  end)
}
