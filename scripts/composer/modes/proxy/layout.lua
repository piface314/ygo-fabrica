local Fonts = require 'res.composer.fonts'

return {
  art = {
    regular = {x = 83, y = 185, w = 528, h = 528},
    pendulum = {
      m = {
        o = {x = 45, y = 182, w = 603, h = 448},
        t = {x = 45, y = 182, w = 603, h = 569}
      },
      s = {
        o = {x = 45, y = 182, w = 603, h = 484},
        t = {x = 45, y = 182, w = 603, h = 569}
      }
    }
  },
  attribute = {
    x = 614, y = 49, w = 68,
    f = Fonts.get_family('monster_desc', 3),
    ff = Fonts.get_file('monster_desc'),
    a = 'center'
  },
  name = {
    x = 54, y = 54, w = 512,
    f = Fonts.get_family('card_name', 20),
    ff = Fonts.get_file('card_name'),
    a = 'left'
  },
  spelltrap_label = {
    x = 623, y = 131, w = 400,
    f = Fonts.get_family('monster_desc', 8.5),
    ff = Fonts.get_file('monster_desc'),
    a = 'right'
  },
  lscale = {
    m = {
      x = 70, y = 695, w = 42,
      f = Fonts.get_family('values', 12),
      ff = Fonts.get_file('values'),
      a = 'center'
    },
    s = {
      x = 70, y = 715, w = 42,
      f = Fonts.get_family('values', 12),
      ff = Fonts.get_file('values'),
      a = 'center'
    }
  },
  rscale = {
    m = {
      x = 623, y = 695, w = 42,
      f = Fonts.get_family('values', 12),
      ff = Fonts.get_file('values'),
      a = 'center'
    },
    s = {
      x = 623, y = 715, w = 42,
      f = Fonts.get_family('values', 12),
      ff = Fonts.get_file('values'),
      a = 'center'
    }
  },
  pendulum_effect = {
    m = {
      x = 109, y = 644, w = 475, h = 102, j = true,
      fs = {5, 4, 3.5},
      ft = Fonts.get_family('effect'),
      ff = Fonts.get_file('effect'),
      a = 'left'
    },
    s = {
      x = 109, y = 680, w = 475, h = 68, j = true,
      fs = {5},
      ft = Fonts.get_family('effect'),
      ff = Fonts.get_file('effect'),
      a = 'left'
    }
  },
  monster_desc = {
    x = 54, y = 766, w = 585,
    f = Fonts.get_family('monster_desc', 6.5),
    ff = Fonts.get_file('monster_desc'),
    a = 'left'
  },
  flavor_text = {
    x = 53, y = 794, w = 588, h = 126, j = true,
    fs = {5, 4},
    ft = Fonts.get_family('flavor_text'),
    ff = Fonts.get_file('flavor_text'),
    a = 'left'
  },
  monster_effect = {
    x = 53, y = 795, w = 588, h = 125, j = true,
    fs = {5, 4.5, 4, 3.8, 3.6},
    ft = Fonts.get_family('effect'),
    ff = Fonts.get_file('effect'),
    a = 'left'
  },
  spelltrap_effect = {
    x = 53, y = 766, w = 585, h = 180, j = true,
    fs = {5, 4.5, 4},
    ft = Fonts.get_family('effect'),
    ff = Fonts.get_file('effect'),
    a = 'left'
  },
  atk = {
    x = 500, y = 927,
    f = Fonts.get_family('values', 7.25),
    ff = Fonts.get_file('values'),
    a = 'right'
  },
  atk_q = {
    x = 500, y = 927, w = 13, h = 19,
    f = Fonts.get_family('values', 12),
    ff = Fonts.get_file('values'),
    a = 'right'
  },
  def = {
    x = 640, y = 927,
    f = Fonts.get_family('values', 7.25),
    ff = Fonts.get_file('values'),
    a = 'right'
  },
  def_q = {
    x = 640, y = 927, w = 13, h = 19,
    f = Fonts.get_family('values', 12),
    ff = Fonts.get_file('values'),
    a = 'right'
  },
  link_rating = {
    x = 639, y = 927,
    f = Fonts.get_family('link_rating', 6.5),
    ff = Fonts.get_file('link_rating'),
    a = 'right'
  },
  setnumber = {
    regular = {
      x = 621, y = 731, w = 180,
      f = Fonts.get_family('signature', 4.5),
      ff = Fonts.get_file('signature'),
      a = 'right'
    },
    link = {
      x = 570, y = 731, w = 180,
      f = Fonts.get_family('signature', 4.5),
      ff = Fonts.get_file('signature'),
      a = 'right'
    },
    pendulum = {
      x = 54, y = 930, w = 180,
      f = Fonts.get_family('signature', 4.5),
      ff = Fonts.get_file('signature'),
      a = 'left'
    }
  },
  edition = {
    low = {
      x = 145, y = 967, w = 230,
      f = Fonts.get_family('edition', 5),
      ff = Fonts.get_file('edition')
    },
    high = {
      x = 75, y = 730, w = 230,
      f = Fonts.get_family('edition', 4.8),
      ff = Fonts.get_file('edition')
    }
  },
  forbidden = {
    x = 32, y = 969, w = 350,
    f = Fonts.get_family('signature', 4.5),
    ff = Fonts.get_file('signature'),
    a = 'left'
  },
  serial_code = {
    x = 32, y = 968, w = 120,
    f = Fonts.get_family('signature', 4.5),
    ff = Fonts.get_file('signature'),
    a = 'left'
  },
  copyright = {
    x = 631, y = 968, w = 260,
    f = Fonts.get_family('signature', 4.25),
    ff = Fonts.get_file('signature'),
    a = 'right'
  }
}
