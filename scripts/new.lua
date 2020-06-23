local fs = require 'lib.fs'
local path = fs.path
local sqlite = require 'lsqlite3complete'
local Logs = require 'lib.logs'


local GENFP = path.prjoin("res", "new")

local function check_name(pack_name)
  Logs.assert(pack_name, 1, "No name was provided for the new extension pack")
  Logs.assert(pack_name:match("^%a[%w-_]*$"), 1, "Invalid name")
end

local function create_folder(folder)
  Logs.info('Creating "', folder, '" folder...')
  local success, msg, errcode = fs.mkdir(folder)
  Logs.assert(success, errcode, ("%q - %s"):format(folder, msg))
end

local function create_cdb(pack_name)
  Logs.info("Creating card database...")
  local db, err, msg = sqlite.open(path.join(pack_name, "expansions",
    pack_name .. ".cdb"))
  Logs.assert(db, err, msg)
  local sqlf = io.open(path.join(GENFP, "create-cdb.sql"), "r")
  local create_sql = sqlf:read("*a")
  sqlf:close()
  db:exec(create_sql)
  db:close()
end

local function read_file(src)
  local srcfile, msg = io.open(src, "r")
  Logs.assert(srcfile, 1, msg)
  local str = srcfile:read("*a")
  srcfile:close()
  return str
end

local function write_file(dst, str)
  local dstfile, msg = io.open(dst, "w")
  Logs.assert(dstfile, 1, msg)
  dstfile:write(str)
  dstfile:close()
end

local function create_config(pack_name)
  Logs.info('Creating "config.toml" file...')
  local cgen = read_file(path.join(GENFP, "config.gen.toml"))
  local dst = path.join(pack_name, "config.toml")
  write_file(dst, cgen:gsub("$EXPANSION", pack_name))
end

return function (pack_name)
  check_name(pack_name)
  create_folder(pack_name)
  create_folder(path.join(pack_name, "artwork"))
  create_folder(path.join(pack_name, "pics"))
  create_folder(path.join(pack_name, "script"))
  create_folder(path.join(pack_name, "expansions"))
  create_cdb(pack_name)
  create_config(pack_name)
  Logs.ok('"', pack_name, '" pack successfully created!')
end
