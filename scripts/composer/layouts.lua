

local Layouts = {}

Layouts.anime = {
  art = { x = 13, y = 14, w = 544, h = 582, blur = 4 },
  atk = { x = 234, y = 725, w = 157, h = 48,
    f = "MatrixBoldSmallCaps 18.7", ff = "values.ttf", a = "right" },
  def = { x = 493, y = 725, w = 157, h = 48,
    f = "MatrixBoldSmallCaps 18.7", ff = "values.ttf", a = "right" },
  lsc = { x = 180, y = 543, w = 75, h = 52,
    f = "MatrixBoldSmallCaps 20", ff = "values.ttf", a = "center" },
  rsc = { x = 390, y = 543, w = 75, h = 52,
    f = "MatrixBoldSmallCaps 20", ff = "values.ttf", a = "center" },
  lkr = { x = 441, y = 732, w = 52, h = 37, s = 1.4,
    f = "CodeTalker 13", ff = "link-rating.otf", a = "left" }
}

Layouts.proxy = {
  
  art = {
    regular = { x = 83, y = 185, w = 528, h = 528 },
    pendulum_m = { x = 45, y = 182, w = 603, h = { 448, 569 } },
    pendulum_s = { x = 45, y = 182, w = 603, h = { 484, 569 } }
  },

  name = { x = 54, y = 54, w = 512,
    f = "MatrixSmallCaps 20", ff = "card-name.ttf", a = "left" },

  lscale_m = { x = 70, y = 695, w = 42,
    f = "MatrixBoldSmallCaps 12", ff = "values.ttf", a = "center" },

  rscale_m = { x = 623, y = 695, w = 42,
    f = "MatrixBoldSmallCaps 12", ff = "values.ttf", a = "center" },

  pendulum_effect_m = { x = 109, y = 644, w = 475, h = 102, j = true,
    f = "MatrixBook 4", ff = "effect.ttf", a = "left" },

  lscale_s = { x = 70, y = 715, w = 42,
    f = "MatrixBoldSmallCaps 12", ff = "values.ttf", a = "center" },

  rscale_s = { x = 623, y = 715, w = 42,
    f = "MatrixBoldSmallCaps 12", ff = "values.ttf", a = "center" },

  pendulum_effect_s = { x = 109, y = 680, w = 475, h = 68, j = true,
    f = "MatrixBook 4.8", ff = "effect.ttf", a = "left" }, -- actually 5pt

  monster_desc = { x = 54, y = 766, w = 585,
    f = "ITCStoneSerifSmallCapsBold 6.5", ff = "monster-desc.ttf", a = "left" },

  flavor_text = { x = 53, y = 794, w = 588, h = 126, j = true,
    f = "ITCStoneSerifLTItalic 5", ff = "flavor-text.ttf", a = "left" },

  monster_effect = { x = 53, y = 794, w = 588, h = 126, j = true,
    f = "MatrixBook 5", ff = "effect.ttf", a = "left" },

  spelltrap_effect = { x = 53, y = 764, w = 585, h = 181, j = true,
    f = "MatrixBook 5", ff = "effect.ttf", a = "left" },

  atk = { x = 500, y = 927,
    f = "MatrixBoldSmallCaps 7.25", ff = "values.ttf", a = "right" },

  def = { x = 640, y = 927,
    f = "MatrixBoldSmallCaps 7.25", ff = "values.ttf", a = "right" },

  link_rating = { x = 639, y = 927,
    f = "CodeTalker 6.5", ff = "link-rating.otf", a = "right" },

  serial_code = { x = 32, y = 968, w = 120,
    f = "Stone Serif 4.5", ff = "signature.ttf", a = "left" },

  copyright = { x = 631, y = 968, w = 260,
    f = "Stone Serif 4.25", ff = "signature.ttf", a = "right" }
}

return Layouts
