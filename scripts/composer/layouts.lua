local path = require 'lib.fs'.path
local Fonts = require 'scripts.composer.fonts'


Fonts.path = path.normalize(path.getproot()) .. '/' .. Fonts.path
local Layouts = {}

Layouts.field = { x = 0, y = 0, w = 512, h = 512 }

Layouts.anime = {
  art = { x = 13, y = 14, w = 544, h = 582, blur = 4 },
  atk = { x = 234, y = 725, w = 157, h = 48,
    f = Fonts.get_family("values", "18.7"), ff = Fonts.get_file("values"), a = "high" },
  def = { x = 493, y = 725, w = 157, h = 48,
    f = Fonts.get_family("values", "18.7"), ff = Fonts.get_file("values"), a = "high" },
  lsc = { x = 180, y = 543, w = 75,
    f = Fonts.get_family("values", "20"), ff = Fonts.get_file("values"), a = "centre" },
  rsc = { x = 390, y = 543, w = 75,
    f = Fonts.get_family("values", "20"), ff = Fonts.get_file("values"), a = "centre" },
  lkr = { x = 450, y = 732, w = 52,
    f = Fonts.get_family("link_rating", "12.5"), ff = Fonts.get_file("link_rating"), a = "low" }
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
    f = Fonts.get_family("card_name", "20"), ff = Fonts.get_file("card_name"), a = "low" },

  lscale = {
    m = { x = 70, y = 695, w = 42,
      f = Fonts.get_family("values", "12"), ff = Fonts.get_file("values"), a = "centre" },
    s = { x = 70, y = 715, w = 42,
      f = Fonts.get_family("values", "12"), ff = Fonts.get_file("values"), a = "centre" }
  },

  rscale = {
    m = { x = 623, y = 695, w = 42,
      f = Fonts.get_family("values", "12"), ff = Fonts.get_file("values"), a = "centre" },
    s = { x = 623, y = 715, w = 42,
      f = Fonts.get_family("values", "12"), ff = Fonts.get_file("values"), a = "centre" }
  },

  pendulum_effect = {
    m = { x = 109, y = 644, w = 475, h = 102, j = true, fs = { 5, 4, 3.5 },
      ft = Fonts.get_family("effect"), ff = Fonts.get_file("effect"), a = "low" },
    s = { x = 109, y = 680, w = 475, h = 68, j = true, fs = { 5 },
      ft = Fonts.get_family("effect"), ff = Fonts.get_file("effect"), a = "low" }
  },

  monster_desc = { x = 54, y = 766, w = 585,
    f = Fonts.get_family("monster_desc", "6.5"), ff = Fonts.get_file("monster_desc"), a = "low" },

  flavor_text = { x = 53, y = 794, w = 588, h = 126, j = true, fs = { 5, 4 },
    ft = Fonts.get_family("flavor_text"), ff = Fonts.get_file("flavor_text"), a = "low" },

  monster_effect = { x = 53, y = 795, w = 588, h = 125, j = true, fs = { 5, 4.5, 4, 3.8, 3.6 },
    ft = Fonts.get_family("effect"), ff = Fonts.get_file("effect"), a = "low" },

  spelltrap_effect = { x = 53, y = 766, w = 585, h = 180, j = true, fs = { 5, 4.5, 4 },
    ft = Fonts.get_family("effect"), ff = Fonts.get_file("effect"), a = "low" },

  atk = { x = 500, y = 927,
    f = Fonts.get_family("values", "7.25"), ff = Fonts.get_file("values"), a = "high" },

  atk_u = { x = 500, y = 927, w = 13, h = 19,
    f = Fonts.get_family("values", "12"), ff = Fonts.get_file("values"), a = "high" },

  def = { x = 640, y = 927,
    f = Fonts.get_family("values", "7.25"), ff = Fonts.get_file("values"), a = "high" },

  def_u = { x = 640, y = 927, w = 13, h = 19,
    f = Fonts.get_family("values", "12"), ff = Fonts.get_file("values"), a = "high" },

  link_rating = { x = 639, y = 927,
    f = Fonts.get_family("link_rating", "6.5"), ff = Fonts.get_file("link_rating"), a = "high" },

  serial_code = { x = 32, y = 968, w = 120,
    f = Fonts.get_family("signature", "4.5"), ff = Fonts.get_file("signature"), a = "low" },

  copyright = { x = 631, y = 968, w = 260,
    f = Fonts.get_family("signature", "4.25"), ff = Fonts.get_file("signature"), a = "high" }
}

return Layouts
