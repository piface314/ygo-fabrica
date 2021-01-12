local path = require'lib.fs'.path
local toml = require 'toml'
local fun = require 'lib.fun'
local Schema = require 'scripts.config.schema'
local Logs = require 'lib.logs'
local i18n = require 'lib.i18n'
require 'lib.table'

local Config = {groups = {from_flag = {}}}

local IS_WIN = package.config:sub(1, 1) == '\\'
local HOME = IS_WIN and path.join(os.getenv('APPDATA'), 'YGOFabrica') or
               path.join(os.getenv('HOME'), '.config', 'ygofab')
local GLOBAL_FP = path.join(HOME, 'config.toml')

local cache = {}
local function load_file(fp)
  if cache[fp] then
    return cache[fp]
  end
  local cfg = io.open(fp, 'r')
  if not cfg then
    return nil
  end
  local config = toml.parse(cfg:read('*a'))
  cfg:close()
  cache[fp] = Schema.validate(config)
  return cache[fp]
end

function Config.load()
  local local_cfg = load_file('./config.toml')
  local global_cfg = load_file(GLOBAL_FP) or Schema.validate({})
  return global_cfg, local_cfg
end

function Config.get(...)
  local cfg = table.merge(Config.load())
  for _, k in ipairs({...}) do
    if type(cfg) == 'table' then
      cfg = cfg[k]
    else
      break
    end
  end
  return cfg
end

local function key(...)
  return table.concat({...}, '.')
end

function Config.groups.get_many(all, default, ...)
  local groups = Config.get(...)
  if default then
    return table.filter(groups, fun 'g -> g.default')
  elseif all then
    return groups
  else
    return {[select(-1, ...)] = groups}
  end
end

function Config.groups.get_one(default, ...)
  local groups = Config.get(...)
  if default then
    return next(table.filter(groups, fun 'g -> g.default'))
  else
    return select(-1, ...), Config.get(...)
  end
end

function Config.groups.from_flag.get_many(gkey, flag)
  local all = flag and not flag[1]
  local id = flag and flag[1]
  local selected = Config.groups.get_many(all, not id, gkey, id)
  local has_any, full_key = next(selected) ~= nil, {key(gkey, id)}
  Logs.assert(not id or has_any, i18n('config.missing', full_key))
  if not has_any then
    Logs.warning(i18n('config.none', full_key))
  end
  return selected
end

function Config.groups.from_flag.get_one(gkey, flag)
  local id = flag and flag[1]
  local selid, sel = Config.groups.get_one(not id, gkey, id)
  Logs.assert(selid, i18n('config.missing', {key(gkey, id)}))
  return selid, sel
end

return Config
