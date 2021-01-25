local Fonts = require 'res.composer.fonts'

return {
  art = {x = 13, y = 14, w = 544, h = 582, blur = 4},
  atk = {
    x = 234, y = 725, w = 157, h = 48,
    f = Fonts.get_family('values', 18.7),
    ff = Fonts.get_file('values'),
    a = 'right'
  },
  def = {
    x = 493, y = 725, w = 157, h = 48,
    f = Fonts.get_family('values', 18.7),
    ff = Fonts.get_file('values'),
    a = 'right'
  },
  lsc = {
    x = 180, y = 543, w = 75,
    f = Fonts.get_family('values', 20),
    ff = Fonts.get_file('values'),
    a = 'center'
  },
  rsc = {
    x = 390, y = 543, w = 75,
    f = Fonts.get_family('values', 20),
    ff = Fonts.get_file('values'),
    a = 'center'
  },
  lkr = {
    x = 450, y = 732, w = 52,
    f = Fonts.get_family('link_rating', 12.5),
    ff = Fonts.get_file('link_rating'),
    a = 'left'
  }
}
