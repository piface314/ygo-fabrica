local path = require 'path'
local Interpreter = require 'lib.interpreter'
local Logs = require 'lib.logs'
local Info = require 'lib.info'


local PWD = arg[1]
local interpreter

local function assert_help(assertion, msg)
  Logs.assert(assertion, 1, msg, "\n",
    "Usage:\n\n",
    "  $ ygopic <mode> <art-folder> <card-database> <output-folder> [options]\n\n",
    "Arguments:\n\n",
    "  mode          \tEither `anime` or `proxy`\n",
    "  art-folder    \tPath to a folder containing artwork for the cards\n",
    "  card-database \tPath to a .cdb describing each card\n",
    "  output-folder \tPath to a folder that will contain output images\n\n",
    "Available options:\n\n",
    "  --size WxH       \tW and H determines width and height of the output\n",
    "                   \timages. If only W or H is specified, aspect ratio\n",
    "                   \tis preserved. Example: `--size 800x` will output\n",
    "                   \timages in 800px in width, keeping aspect ratio.\n",
    "                   \tDefaults to original size\n\n",
    "  --ext <ext>      \tSpecifies which extension is used for output,\n",
    "                   \teither `png`, `jpg` or `jpeg`. Defaults to `jpg`\n\n",
    "  --artsize <mode> \tSpecifies how artwork is fitted into the artbox,\n",
    "                   \teither `cover`, `contain` or `fill`.\n",
    "                   \tDefaults to `cover`\n\n",
    "  --year <year>    \tSpecifies an year to be used in `proxy` mode in\n",
    "                   \tthe copyright line. Defaults to `1996`\n\n",
    "  --author <author>\tSpecifies an author to be used in `proxy` mode in\n",
    "                   \tthe copyright line. Defaults to `KAZUKI TAKAHASHI`\n\n",
    "  --field          \tEnables the generation of field background images\n\n",
    "  --color-* <color>\tChanges the color used for card names in `proxy`\n",
    "                   \tmode, according to the card type (*). <color>\n",
    "                   \tmust be a color string in hex format.\ns",
    "                   \tE.g., `--color-effect \"#ffffff\"` specifies white\n",
    "                   \tfor Effect Monsters card name."
  )
end

local function run(flags, mode, imgfolder, cdbfp, outfolder)
  if flags['--version'] or flags['-v'] then
    return Logs.info(Info.get_version())
  end
  local Composer = require 'scripts.composer.composer'
  assert_help(mode, "Please specify <mode>")
  assert_help(imgfolder, "Please specify <art-folder>")
  assert_help(cdbfp, "Please specify <card-database>")
  assert_help(outfolder, "Please specify <output-folder>")
  imgfolder = path.join(PWD, imgfolder)
  cdbfp = path.join(PWD, cdbfp)
  outfolder = path.join(PWD, outfolder)
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
  for k, o in pairs(options) do options[k] = o[1] end
  Composer.compose(mode or "", imgfolder, cdbfp, outfolder, options)
end

local function init_interpreter()
  interpreter = Interpreter.new()
  interpreter:add_command("", run, "--size", 1, "--ext", 1, "--artsize", 1,
    "--year", 1, "--author", 1, "--field", 0, "--color-normal", 1, "--color-effect", 1,
    "--color-fusion", 1, "--color-ritual", 1, "--color-synchro", 1, "--color-token", 1,
    "--color-xyz", 1, "--color-link", 1, "--color-spell", 1, "--color-trap", 1,
    "--version", 0, "-v", 0)
end

init_interpreter()
local errmsg, cmd, args, flags = interpreter:parse(unpack(arg, 2))
assert_help(not errmsg, errmsg)
interpreter:exec(cmd, args, flags)
