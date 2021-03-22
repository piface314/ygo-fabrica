local Decoder = require 'scripts.composer.decoder'
local Parser = require 'scripts.composer.parser'
local Layer = require 'scripts.composer.layer'
local Shape = require 'scripts.composer.shape'
local Fitter = require 'scripts.composer.fitter'
local Codes = require 'lib.codes'
local path = require 'lib.path'
local vips = require 'vips'

local base_fp = path.prjoin('res', 'composer', 'layers', '_field.png')
local base = vips.Image.new_from_file(base_fp)
local layout = {x = 0, y = 0, w = 512, h = 512}

local field_shape = Shape('field', function(fp)
  local art = vips.Image.new_from_file(fp)
  if art:bands() == 3 then art = art:bandjoin{255} end
  return Fitter.cover(base, art, layout):composite(base, 'over')
end)

return Decoder('field', base, 'singleton', {
  singleton = function(card)
    if Parser.bcheck(card.type, Codes.const.type.FIELD) then
      return nil, Layer(field_shape, card.art)
    end
  end
})
