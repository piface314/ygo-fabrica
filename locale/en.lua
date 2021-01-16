return {
  en = {
    interpreter = {
      invalid_command = 'invalid command %q',
      invalid_flag = 'invalid flag %q',
      missing_flag_args = 'not enough arguments for %q flag'
    },
    logs = {err = 'ERROR', ok = 'OK'},
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
      generating = 'Generating %q...',
      done = 'Done!',
      data_fetcher = {
        no_img_folder = 'missing image folder',
        closed_db = 'nil or closed card database',
        read_db_fail = 'failed to read card database'
      },
      decoder = {
        no_monster_type = 'missing monster type',
        no_card_type = 'missing card type'
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
      encoder = {
        pendulum_effect = 'Pendulum Effect',
        monster_effect = 'Monster Effect',
        flavor_text = 'Flavor Text'
      },
      parser = {
        cyclic_macro = '%q: cyclic macro',
      },
      writer = {
        write_error = 'error code %s while writing .cdb',
        clean_error = 'error code %s while cleaning .cdb'
      }
    },
    new = {
      no_name = 'no name was provided for new project',
      invalid_name = 'invalid project name',
      create_folder = 'Creating %q folder...',
      create_cdb = 'Creating card database...',
      create_config = 'Creating config.toml...',
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
      invalid_command = 'not a valid command',
    },
    ygopic = {
      usage = "Usage:\
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
                    \tE.g., `--color-effect \"#ffffff\"` specifies white\
                    \tfor Effect Monsters card name.",
      missing_mode = "please specify <mode>",
      missing_imgfolder = "please specify <art-folder>",
      missing_cdbfp = "please specify <card-database>",
      missing_outfolder = "please specify <output-folder>"
    }
  }
}
