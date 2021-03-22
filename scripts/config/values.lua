local path = require 'lib.path'
local toml = require 'toml'
local fun = require 'lib.fun'
local Schema = require 'scripts.config.schema'
local Logs = require 'lib.logs'
local i18n = require 'i18n'

local Config = {
  groups = {from_flag = {}},
  GLOBAL_FP = path.gcjoin('config.toml')
}

local cache = {}
local function load_file(fp)
  if cache[fp] then return cache[fp] end
  local cfg = io.open(fp, 'r')
  if not cfg then return nil end
  local config = toml.parse(cfg:read('*a'))
  cfg:close()
  cache[fp] = Schema.validate(config)
  return cache[fp]
end

function Config.load()
  local local_cfg = load_file('./config.toml')
  local global_cfg = load_file(Config.GLOBAL_FP) or Schema.validate({})
  return global_cfg, local_cfg
end

--- Looks for configuration values in table, according to a
--- sequence of keys in the variable arguments.
--- If `cfg` is a table, then `Config.get` looks up in that table.
--- Otherwise, it loads global and local configs, merges them, and
--- looks up that resulting table, and `cfg` is treated as the first key.
--- @param cfg table|string
--- @vararg string
--- @return any
function Config.get(cfg, ...)
  local key
  if type(cfg) == 'table' then
    key = {...}
  else
    key = {cfg, ...}
    cfg = table.merge(Config.load())
  end
  for _, k in ipairs(key) do
    if type(cfg) == 'table' then
      cfg = cfg[k]
    else
      break
    end
  end
  return cfg
end

local key = function(...) return table.concat({...}, '.') end
local default_f = function(_, g) return g.default end

--- Gets many configuration values. If `default` is `true`, then
--- every default value is returned. If `all` is `true`, all values
--- are returned. Otherwise, returns the configuration specified in
--- a table, indexed by the last key:
--- E.g. `get_many(true, false, 'gamedir')` -> `{main={default=true}}`
--- E.g. `get_many(false, true, 'gamedir')` -> `{main={default=true}, alt={}}`
--- E.g. `get_many(false, false, 'gamedir', 'alt')` -> `{alt={}}`
--- @param all boolean
--- @param default boolean
--- @vararg string
--- @return table configs
function Config.groups.get_many(all, default, ...)
  local groups = Config.get(...)
  if default then
    return fun.iter(groups):filter(default_f):tomap()
  elseif all then
    return groups
  else
    return {[select(-1, ...)] = groups}
  end
end

local function first_default(gs)
  return next(fun.iter(gs):filter(default_f):tomap())
end

--- Gets one specific configuration, or looks for a default one,
--- if `default` is `true`
--- @param default boolean
--- @vararg string
--- @return string config_id
--- @return table config
function Config.groups.get_one(default, ...)
  if default then
    local gc, lc = Config.load()
    local k, v = first_default(Config.get(lc, ...))
    if k then return k, v end
    return first_default(Config.get(gc, ...))
  else
    return select(-1, ...), Config.get(...)
  end
end

--- Gets multiple configurations according to a flag. If the flag specifies
--- an id and that configuration exists, it is returned in a table. If the flag
--- specifies `all`, then all configurations in that group are returned.
--- Otherwise, default configurations are selected
--- @param gkey string
--- @param flag table
--- @return table configs
function Config.groups.from_flag.get_many(gkey, flag)
  local all = flag and not flag[1]
  local id = flag and flag[1]
  local selected = Config.groups.get_many(all, not flag, gkey, id)
  local has_any, full_key = next(selected) ~= nil, {key(gkey, id)}
  Logs.assert(not id or has_any, i18n('config.missing', full_key))
  if not has_any then Logs.warning(i18n('config.none', full_key)) end
  return selected
end

--- Gets a single configuration according to a flag. If none is specified,
--- a default configuration is selected. If none is found, an error is raised.
--- @param gkey string
--- @param flag table
--- @return string config_id
--- @return table config
function Config.groups.from_flag.get_one(gkey, flag)
  local id = flag and flag[1]
  local selid, sel = Config.groups.get_one(not flag, gkey, id)
  Logs.assert(selid, i18n('config.missing', {key(gkey, id)}))
  return selid, sel
end

return Config
