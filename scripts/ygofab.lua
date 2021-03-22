require 'lib.table'
local Interpreter = require 'lib.interpreter'
local Logs = require 'lib.logs'
local Version = require 'lib.version'
local path = require 'lib.path'
local Locale = require 'locale'
local Config = require 'scripts.config'
local i18n = require 'i18n'
local fun = require 'lib.fun'

local function print_header() Logs.info(require 'lib.header') end

local function display_help(msg)
  local commands = fun.range(1, 6)
    :map(function(i) return 'ygofab.usage.commands.cmd' .. i end)
    :map(function(k) return {'  ' .. i18n(k .. '.id') .. '  ', i18n(k .. '.desc')} end)
    :totable()
  local usage = {
    i18n 'ygofab.usage.header', '\n  ', i18n 'ygofab.usage.cmd', '\n\n',
    i18n 'ygofab.usage.commands.header', '\n', unpack(Logs.tabular({0, 0}, commands))
  }
  if msg then Logs.error(msg, '\n', unpack(usage)) end
  print_header()
  Logs.info(unpack(usage))
  Logs.info('\n', i18n 'ygofab.usage.more')
end

local function add_project_warning()
  Logs.add_post_error_cb(function()
    if not path.exists('config.toml') then
      Logs.info('---------')
      Logs.warning(i18n 'ygofab.not_in_project')
    end
  end)
end

local function cmd_version(flags)
  if flags['--version'] or flags['-v'] then
    Logs.info(Version.formatted())
  elseif #arg > 0 then
    display_help(i18n 'ygofab.invalid_command' .. '\n')
  else
    display_help()
  end
end

local function cmd_compose(flags)
  add_project_warning()
  require 'scripts.compose'(flags)
end

local function cmd_config()
  add_project_warning()
  require 'scripts.config'()
end

local function cmd_export(flags)
  add_project_warning()
  require 'scripts.export'(flags)
end

local function cmd_make(flags, exp)
  add_project_warning()
  require 'scripts.make'(flags, exp)
end

local function cmd_new(_, pack_name) require 'scripts.new'(pack_name) end

local function cmd_sync(flags)
  add_project_warning()
  require 'scripts.sync'(flags)
end

local interpreter = Interpreter.new()
interpreter:add_command('compose', cmd_compose, '-p', 1, '-Pall', 0, '-e', 1,
  '-Eall', 0, '--verbose', 0)
interpreter:add_command('config', cmd_config)
interpreter:add_command('export', cmd_export, '-p', 1, '-Pall', 0, '-o', 1, '-e', 1,
  '-Eall', 0, '--verbose', 0)
interpreter:add_command('make', cmd_make, '--overwrite', 0, '-ow', 0, '--all', 0)
interpreter:add_command('new', cmd_new)
interpreter:add_command('sync', cmd_sync, '-g', 1, '-Gall', 0, '-p', 1, '-e', 1,
  '--no-string', 0, '--verbose', 0)
interpreter:add_command('', cmd_version, '--version', 0, '-v', 0)

Locale.set(Config.get('locale') or i18n.getFallbackLocale())
local errmsg, data = interpreter:exec(...)
if errmsg then display_help(i18n('interpreter.' .. errmsg, {data})) end
