local Interpreter = require 'lib.interpreter'
local Logs = require 'lib.logs'
local Version = require 'lib.version'


local function assert_help(assertion, msg)
  Logs.assert(assertion, 1, msg,
"Usage:\
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
  --size WxH       \tW and H determines width and height of the output\
                   \timages. If only W or H is specified, aspect ratio\
                   \tis preserved. Example: `--size 800x` will output\
                   \timages in 800px in width, keeping aspect ratio.\
                   \tDefaults to original size\
\
  --ext <ext>      \tSpecifies which extension is used for output,\
                   \teither `png`, `jpg` or `jpeg`. Defaults to `jpg`\
\
  --artsize <mode> \tSpecifies how artwork is fitted into the artbox,\
                   \teither `cover`, `contain` or `fill`.\
                   \tDefaults to `cover`\
\
  --year <year>    \tSpecifies an year to be used in `proxy` mode in\
                   \tthe copyright line. Defaults to `1996`\
\
  --author <author>\tSpecifies an author to be used in `proxy` mode in\
                   \tthe copyright line. Defaults to `KAZUKI TAKAHASHI`\
\
  --field          \tEnables the generation of field background images\
\
  --color-* <color>\tChanges the color used for card names in `proxy`\
                   \tmode, according to the card type (*). <color>\
                   \tmust be a color string in hex format.\
                   \tE.g., `--color-effect \"#ffffff\"` specifies white\
                   \tfor Effect Monsters card name."
  )
end

local function run(flags, mode, imgfolder, cdbfp, outfolder)
  if flags['--version'] or flags['-v'] then
    return Logs.info(Version.formatted())
  end
  local Composer = require 'scripts.composer.composer'
  assert_help(mode, "Please specify <mode>")
  assert_help(imgfolder, "Please specify <art-folder>")
  assert_help(cdbfp, "Please specify <card-database>")
  assert_help(outfolder, "Please specify <output-folder>")
  local options = {
    year = flags["--year"],
    author = flags["--author"],
    ext = flags["--ext"],
    size = flags["--size"],
    artsize = flags["--artsize"],
    field = flags["--field"],
    ["color-normal"] = flags["--color-normal"],
    ["color-effect"] = flags["--color-effect"],
    ["color-fusion"] = flags["--color-fusion"],
    ["color-ritual"] = flags["--color-ritual"],
    ["color-synchro"] = flags["--color-synchro"],
    ["color-token"] = flags["--color-token"],
    ["color-xyz"] = flags["--color-xyz"],
    ["color-link"] = flags["--color-link"],
    ["color-spell"] = flags["--color-spell"],
    ["color-trap"] = flags["--color-trap"]
  }
  for k, o in pairs(options) do
    options[k] = o[1]
  end
  Composer.compose(mode or "", imgfolder, cdbfp, outfolder, options)
end


local interpreter = Interpreter.new()
interpreter:add_command("", run, "--size", 1, "--ext", 1, "--artsize", 1,
  "--year", 1, "--author", 1, "--field", 0, "--color-normal", 1, "--color-effect", 1,
  "--color-fusion", 1, "--color-ritual", 1, "--color-synchro", 1, "--color-token", 1,
  "--color-xyz", 1, "--color-link", 1, "--color-spell", 1, "--color-trap", 1,
  "--version", 0, "-v", 0)

local errmsg = interpreter:exec(...)
assert_help(not errmsg, errmsg)

