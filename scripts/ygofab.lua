local ArgParser = require 'scripts.argparser'


local function get_pwd()
  PWD = arg[1]
end

local argparser
local function init_argparser()
  argparser = ArgParser()
  argparser:add_command("compose", "-p", 1, "-Pall", 0)
  argparser:add_command("config")
  argparser:add_command("export", "-p", 1, "-Pall", 0, "-o", 1)
  argparser:add_command("new")
  argparser:add_command("sync", "-g", 1, "-Gall", 0, "-p", 1)
  argparser:add_command("card create")
  argparser:add_command("card edit")
  argparser:add_command("card delete", "--clean", 0)
  argparser:add_command("card search")
end

get_pwd()
init_argparser()
