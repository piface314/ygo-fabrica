local Interpreter = require 'lib.interpreter'
local Logs = require 'lib.logs'


local VERSION, PWD = "1.0.0"
local interpreter

local function get_pwd()
  return arg[1]
end

local function print_header()
  print(require 'lib.header'(VERSION))
end

local function display_help(header, msg)
  if header then print_header() end
  Logs.assert(false, 1, msg or "This is not a valid command.\n",
    "Usage:\n\n",
    "  $ ygofab <command> [options]\n\n",
    "Available commands:\n\n",
    "  compose\tGenerates card pics\n",
    "  config \tShows project configurations\n",
    "  export \tExports your project to a .zip file\n",
    "  make   \tConverts card description in .toml into a .cdb\n",
    "  new    \tCreates a new project, given a name\n",
    "  sync   \tCopies your project files to YGOPro game"
  )
end

local function cmd_compose(flags)
  require 'scripts.compose'(PWD, flags)
end

local function cmd_config()
  require 'scripts.config'(PWD)
end

local function cmd_export(flags)
  require 'scripts.export'(PWD, flags)
end

local function cmd_make(flags, exp)
  require 'scripts.make'(PWD, flags, exp)
end

local function cmd_new(_, pack_name)
  require 'scripts.new'(PWD, pack_name)
end

local function cmd_sync(flags)
  require 'scripts.sync'(PWD, flags)
end

local function init_interpreter()
  interpreter = Interpreter()
  interpreter:add_command("compose", cmd_compose, "-p", 1, "-Pall", 0,
    "-e", 1, "-Eall", 0)
  interpreter:add_command("config", cmd_config)
  interpreter:add_command("export", cmd_export, "-p", 1, "-Pall", 0, "-o", 1,
    "-e", 1, "-Eall", 0)
  interpreter:add_command("make", cmd_make, "--clean", 0, "--all")
  interpreter:add_command("new", cmd_new)
  interpreter:add_command("sync", cmd_sync, "-g", 1, "-Gall", 0, "-p", 1, "-e", 1,
    "--clean", 0, "--no-script", 0, "--no-pics", 0, "--no-exp", 0, "--no-string", 0)
  interpreter:add_fallback("", function() return display_help(true) end)
end

PWD = get_pwd()
init_interpreter()
local errmsg, cmd, args, flags = interpreter:parse(unpack(arg, 2))
if errmsg then
  display_help(false, errmsg .. "\n")
end
interpreter:exec(cmd, args, flags)
