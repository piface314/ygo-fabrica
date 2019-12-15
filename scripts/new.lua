local lfs = require 'lfs'
local path = require 'path'
local sqlite = require 'lsqlite3complete'
local Logs = require 'logs'


local function check_name(pack_name)
  Logs.assert(pack_name, 1, "No name was provided for the new extension pack")
end

local function create_folder(folder)
  Logs.info("Creating \"", folder, "\" folder...")
  local success, msg, errcode = lfs.mkdir(path.join(PWD, folder))
  Logs.assert(success, errcode, ("%q - %s"):format(folder, msg))
end

local function create_cdb(pack_name)
  Logs.info("Creating card database...")
  local db, err, msg = sqlite.open(path.join(PWD, pack_name, pack_name .. ".cdb"))
  Logs.assert(db, err, msg)
  local sqlf = io.open("scripts/starter/create-cdb.sql", "r")
  local create_sql = sqlf:read("*a")
  sqlf:close()
  db:exec(create_sql)
end

local function copy_file(from, to)
  Logs.info("Creating \"", to, "\" file...")
  local fromfile, msg = io.open(from, "r")
  Logs.assert(fromfile, 1, msg)
  local tofile, msg = io.open(path.join(PWD, to), "w")
  Logs.assert(tofile, 1, msg)
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
  Logs.ok("\"", pack_name, "\" pack successfully created!")
end
