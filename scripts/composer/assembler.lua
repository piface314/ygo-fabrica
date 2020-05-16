local vips = require 'vips'
local path = require 'lib.fs'.path
local Layouts = require 'scripts.composer.layouts'
local Fitter = require 'scripts.composer.fitter'
local TypeWriter = require 'scripts.composer.type-writer'


local Assembler = {}

local mode = 'proxy'
local options = {}
local layers_dir = path.prjoin("res", "composer", "layers")
local bases, overlays = {}, { anime = {}, proxy = {} }
local shapes = { anime = {}, proxy = {} }

local function get_base()
  if not bases[mode] then
    local basefp = path.join(layers_dir, mode, "_base.png")
    bases[mode] = vips.Image.new_from_file(basefp)
  end
  return bases[mode]
end

local function overlay(ov)
  if not overlays[mode][ov] then
    local layer = vips.Image.new_from_file(path.join(layers_dir, mode, ov))
    overlays[mode][ov] = layer
  end
  return overlays[mode][ov]
end

local field_pic, field_base
local function field(fp)
  if not field_base then
    field_base = vips.Image.new_from_file(path.join(layers_dir, "_field.png"))
  end
  local art = vips.Image.new_from_file(fp)
  if art:bands() == 3 then art = art:bandjoin{ 255 } end
  field_pic = Fitter.cover(field_base, art, Layouts.field)
    :composite(field_base, 'over')
end
shapes.anime.field = field
shapes.proxy.field = field

function shapes.anime.overlay(ov)
  return overlay(ov)
end

function shapes.anime.art(fp)
  local art = vips.Image.new_from_file(fp)
  if art:bands() == 3 then art = art:bandjoin{ 255 } end
  local artsize = options.artsize
  if artsize == 'fill' then
    return Fitter.fill(get_base(), art, Layouts.anime.art)
  elseif artsize == 'contain' then
    return Fitter.contain(get_base(), art, Layouts.anime.art)
  else
    return Fitter.cover(get_base(), art, Layouts.anime.art)
  end
end

function shapes.anime.scales(lsc, rsc)
  local lt = TypeWriter.print(tostring(lsc), get_base(), nil, Layouts.anime.lsc)
  return TypeWriter.print(tostring(rsc), lt, nil, Layouts.anime.rsc)
end

function shapes.anime.link_rating(link_rating)
  return TypeWriter.print(tostring(link_rating), get_base(), nil, Layouts.anime.lkr)
end

function shapes.anime.atk(atk)
  atk = atk < 0 and "?" or tostring(atk)
  return TypeWriter.print(atk, get_base(), nil, Layouts.anime.atk)
end

function shapes.anime.def(def)
  def = def < 0 and "?" or tostring(def)
  return TypeWriter.print(def, get_base(), nil, Layouts.anime.def)
end

function shapes.proxy.overlay(ov)
  return overlay(ov)
end

function shapes.proxy.art(fp)
  local art = vips.Image.new_from_file(fp)
  if art:bands() == 3 then art = art:bandjoin{ 255 } end
  local artsize = options.artsize
  local box = overlay("artbox.png")
  if artsize == 'fill' then
    return Fitter.fill(box, art, Layouts.proxy.art.regular)
  elseif artsize == 'contain' then
    return Fitter.contain(box, art, Layouts.proxy.art.regular)
  else
    return Fitter.cover(box, art, Layouts.proxy.art.regular)
  end
end

local abs, inf = math.abs, math.huge
local function best_layout(ref, layouts)
  local bestdr, best = inf, nil
  for id, layout in pairs(layouts) do
    local dr = abs(layout.w / layout.h - ref)
    if dr < bestdr then
      bestdr, best = dr, id
    end
  end
  return best, layouts[best]
end

