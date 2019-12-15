local lfs = require 'lfs'
local path = require 'path'
local sqlite = require 'lsqlite3complete'
local colors = require 'colors'
local aexit = require 'aexit'


local function check_name(pack_name)
  aexit(pack_name, 1, "No name was provided for the new extension pack")
end

local function create_folder(folder)
  io.write("Creating \"", folder, "\" folder...", "\n")
  local success, msg, errcode = lfs.mkdir(path.join(PWD, folder))
  aexit(success, errcode, ("%q - %s"):format(folder, msg))
end

local function create_cdb(pack_name)
  io.write("Creating card database...", "\n")
  local db, err, msg = sqlite.open(path.join(PWD, pack_name, pack_name .. ".cdb"))
  aexit(db, err, msg)
  local sqlf = io.open("scripts/starter/create-cdb.sql", "r")
  local create_sql = sqlf:read("*a")
  sqlf:close()
  db:exec(create_sql)
end

local function copy_file(from, to)
  io.write("Creating \"", to, "\" file...", "\n")
  local fromfile, msg = io.open(from, "r")
  aexit(fromfile, 1, msg)
  local tofile, msg = io.open(path.join(PWD, to), "w")
  aexit(tofile, 1, msg)
  tofile:write(fromfile:read("*a"))
  tofile:close()
  fromfile:close()
end

return function (pack_name)
  check_name(pack_name)
  create_folder(pack_name)
  create_folder(path.join(pack_name, "artwork"))
  create_folder(path.join(pack_name, "pics"))
  create_folder(path.join(pack_name, "script"))
  create_cdb(pack_name)
  copy_file("scripts/starter/default-config.toml", path.join(pack_name, "config.toml"))
  copy_file("scripts/starter/default.gitignore", path.join(pack_name, ".gitignore"))
  io.write(colors.FG_GREEN, colors.BOLD, "[OK]", colors.RESET,
    " \"", pack_name, "\" pack successfully created!\n")
end
