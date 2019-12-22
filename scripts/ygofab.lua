local Interpreter = require 'scripts.interpreter'
local Logs = require 'scripts.logs'
local lfs = require 'lfs'
local path = require 'path'


local VERSION, PWD = "0.0.1"
local interpreter

local function get_pwd()
  return arg[1]
end

local function print_header()
  print(require 'scripts.header'(VERSION))
end

local function is_inside_project()
  for entry in lfs.dir(PWD) do
    local mode = lfs.attributes(path.join(PWD, entry), 'mode')
    if mode == 'file' and entry:match(".+%.cdb$") then
      return true
    end
  end
  return false
end

local function not_in_project_dialogue()
  print_header()
  Logs.assert(false, 1, "You are not in a project folder!\n",
    "You can create a new project using\n\n",
    "  $ ygofab new <pack-name>\n")
end

local function display_help(header, msg)
  if is_inside_project() then
    if header then print_header() end
    Logs.assert(false, 1, msg or "This is not a valid command.\n",
      "Usage:\n\n",
      "  $ ygofab [command] [options]\n\n",
      "Available commands:\n\n",
      "  card   \tManages card editing and searching\n",
      "  compose\tGenerates card pics\n",
      "  config \tShows project configurations\n",
      "  export \tExports your project to a .zip file\n",
      "  sync   \tCopies your project files to YGOPro game"
    )
  else
    not_in_project_dialogue()
  end
end

local function display_card_help(header)
  if is_inside_project() then
    if header then print_header() end
    Logs.assert(false, 1, msg or "This is not a valid command.\n",
      "Usage:\n\n",
      "  $ ygofab card [command] [options]\n\n",
      "Available commands:\n\n",
      "  create <card-id>    \tCreates a new card\n",
      "  delete <card-id> ...\tDeletes the specified card(s)\n",
      "  edit <card-id>      \tEdits the specified card\n",
      "  search <query> ...  \tSearches for cards matching the query"
    )
  else
    not_in_project_dialogue()
  end
end

local function cmd_card_create(flags, ...) end

local function cmd_card_delete(flags, ...) end

local function cmd_card_edit(flags, ...) end

local function cmd_card_search(flags, ...) end

local function cmd_compose(flags) end

local function cmd_config()
  require 'scripts.config'(is_inside_project() and PWD)
end

local function cmd_export(flags)
  if is_inside_project() then
    require 'scripts.export'(PWD, flags)
  else
    not_in_project_dialogue()
  end
end

local function cmd_new(_, pack_name)
  require 'scripts.new'(PWD, pack_name)
end

local function cmd_sync(flags)
  if is_inside_project() then
    require 'scripts.sync'(PWD, flags)
  else
    not_in_project_dialogue()
  end
end

local function init_interpreter()
  interpreter = Interpreter()
  interpreter:add_command("compose", cmd_compose, "-p", 1, "-Pall", 0)
  interpreter:add_command("config", cmd_config)
  interpreter:add_command("export", cmd_export, "-p", 1, "-Pall", 0, "-o", 1)
  interpreter:add_command("new", cmd_new)
  interpreter:add_command("sync", cmd_sync, "-g", 1, "-Gall", 0, "-p", 1,
    "--clean", 0, "--no-script", 0, "--no-pics", 0, "--no-exp", 0)
  interpreter:add_command("card create", cmd_card_create)
  interpreter:add_command("card edit", cmd_card_edit)
  interpreter:add_command("card delete", cmd_card_delete, "--clean", 0)
  interpreter:add_command("card search", cmd_card_search)
  interpreter:add_fallback("", function() return display_help(true) end)
  interpreter:add_fallback("card", function() return display_card_help(true) end)
end

PWD = get_pwd()
init_interpreter()
local errmsg, cmd, args, flags = interpreter:parse(unpack(arg, 2))
if errmsg then
  display_help(false, errmsg .. "\n")
end
interpreter:exec(cmd, args, flags)
