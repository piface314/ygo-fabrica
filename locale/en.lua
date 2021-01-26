return {
  en = {
    bad_argument = 'bad argument `%{arg}` to %{caller} (%{exp} expected, got %{got})',
    bad_argument_i = 'bad argument #%{arg} to %{caller} (%{exp} expected, got %{got})',
    nil_argument = 'bad argument `%{arg}` to %{caller} (value expected)',
    nil_argument_i = 'bad argument #%{arg} to %{caller} (value expected)',
    interpreter = {
      invalid_command = 'invalid command %q',
      invalid_flag = 'invalid flag %q',
      missing_flag_args = 'not enough arguments for %q flag'
    },
    logs = {err = 'ERROR', ok = 'OK'},
    codes = {
      attribute = {
        EARTH = 'EARTH',
        WATER = 'WATER',
        FIRE = 'FIRE',
        WIND = 'WIND',
        LIGHT = 'LIGHT',
        DARK = 'DARK',
        DIVINE = 'DIVINE'
      },
      race = {
        WARRIOR = 'Warrior',
        SPELLCASTER = 'Spellcaster',
        FAIRY = 'Fairy',
        FIEND = 'Fiend',
        ZOMBIE = 'Zombie',
        MACHINE = 'Machine',
        AQUA = 'Aqua',
        PYRO = 'Pyro',
        ROCK = 'Rock',
        WINGED_BEAST = 'Winged Beast',
        PLANT = 'Plant',
        INSECT = 'Insect',
        THUNDER = 'Thunder',
        DRAGON = 'Dragon',
        BEAST = 'Beast',
        BEAST_WARRIOR = 'Beast-Warrior',
        DINOSAUR = 'Dinosaur',
        FISH = 'Fish',
        SEA_SERPENT = 'Sea Serpent',
        REPTILE = 'Reptile',
        PSYCHIC = 'Psychic',
        DIVINE_BEAST = 'Divine-Beast',
        CREATOR_GOD = 'Creator God',
        WYRM = 'Wyrm',
        CYBERSE = 'Cyberse'
      },
      type = {
        SPELL = {
          attribute = 'SPELL',
          label = {
            normal = '<t=2><r=2>[</> Spell Card <r=2>]</></>',
            other = '<t=2><r=2>[</> Spell Card    <r=2>]</></>'
          }
        },
        TRAP = {
          attribute = 'TRAP',
          label = {
            normal = '<t=2><r=2>[</> Trap Card <r=2>]</></>',
            other = '<t=2><r=2>[</> Trap Card    <r=2>]</></>'
          }
        },
        NORMAL = 'Normal',
        EFFECT = 'Effect',
        FUSION = 'Fusion',
        RITUAL = 'Ritual',
        SPIRIT = 'Spirit',
        UNION = 'Union',
        GEMINI = 'Gemini',
        TUNER = 'Tuner',
        SYNCHRO = 'Synchro',
        TOKEN = 'Token',
        FLIP = 'Flip',
        TOON = 'Toon',
        XYZ = 'Xyz',
        PENDULUM = 'Pendulum',
        LINK = 'Link'
      }
    },
    config = {
      globals = 'Global configurations:',
      locals = 'Local configurations:',
      none = 'no %s has been configured',
      missing = '%q has not been configured'
    },
    compose = {
      status = 'Composing %q with %q...',
      output_conflict = 'output folder cannot be the same as artwork folder',
      unknown_mode = 'unknown mode %q',
      decode_fail = 'failed at decoding %q: ',
      decoding = 'Decoding %q...',
      rendering = 'Rendering %q...',
      printing = 'Printing %q...',
      done = 'Done!',
      data_fetcher = {
        no_img_folder = 'missing image folder',
        closed_db = 'nil or closed card database',
        read_db_fail = 'failed to read card database'
      },
      decoder = {
        state_key_err = '%s not found in states',
        unknown_error = 'unknown error in state %q',
        error = 'error in %q state: ',
        not_layer = 'bad return value #%{arg} (expected Layer, got %{got})'
      },
      modes = {
        anime = {
          no_card_type = 'missing card type'
        },
        proxy = {
          no_card_type = 'missing card type',
          copyright = '<t=2><s=5>©</>%{year}</> %{author}',
          default_author = 'KAZUKI TAKAHASHI',
          typedesc = '<t=2><r=2>[</>%s<r=2>]</></>',
          edition = '1<r=7.2 s=3>st</> Edition',
          forbidden = '<t=3>This card cannot be in a Deck.</>'
        }
      }
    },
    export = {
      status = 'Exporting %q with %q...',
      zip_create_error = 'while creating .zip:',
      zip_add_error = {
        one = 'This files was not zipped:',
        other = '%{count} files were not zipped:'
      },
      scan_scripts = 'Looking for scripts...',
      scan_pics = 'Looking for card pics...',
      scan_fields = 'Looking for field backgrounds...',
      file_srcdst = '%q -> %q',
      done = 'Done!'
    },
    make = {
      recipe_not_list = '"recipe" must be a list of file names',
      status = 'Making %q card database...',
      done = 'Done!',
      data_fetcher = {toml_error = 'while parsing .toml:'},
      encoder = {
        pendulum_effect = 'Pendulum Effect',
        monster_effect = 'Monster Effect',
        flavor_text = 'Flavor Text'
      },
      parser = {cyclic_macro = '%q: cyclic macro'},
      writer = {
        create_error = 'error code %s while creating .cdb',
        write_error = 'error code %s while writing .cdb',
        clean_error = 'error code %s while cleaning .cdb',
        strings = 'Writing strings.conf...',
        strings_fail = 'failed writing strings.conf'
      }
    },
    new = {
      no_name = 'no name was provided for new project',
      invalid_name = 'invalid project name',
      create_folder = 'Creating %q folder...',
      create_cdb = 'Creating card database...',
      create_config = 'Creating config.toml...',
      config_comment = [[
# Use this to define local configurations for your project.
# Any configuration defined here will override its global counterpart.
# Global configurations are located in `%s`.]],
      done = 'Project %q successfully created!'
    },
    sync = {
      status = 'Syncing %q and %q to %q...',
      writing_string = 'Writing strings.conf...',
      done = 'Done!'
    },
    ygofab = {
      usage = 'Usage:\
  $ ygofab <command> [options]\
\
Available commands:\
  compose\tGenerates card pics\
  config \tShows current configurations\
  export \tExports your project to a .zip file\
  make   \tConverts card description in .toml into a .cdb\
  new    \tCreates a new project, given a name\
  sync   \tCopies your project files to YGOPro game',
      not_in_project = 'It looks like you\'re not in a project folder...',
      invalid_command = 'not a valid command'
    },
    ygopic = {
      usage = 'Usage:\
\
  $ ygopic <mode> <art-folder> <card-database> <output-folder> [options]\
\
Arguments:\
\
  mode          \tEither `anime` or `proxy`\
  art-folder    \tPath to a folder containing artwork for the cards\
  card-database \tPath to a .cdb describing each card\
  output-folder \tPath to a folder that will contain output images\
\
Available options:\
\
  --size WxH        \tW and H determines width and height of the output\
                    \timages. If only W or H is specified, aspect ratio\
                    \tis preserved. Example: `--size 800x` will output\
                    \timages in 800px in width, keeping aspect ratio.\
                    \tDefaults to original size.\
\
  --ext <ext>       \tSpecifies which extension is used for output,\
                    \teither `png`, `jpg` or `jpeg`. Defaults to `jpg`.\
\
  --artsize <mode>  \tSpecifies how artwork is fitted into the artbox,\
                    \teither `cover`, `contain` or `fill`.\
                    \tDefaults to `cover`.\
\
  --year <year>     \tSpecifies an year to be used in `proxy` mode in\
                    \tthe copyright line. Defaults to `1996`.\
\
  --author <author> \tSpecifies an author to be used in `proxy` mode in\
                    \tthe copyright line. Defaults to `KAZUKI TAKAHASHI`.\
\
  --field           \tEnables the generation of field background images.\
\
  --color-* <color> \tChanges the color used for card names in `proxy`\
                    \tmode, according to the card type (*). <color>\
                    \tmust be a color string in hex format.\
                    \tE.g., `--color-effect "#ffffff"` specifies white\
                    \tfor Effect Monsters card name.',
      missing_mode = 'please specify <mode>',
      missing_imgfolder = 'please specify <art-folder>',
      missing_cdbfp = 'please specify <card-database>',
      missing_outfolder = 'please specify <output-folder>'
    }
  }
}
