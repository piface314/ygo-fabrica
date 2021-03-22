local Logs = require 'lib.logs'
local Config = require 'scripts.config'
local path = require 'lib.path'
local sqlite = require 'lsqlite3complete'
local i18n = require 'i18n'

local GENFP = path.prjoin('res', 'new')

local function check_name(name)
  Logs.assert(name, i18n 'new.no_name')
  Logs.assert(name:match('^%a[%w-_]*$'), i18n 'new.invalid_name')
end

local function create_folder(folder)
  Logs.info(i18n('new.create_folder', {folder}))
  local success, msg = path.mkdir(folder)
  Logs.assert(success, ('%q - %s'):format(folder, msg))
end

local function create_cdb(name)
  Logs.info(i18n 'new.create_cdb')
  local db, _, msg = sqlite.open(path.join(name, 'expansions', name .. '.cdb'))
  Logs.assert(db, msg)
  local sqlf = io.open(path.join(GENFP, 'create-cdb.sql'), 'r')
  local create_sql = sqlf:read('*a')
  sqlf:close()
  db:exec(create_sql)
  db:close()
end

local function read_file(src)
  local srcfile, msg = io.open(src, 'r')
  Logs.assert(srcfile, msg)
  local str = srcfile:read('*a')
  srcfile:close()
  return str
end

local function write_file(dst, str)
  local dstfile, msg = io.open(dst, 'w')
  Logs.assert(dstfile, msg)
  dstfile:write(str)
  dstfile:close()
end

local function create_config(pack_name)
  Logs.info(i18n 'new.create_config')
  local cgen = read_file(path.join(GENFP, 'config.gen.toml'))
  local dst = path.join(pack_name, 'config.toml')
  local comment = i18n('new.config_comment', {Config.GLOBAL_FP})
  write_file(dst, comment .. cgen:gsub('$EXPANSION', pack_name))
end

return function(proj_name)
  check_name(proj_name)
  create_folder(proj_name)
  create_folder(path.join(proj_name, 'artwork'))
  create_folder(path.join(proj_name, 'pics'))
  create_folder(path.join(proj_name, 'script'))
  create_folder(path.join(proj_name, 'expansions'))
  create_cdb(proj_name)
  create_config(proj_name)
  Logs.ok(i18n('new.done', {proj_name}))
end
