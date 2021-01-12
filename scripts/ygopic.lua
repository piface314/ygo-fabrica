local Interpreter = require 'lib.interpreter'
local Logs = require 'lib.logs'
local Version = require 'lib.version'
local Locale = require 'locale'
local Config = require 'scripts.config'
local i18n = require 'lib.i18n'

local function assert_help(assertion, msg)
  Logs.assert(assertion, msg, '\n', i18n 'ygopic.usage')
end

local function run(flags, mode, imgfolder, cdbfp, outfolder)
  if flags['--version'] or flags['-v'] then
    return Logs.info(Version.formatted())
  end
  local Composer = require 'scripts.composer.composer'
  assert_help(mode, i18n 'ygopic.missing_mode')
  assert_help(imgfolder, i18n 'ygopic.missing_imgfolder')
  assert_help(cdbfp, i18n 'ygopic.missing_cdbfp')
  assert_help(outfolder, i18n 'ygopic.missing_outfolder')
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

Locale.set(Config.get('locale'))
local errmsg = interpreter:exec(...)
assert_help(not errmsg, errmsg)

