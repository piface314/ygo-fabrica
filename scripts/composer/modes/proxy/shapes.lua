local Layout = require 'scripts.composer.modes.proxy.layout'
local Shape = require 'scripts.composer.shape'
local Fitter = require 'scripts.composer.fitter'
local TypeWriter = require 'scripts.composer.type-writer'
local vips = require 'vips'
local path = require 'lib.path'
local Codes = require 'lib.codes'
local i18n = require 'i18n'
local fun = require 'lib.fun'

local types = Codes.const.type

local cache = {}
local ov_fp = path.prjoin('res', 'composer', 'layers', 'proxy')
local base_fp = path.prjoin('res', 'composer', 'layers', 'proxy', '_base.png')
local base = vips.Image.new_from_file(base_fp)
local function ov(prefix, code, suffix)
  local file = ('%s%s%s.png'):format(prefix, code or '', suffix or '')
  if not cache[file] then
    cache[file] = vips.Image.new_from_file(path.join(ov_fp, file))
  end
  return cache[file]
end

local abs, inf = math.abs, math.huge
local function best_layout(ref, layouts)
  local bestdr, best = inf, nil
  for id, layout in pairs(layouts) do
    local dr = abs(layout.w / layout.h - ref)
    if dr < bestdr then bestdr, best = dr, id end
  end
  return best, layouts[best]
end

local fmt_sc = function(sc) return ('<t=-14>%d</>'):format(sc) end

local setnumber_keys = {
  [0] = 'regular',
  [types.PENDULUM] = 'pendulum',
  [types.LINK] = 'link'
}

--- @type table<string, Shape>
return {
  BASE = base,
  OVERLAY = Shape('overlay', ov),
  NAME = Shape('card-name', function(name, color)
    return TypeWriter.print(name, base, Layout.name, color)
  end),
  ATTRIBUTE = Shape('attribute', function(att, st)
    local icon = ov('att', st and 'st' or '', att)
    local label = st and Codes.i18n('type', att, 'attribute')
      or Codes.i18n('attribute', att)
    label = '<t=-1>' .. label .. '</>'
    return TypeWriter.print(label, icon, Layout.attribute, '#ffffff')
  end),
  ST_LABEL = Shape('spelltrap-label', function(st, st_type)
    if st_type > 0 then
      local icon = ov('st', st_type)
      local label = Codes.i18n('type', st, 'label.other')
      return TypeWriter.print(label, icon, Layout.spelltrap_label)
    else
      local label = Codes.i18n('type', st, 'label.normal')
      return TypeWriter.print(label, base, Layout.spelltrap_label)
    end
  end),
  ART = Shape('art', function(fp, artsize)
    local art = vips.Image.new_from_file(fp)
    if art:bands() == 3 then art = art:bandjoin{255} end
    local box = ov('artbox')
    local fit = Fitter[artsize] or Fitter.cover
    return fit(box, art, Layout.art.regular)
  end),
  LINK_ARROWS = Shape('link-arrows', function(arrows, ps)
    local suffix = ps and 'p' .. ps or ''
    return fun.iter(arrows):map(function(a) return ov('lka', a, suffix) end)
      :reduce(ov('lka-base', suffix), function(img, a)
        return img:composite(a, 'over')
      end)
  end),
  SETNUMBER = Shape('setnumber', function(set, mtype, color)
    set = '<t=4>' .. set .. '</>'
    mtype = setnumber_keys[mtype]
    return TypeWriter.print(set, base, Layout.setnumber[mtype], color)
  end),
  PEND_FRAME = Shape('pendulum-frame', function(fp, ps, artsize)
    local art = vips.Image.new_from_file(fp)
    if art:bands() == 3 then art = art:bandjoin{255} end
    local r = art:width() / art:height()
    local op_type, layout = best_layout(r, Layout.art.pendulum[ps])
    local fit = Fitter[artsize] or Fitter.cover
    art = fit(base, art, layout)
    local frame = ov('type', Codes.const.type.PENDULUM, ps .. op_type)
    return art:composite(frame, 'over')
  end),
  PEND_SCALE = Shape('pendulum-scale', function(lsc, rsc, ps)
    lsc, rsc = fmt_sc(lsc), fmt_sc(rsc)
    local lt = TypeWriter.print(lsc, base, Layout.lscale[ps])
    return TypeWriter.print(rsc, lt, Layout.rscale[ps])
  end),
  PEND_EFFECT = Shape('pendulum-effect', function(effect, ps)
    return TypeWriter.printf(effect, base, Layout.pendulum_effect[ps])
  end),
  MONSTER_DESC = Shape('monster-desc', function(desc)
    desc = '<t=2><r=2>[</>' .. table.concat(desc, '/') .. '<r=2>]</></>'
    return TypeWriter.print(desc, base, Layout.monster_desc)
  end),
  FLAVOR_TEXT = Shape('flavor-text', function(text)
    return TypeWriter.printf(text, base, Layout.flavor_text)
  end),
  MONSTER_EFFECT = Shape('monster-effect', function(effect)
    return TypeWriter.printf(effect, base, Layout.monster_effect)
  end),
  ST_EFFECT = Shape('spelltrap-effect', function(effect)
    return TypeWriter.printf(effect, base, Layout.spelltrap_effect)
  end),
  ATK = Shape('atk', function(atk)
    local label = ov('atk')
    return atk < 0
      and TypeWriter.print('?', label, Layout.atk_q)
      or  TypeWriter.print(atk, label, Layout.atk)
  end),
  DEF = Shape('def', function(def)
    local label = ov('def')
    return def < 0
      and TypeWriter.print('?', label, Layout.def_q)
      or  TypeWriter.print(def, label, Layout.def)
  end),
  LINK_RATING = Shape('link-rating', function(lkr)
    return TypeWriter.print(lkr, ov('link'), Layout.link_rating)
  end),
  EDITION = Shape('edition', function(pos, color)
    local edition = i18n 'compose.modes.proxy.edition'
    return TypeWriter.print(edition, base, Layout.edition[pos], color)
  end),
  SERIAL_CODE = Shape('serial-code', function(id, color)
    local code = ('<t=2>%08u</>'):format(id)
    return TypeWriter.print(code, base, Layout.serial_code, color)
  end),
  FORBIDDEN = Shape('forbidden', function()
    local label = i18n 'compose.modes.proxy.forbidden'
    return TypeWriter.print(label, base, Layout.forbidden)
  end),
  COPYRIGHT = Shape('copyright', function(color, year, author)
    local vals = {
      year = year or 1996,
      author = author or i18n 'compose.modes.proxy.default_author'
    }
    local text = i18n('compose.modes.proxy.copyright', vals)
    return TypeWriter.print(text, base, Layout.copyright, color)
  end)
}