function shapes.proxy.pendulum_frame(fp, frame_fp, size)
  local art = vips.Image.new_from_file(fp)
  if art:bands() == 3 then art = art:bandjoin{ 255 } end
  local r = art:width() / art:height()
  local frame_type, layout = best_layout(r, Layouts.proxy.art.pendulum[size])
  local artsize = options.artsize
  if artsize == 'fill' then
    art = Fitter.fill(get_base(), art, layout)
  elseif artsize == 'contain' then
    art = Fitter.contain(get_base(), art, layout)
  else
    art = Fitter.cover(get_base(), art, layout)
  end
  local frame = overlay(frame_fp:format(size, frame_type))
  return art:composite(frame, 'over')
end

local function fmt_sc(sc) return ('<span letter_spacing="-7168">%d</span>'):format(sc) end
function shapes.proxy.pendulum_scales(lsc, rsc, size)
  local lt = TypeWriter.print(fmt_sc(lsc), get_base(), nil, Layouts.proxy.lscale[size])
  return TypeWriter.print(fmt_sc(rsc), lt, nil, Layouts.proxy.rscale[size])
end

function shapes.proxy.pendulum_effect(effect, size)
  return TypeWriter.printf(effect, get_base(), nil, Layouts.proxy.pendulum_effect[size])
end

function shapes.proxy.spelltrap_effect(effect)
  return TypeWriter.printf(effect, get_base(), nil, Layouts.proxy.spelltrap_effect)
end

function shapes.proxy.link_rating(link_rating)
  local label = overlay("link.png")
  return TypeWriter.print(tostring(link_rating), label, nil,
    Layouts.proxy.link_rating)
end

function shapes.proxy.def(def)
  local label = overlay("def.png")
  if def < 0 then
    return TypeWriter.print("?", label, nil, Layouts.proxy.def_u)
  else
    return TypeWriter.print(tostring(def), label, nil, Layouts.proxy.def)
  end
end

function shapes.proxy.atk(atk)
  local label = overlay("atk.png")
  if atk < 0 then
    return TypeWriter.print("?", label, nil, Layouts.proxy.atk_u)
  else
    return TypeWriter.print(tostring(atk), label, nil, Layouts.proxy.atk)
  end
end

local brackets = [[<span rise="2000">%s</span>]]
local desc_template = ([[<span letter_spacing="1024">%s%%s%s</span>]])
  :format(brackets:format("["), brackets:format("]"))
local function fmt_desc(desc) return desc_template:format(desc) end
function shapes.proxy.monster_desc(desc)
  return TypeWriter.print(fmt_desc(desc), get_base(), nil, Layouts.proxy.monster_desc)
end

function shapes.proxy.flavor_text(text)
  return TypeWriter.printf(text, get_base(), nil, Layouts.proxy.flavor_text)
end

function shapes.proxy.monster_effect(effect)
  return TypeWriter.printf(effect, get_base(), nil, Layouts.proxy.monster_effect)
end

function shapes.proxy.name(name, color)
  return TypeWriter.print(name, get_base(), color, Layouts.proxy.name)
end

local code_template = [[<span letter_spacing="1024">%08u</span>]]
local function fmt_code(code) return code_template:format(code) end
function shapes.proxy.serial_code(code, color)
  return TypeWriter.print(fmt_code(code), get_base(), color, Layouts.proxy.serial_code)
end

local cr_template = [[<span letter_spacing="1024"><span size="5000">©</span>%s</span> %s]]
local default_year = 1996
local default_author = "KAZUKI TAKASHI"
local function fmt_cr(year, author) return cr_template:format(year, author:upper()) end
function shapes.proxy.copyright(color)
  local year = options.year or default_year
  local author = options.author or default_author
  return TypeWriter.print(fmt_cr(year, author), get_base(),
    color, Layouts.proxy.copyright)
end

function Assembler.configure(m, opt)
  mode, options = m, opt
end

function Assembler.assemble(metalayers)
  local img = get_base()
  field_pic = nil
  for _, metalayer in ipairs(metalayers) do
    local shape, values = metalayer.shape, metalayer.values
    local layer = shapes[mode][shape](unpack(values))
    if layer then
      img = img:composite(layer, 'over')
    end
  end
  return img, field_pic
end

return Assembler
