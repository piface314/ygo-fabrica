

local Layouts = {}

local fonts = "res/composer/fonts/"

Layouts.anime = {
  art = { x = 13, y = 14, w = 544, h = 582, blur = 4 },
  atk = { x = 234, y = 725, w = 157, h = 48,
    f = "MatrixBoldSmallCaps 18.7", ff = fonts .. "values.ttf", a = "high" },
  def = { x = 493, y = 725, w = 157, h = 48,
    f = "MatrixBoldSmallCaps 18.7", ff = fonts .. "values.ttf", a = "high" },
  lsc = { x = 180, y = 543, w = 75,
    f = "MatrixBoldSmallCaps 20", ff = fonts .. "values.ttf", a = "centre" },
  rsc = { x = 390, y = 543, w = 75,
    f = "MatrixBoldSmallCaps 20", ff = fonts .. "values.ttf", a = "centre" },
  lkr = { x = 450, y = 732, w = 52,
    f = "CodeTalker 12.5", ff = fonts .. "link-rating.otf", a = "low" }
}

Layouts.proxy = {

  art = {
    regular = { x = 83, y = 185, w = 528, h = 528 },
    pendulum = {
      m = {
        o = { x = 45, y = 182, w = 603, h = 448 },
        t = { x = 45, y = 182, w = 603, h = 569 }
      },
      s = {
        o = { x = 45, y = 182, w = 603, h = 484 },
        t = { x = 45, y = 182, w = 603, h = 569 }
      }
    }
  },

  name = { x = 54, y = 54, w = 512,
    f = "MatrixSmallCaps 20", ff = fonts .. "card-name.ttf", a = "low" },

  lscale = {
    m = { x = 70, y = 695, w = 42,
      f = "MatrixBoldSmallCaps 12", ff = fonts .. "values.ttf", a = "centre" },
    s = { x = 70, y = 715, w = 42,
      f = "MatrixBoldSmallCaps 12", ff = fonts .. "values.ttf", a = "centre" }
  },

  rscale = {
    m = { x = 623, y = 695, w = 42,
      f = "MatrixBoldSmallCaps 12", ff = fonts .. "values.ttf", a = "centre" },
    s = { x = 623, y = 715, w = 42,
      f = "MatrixBoldSmallCaps 12", ff = fonts .. "values.ttf", a = "centre" }
  },

  pendulum_effect = {
    m = { x = 109, y = 644, w = 475, h = 102, j = true, fs = { 4, 3.5 },
      ft = "MatrixBook", ff = fonts .. "effect.ttf", a = "low" },
    s = { x = 109, y = 680, w = 475, h = 68, j = true, fs = { 4.8 },
      ft = "MatrixBook", ff = fonts .. "effect.ttf", a = "low" } -- actually 5pt
  },

  monster_desc = { x = 54, y = 766, w = 585,
    f = "ITCStoneSerifSmallCapsBold 6.5", ff = fonts .. "monster-desc.ttf", a = "low" },

  flavor_text = { x = 53, y = 794, w = 588, h = 126, j = true, fs = { 5, 4 },
    ft = "ITCStoneSerifLTItalic", ff = fonts .. "flavor-text.ttf", a = "low" },

  monster_effect = { x = 53, y = 794, w = 588, h = 126, j = true, fs = { 5, 4.5, 4, 3.8, 3.6 },
    ft = "MatrixBook", ff = fonts .. "effect.ttf", a = "low" },

  spelltrap_effect = { x = 53, y = 764, w = 585, h = 181, j = true, fs = { 5, 4.5, 4 },
    ft = "MatrixBook", ff = fonts .. "effect.ttf", a = "low" },

  atk = { x = 500, y = 927,
    f = "MatrixBoldSmallCaps 7.25", ff = fonts .. "values.ttf", a = "high" },

  atk_u = { x = 500, y = 927, w = 13, h = 19,
    f = "MatrixBoldSmallCaps 12", ff = fonts .. "values.ttf", a = "high" },

  def = { x = 640, y = 927,
    f = "MatrixBoldSmallCaps 7.25", ff = fonts .. "values.ttf", a = "high" },

  def_u = { x = 640, y = 927, w = 13, h = 19,
    f = "MatrixBoldSmallCaps 12", ff = fonts .. "values.ttf", a = "high" },

  link_rating = { x = 639, y = 927,
    f = "CodeTalker 6.5", ff = fonts .. "link-rating.otf", a = "high" },

  serial_code = { x = 32, y = 968, w = 120,
    f = "Stone Serif 4.5", ff = fonts .. "signature.ttf", a = "low" },

  copyright = { x = 631, y = 968, w = 260,
    f = "Stone Serif 4.25", ff = fonts .. "signature.ttf", a = "high" }
}

return Layouts
