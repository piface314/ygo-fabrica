local vips = require 'vips'
local path = require 'path'
local Layouts = require 'scripts.composer.layouts'
local Fitter = require 'scripts.composer.fitter'


local Assembler = {}

local mode = 'proxy'
local options = {}
local folders = {}
folders.res = path.join("res", "composer")
folders.fonts = path.join(folders.res, "fonts")
folders.layers = path.join(folders.res, "layers")
local bases = {}
local shapes = { anime = {}, proxy = {} }

local function get_base()
  if not bases[mode] then
    local basefp = path.join(folders.layers, mode, "_base.png")
    bases[mode] = vips.Image.new_from_file(basefp)
  end
  return bases[mode]
end

local function overlay(ov)
  return vips.Image.new_from_file(path.join(folders.layers, mode, ov))
end

function shapes.anime.overlay(ov)
  return overlay(ov)
end

function shapes.anime.art(fp)
  local art = vips.Image.new_from_file(fp)
  if art:bands() == 3 then art = art:bandjoin{ 255 } end
  local artsize = options.artsize
  if artsize == 'contain' then
    return Fitter.contain(get_base(), art, Layouts.anime.art)
  else
    return Fitter.cover(get_base(), art, Layouts.anime.art)
  end
end

function shapes.anime.scales(lsc, rsc)

end

function shapes.anime.link_rating(args)

end

function shapes.anime.atk(atk)

end

function shapes.anime.def(def)

end

function shapes.proxy.overlay(ov)
  return overlay(ov)
end

function shapes.proxy.art(fp)
  local art = vips.Image.new_from_file(fp)
  if art:bands() == 3 then art = art:bandjoin{ 255 } end
  local artsize = options.artsize
  local box = overlay("artbox.png")
  if artsize == 'contain' then
    return Fitter.contain(box, art, Layouts.proxy.art.regular)
  else
    return Fitter.cover(box, art, Layouts.proxy.art.regular)
  end
end

function shapes.proxy.pendulum_art(fp)

end

function shapes.proxy.pendulum_frame()

end

function shapes.proxy.pendulum_scales(lsc, rsc)

end

function shapes.proxy.pendulum_effect(effect)

end

function shapes.proxy.pendulum_lkabase()

end

function shapes.proxy.pendulum_lka(arrow)

end

function shapes.proxy.spelltrap_effect(effect)

end

function shapes.proxy.link_rating(link_rating)

end

function shapes.proxy.def(def)

end

function shapes.proxy.atk(atk)

end

function shapes.proxy.monster_desc(desc)

end

function shapes.proxy.flavor_text(text)

end

function shapes.proxy.monster_effect(effect)

end

function shapes.proxy.name(name, color)

end

function shapes.proxy.serial_code(code, color)

end

function shapes.proxy.copyright(color)

end

function Assembler.set_mode(m)
  mode = m
end

function Assembler.set_options(opt)
  options = opt
end

function Assembler.assemble(metalayers)
  local img = get_base()
  for _, metalayer in ipairs(metalayers) do
    local shape, values = metalayer.shape, metalayer.values
    local layer, msg = shapes[mode][shape](unpack(values))
    if layer then
      img = img:composite(layer, 'over')
    end
  end
  return img
end

return Assembler
