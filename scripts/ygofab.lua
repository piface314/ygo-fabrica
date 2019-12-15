local colors  = require 'colors'
local TOML = require 'toml'

PWD, ARGS = arg[1], { unpack(arg, 2) }

local commands = {
  new = require "scripts.new"
}

commands.new(ARGS[1])
