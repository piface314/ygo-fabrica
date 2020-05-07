
local Fonts = {
  path = "res/composer/fonts",
  fonts = {
    card_name = { file = "card-name.ttf", family = "MatrixSmallCaps" },
    effect = { file = "effect.ttf", family = "MatrixBook" },
    flavor_text = { file = "flavor-text.ttf", family = "ITCStoneSerifLTItalic" },
    link_rating = { file = "link-rating.otf", family = "CodeTalker" },
    monster_desc = { file = "monster-desc.ttf", family = "ITCStoneSerifSmallCapsBold" },
    signature = { file = "signature.ttf", family = "Stone Serif" },
    values = { file = "values.ttf", family = "MatrixBoldSmallCaps" }
  }
}

function Fonts.list()
  local lf = {}
  for _, font in pairs(Fonts.fonts) do
    table.insert(lf, font.file)
  end
  return lf
end

function Fonts.get_file(id)
  return Fonts.path .. "/" .. Fonts.fonts[id].file
end

function Fonts.get_family(id, size)
  if size then
    return ("%s %s"):format(Fonts.fonts[id].family, size)
  else
    return Fonts.fonts[id].family
  end
end

return Fonts