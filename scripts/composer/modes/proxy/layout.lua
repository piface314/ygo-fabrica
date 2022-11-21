local Fonts = require 'res.composer.fonts'

return {
  art = {
    regular = {x = 98, y = 217, w = 617, h = 617},
    pendulum = {
      m = {
        o = {x = 52, y = 213, w = 708, h = 526},
        t = {x = 52, y = 213, w = 708, h = 667}
      },
      s = {
        o = {x = 52, y = 213, w = 708, h = 568},
        t = {x = 52, y = 213, w = 708, h = 667}
      }
    }
  },
  attribute = {
    x = 720, y = 57, w = 80,
    f = Fonts.get_family('monster_desc', 3.5),
    ff = Fonts.get_file('monster_desc'),
    a = 'center'
  },
  att_icon = { cx = 720, cy = 90, w = 80, h = 80 },
  st_icon = { x = 672, y = 151, w = 43, h = 43 },
  level_stars = { x = 675, y = 142, w = 53, h = 53, sp = 1 },
  rank_stars = { x = 82, y = 142, w = 53, h = 53, sp = 1, dx = -25 },
  name = {
    x = 63, y = 63, w = 600,
    f = Fonts.get_family('card_name', 24),
    ff = Fonts.get_file('card_name'),
    a = 'left'
  },
  spelltrap_label = {
    x = 730, y = 152, w = 469,
    f = Fonts.get_family('monster_desc', 10),
    ff = Fonts.get_file('monster_desc'),
    a = 'right'
  },
  lscale = {
    m = {
      x = 82, y = 814, w = 49,
      f = Fonts.get_family('values', 14),
      ff = Fonts.get_file('values'),
      a = 'center'
    },
    s = {
      x = 82, y = 837, w = 49,
      f = Fonts.get_family('values', 14),
      ff = Fonts.get_file('values'),
      a = 'center'
    }
  },
  rscale = {
    m = {
      x = 730, y = 814, w = 49,
      f = Fonts.get_family('values', 14),
      ff = Fonts.get_file('values'),
      a = 'center'
    },
    s = {
      x = 730, y = 837, w = 49,
      f = Fonts.get_family('values', 14),
      ff = Fonts.get_file('values'),
      a = 'center'
    }
  },
  pendulum_effect = {
    m = {
      x = 128, y = 754, w = 554, h = 119, j = true,
      fs = {6, 5, 4, 3.5},
      ft = Fonts.get_family('effect'),
      ff = Fonts.get_file('effect'),
      a = 'left'
    },
    s = {
      x = 128, y = 796, w = 554, h = 80, j = true,
      fs = {6, 5},
      ft = Fonts.get_family('effect'),
      ff = Fonts.get_file('effect'),
      a = 'left'
    }
  },
  monster_desc = {
    x = 63, y = 897, w = 685,
    f = Fonts.get_family('monster_desc', 8),
    ff = Fonts.get_file('monster_desc'),
    a = 'left'
  },
  flavor_text = {
    x = 62, y = 934, w = 687, h = 145, j = true,
    fs = {6, 5, 4},
    ft = Fonts.get_family('flavor_text'),
    ff = Fonts.get_file('flavor_text'),
    a = 'left'
  },
  monster_effect = {
    x = 62, y = 934, w = 687, h = 145, j = true,
    fs = {6, 5, 4.5, 4, 3.8, 3.6},
    ft = Fonts.get_family('effect'),
    ff = Fonts.get_file('effect'),
    a = 'left'
  },
  spelltrap_effect = {
    x = 62, y = 897, w = 687, h = 211, j = true,
    fs = {6, 5, 4.5, 4},
    ft = Fonts.get_family('effect'),
    ff = Fonts.get_file('effect'),
    a = 'left'
  },
  atk_label = {
    x = 442, y = 1085,
    f = Fonts.get_family('values', 8.5),
    ff = Fonts.get_file('values'),
    a = 'left'
  },
  atk = {
    x = 586, y = 1085,
    f = Fonts.get_family('values', 8.5),
    ff = Fonts.get_file('values'),
    a = 'right'
  },
  atk_q = {
    x = 586, y = 1085, w = 15, h = 24,
    f = Fonts.get_family('values', 14),
    ff = Fonts.get_file('values'),
    a = 'right'
  },
  def_label = {
    x = 610, y = 1085,
    f = Fonts.get_family('values', 8.5),
    ff = Fonts.get_file('values'),
    a = 'left'
  },
  def = {
    x = 750, y = 1085,
    f = Fonts.get_family('values', 8.5),
    ff = Fonts.get_file('values'),
    a = 'right'
  },
  def_q = {
    x = 750, y = 1085, w = 13, h = 14,
    f = Fonts.get_family('values', 14),
    ff = Fonts.get_file('values'),
    a = 'right'
  },
  link_label = {
    x = 720, y = 1085,
    f = Fonts.get_family('link_rating', 7.5),
    ff = Fonts.get_file('link_rating'),
    a = 'right'
  },
  link_rating = {
    x = 749, y = 1085,
    f = Fonts.get_family('link_rating', 7.5),
    ff = Fonts.get_file('link_rating'),
    a = 'right'
  },
  link_arrows = {
    n = {
      [64] = {x = 65, y = 186}, [128] = {x = 327, y = 170}, [256] = {x = 674, y = 186},
      [8]  = {x = 51, y = 447},                             [32]  = {x = 715, y = 447},
      [1]  = {x = 65, y = 793}, [2]   = {x = 327, y = 834}, [4]   = {x = 674, y = 793}
    },
    s = {
      [64] = {x = 43, y = 203}, [128] = {x = 327, y = 195}, [256] = {x = 697, y = 203},
      [8]  = {x = 36, y = 415},                             [32]  = {x = 729, y = 415},
      [1]  = {x = 42, y = 711}, [2]   = {x = 327, y = 744}, [4]   = {x = 696, y = 711}
    },
    m = {
      [64] = {x = 43, y = 203}, [128] = {x = 327, y = 195}, [256] = {x = 697, y = 203},
      [8]  = {x = 36, y = 394},                             [32]  = {x = 729, y = 394},
      [1]  = {x = 42, y = 669}, [2]   = {x = 327, y = 702}, [4]   = {x = 696, y = 669}
    }
  },
  setnumber = {
    regular = {
      x = 727, y = 856, w = 211,
      f = Fonts.get_family('signature', 5.3),
      ff = Fonts.get_file('signature'),
      a = 'right'
    },
    link = {
      x = 668, y = 856, w = 211,
      f = Fonts.get_family('signature', 5.3),
      ff = Fonts.get_file('signature'),
      a = 'right'
    },
    pendulum = {
      x = 63, y = 1089, w = 211,
      f = Fonts.get_family('signature', 5.3),
      ff = Fonts.get_file('signature'),
      a = 'left'
    }
  },
  edition = {
    low = {
      x = 170, y = 1132, w = 269,
      f = Fonts.get_family('edition', 6),
      ff = Fonts.get_file('edition')
    },
    high = {
      x = 88, y = 855, w = 269,
      f = Fonts.get_family('edition', 5.8),
      ff = Fonts.get_file('edition')
    }
  },
  forbidden = {
    x = 37, y = 1135, w = 410,
    f = Fonts.get_family('signature', 5.3),
    ff = Fonts.get_file('signature'),
    a = 'left'
  },
  serial_code = {
    x = 37, y = 1133, w = 141,
    f = Fonts.get_family('signature', 5.3),
    ff = Fonts.get_file('signature'),
    a = 'left'
  },
  copyright = {
    x = 738, y = 1133, w = 305,
    f = Fonts.get_family('signature', 5),
    ff = Fonts.get_file('signature'),
    a = 'right'
  },
  holo = { x = 746, y = 1118, w = 45, h = 45 }
}
