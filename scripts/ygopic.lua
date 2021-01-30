local Interpreter = require 'lib.interpreter'
local Logs = require 'lib.logs'
local Version = require 'lib.version'
local Locale = require 'locale'
local Config = require 'scripts.config'
local i18n = require 'i18n'
local fun = require 'lib.fun'

local function assert_help(assertion, msg, verbose)
  if assertion then return end
  local args = fun(1, 4):map(fun 'i -> "ygopic.usage.arguments.arg" .. i')
    :map(function(k) return {'  ' .. i18n(k .. '.id'), i18n(k .. '.desc')} end)
  args = Logs.tabular({20, 50}, args)
  local usage = {
    i18n 'ygopic.usage.header', '\n  ', i18n 'ygopic.usage.cmd', '\n\n',
    i18n 'ygopic.usage.help', '\n\n', i18n 'ygopic.usage.arguments.header',
    '\n', unpack(args)
  }
  if verbose then
    local opts = fun(1, 7):map(fun 'i -> "ygopic.usage.options.opt" .. i')
      :map(function(k) return {'  ' .. i18n(k .. '.label'), i18n(k .. '.desc')} end)
    opts = Logs.tabular({20, 50}, opts, {in_newline = true})
    usage = usage .. fun {'\n\n', i18n 'ygopic.usage.options.header', '\n'} .. opts
  end
  Logs.assert(false, msg, '\n', unpack(usage))
end

local function run(flags, mode, imgfolder, cdbfp, outfolder)
  if flags['--version'] or flags['-v'] then return Logs.info(Version.formatted()) end
  local Composer = require 'scripts.composer'
  local help = flags['--help']
  assert_help(mode, i18n 'ygopic.missing_mode', help)
  assert_help(imgfolder, i18n 'ygopic.missing_imgfolder', help)
  assert_help(cdbfp, i18n 'ygopic.missing_cdbfp', help)
  assert_help(outfolder, i18n 'ygopic.missing_outfolder', help)
  local options = {}
  for k, v in pairs(flags) do options[k:match('^%-%-(.*)$')] = v[1] or true end
  local holo = flags['--holo'] and flags['--holo'][1]
  options.holo = (holo == 'false' or holo == '0') and 0 or 1
  Composer.compose(mode, imgfolder, cdbfp, outfolder, options)
end

local interpreter = Interpreter.new()
interpreter:add_command('', run, '--size', 1, '--ext', 1, '--artsize', 1, '--year',
  1, '--author', 1, '--field', 0, '--color-normal', 1, '--color-effect', 1,
  '--color-fusion', 1, '--color-ritual', 1, '--color-synchro', 1, '--color-token', 1,
  '--color-xyz', 1, '--color-link', 1, '--color-spell', 1, '--color-trap', 1,
  '--holo', 1, '--locale', 1, '--version', 0, '-v', 0, '--verbose', 0, '--help', 0)

Locale.set(Config.get('locale'))
local errmsg = interpreter:exec(...)
assert_help(not errmsg, errmsg)

