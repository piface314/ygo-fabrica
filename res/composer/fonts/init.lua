local path = require 'lib.path'

local Fonts = {
  path = path.prjoin('res', 'composer', 'fonts'),
  fonts = {
    card_name = {file = 'card-name.ttf', family = 'MatrixSmallCaps'},
    edition = {file = 'edition.ttf', family = 'StoneSerif-Semibold'},
    effect = {file = 'effect.ttf', family = 'MatrixBook'},
    flavor_text = {file = 'flavor-text.ttf', family = 'ITCStoneSerifLTItalic'},
    link_rating = {file = 'link-rating.otf', family = 'CodeTalker'},
    monster_desc = { file = 'monster-desc.ttf', family = 'ITCStoneSerifSmallCapsBold' },
    signature = {file = 'signature.ttf', family = 'Stone Serif'},
    values = {file = 'values.ttf', family = 'MatrixBoldSmallCaps'}
  }
}

function Fonts.get_file(id)
  return path.join(Fonts.path, Fonts.fonts[id].file)
end

function Fonts.get_family(id, size)
  if size then
    return ('%s %s'):format(Fonts.fonts[id].family, size)
  else
    return Fonts.fonts[id].family
  end
end

return Fonts
