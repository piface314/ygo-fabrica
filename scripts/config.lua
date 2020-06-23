local path = require 'lib.fs'.path
local toml = require 'toml'
local Logs = require 'lib.logs'
local colors = require 'lib.colors'
require 'lib.table'


local Config = {}

local IS_WIN = package.config:sub(1, 1) == "\\"
-- TODO: change to (os.getenv("HOME") .. "/.config/ygofab")
local HOME = IS_WIN and (os.getenv("APPDATA") .. "\\YGOFabrica") or (os.getenv("HOME") .. "/ygofab")

local FIELDS = {
  gamedir = { path = true },
  picset = { mode = true },
  expansion = { recipe = true }
}

local merge, concat = table.merge, table.concat

local function validate(cfg, fields)
  for k, f in pairs(fields or FIELDS) do
    local c = cfg[k]
    if type(f) == 'table' then
      if not c or type(c) ~= 'table' then
        cfg[k] = {}
      end
      for ck, c in pairs(cfg[k]) do
        if not validate(c, f) then
          cfg[k][ck] = nil
        end
      end
    elseif not c then
      return false
    end
  end
  return true
end

local function load_file(path)
  local cfg = io.open(path, "r")
  if not cfg then
    return nil
  end
  local config = toml.parse(cfg:read('*a'))
  cfg:close()
  validate(config)
  return config
end

local function format_list(cfg, title, fmt)
  local list = {}
  for k, v in pairs(cfg) do
    list[#list + 1] = fmt(k, v)
  end
  if list and #list > 0 then
    table.sort(list)
    list = concat(list)
    list = ("  %s%s:%s\n%s")
      :format(colors.FG_MAGENTA, title, colors.RESET, list)
  else
    list = ("  %s[!]%s You have no %s configured.\n")
      :format(colors.FG_YELLOW, colors.RESET, title:lower())
  end
  return list
end

local function format(cfg)
  local gamedirs = format_list(cfg.gamedir, "Game directories", function(k, v)
      return ("    %s: %q%s\n"):format(k, v.path, v.default and " (default)" or "")
    end)
  local picsets = format_list(cfg.picset, "Pic sets", function(k, v)
      return ("    %s: %s%s%s%s%s\n"):format(k, v.mode,
        v.size and " --size " .. v.size or "",
        v.ext and " --ext " .. v.ext or "",
        v.field and " --field" or "", v.default and " (default)" or "")
    end)
  local expansions = format_list(cfg.expansion, "Expansions", function(k, v)
      local recipe = type(v.recipe) == 'table' and v.recipe or {}
      return ("    %s: %s%s\n"):format(k, "[" .. concat(recipe, ", ") .. "]",
        v.default and " (default)" or "")
    end)
  return gamedirs .. "\n" .. picsets .. "\n" .. expansions
end

function Config.get()
  local empty = {}
  validate(empty)
  local global_cfg = load_file(path.join(HOME, "config.toml")) or empty
  local local_cfg = load_file("config.toml")
  return local_cfg, global_cfg
end

function Config.get_one(key, id)
  local local_cfg, global_cfg = Config.get()
  local lc = local_cfg and local_cfg[key][id] or nil
  local gc = global_cfg[key][id]
  return lc or gc
end

function Config.get_default(key)
  local local_cfg, global_cfg = Config.get()
  local function search(t)
    for id, c in pairs(t) do
      if c.default then return id, c end
    end
    return nil
  end
  local id, c = search(local_cfg and local_cfg[key] or {})
  if id then
    return id, c
  else
    return search(global_cfg[key])
  end
end

function Config.get_defaults(key)
  local local_cfg, global_cfg = Config.get()
  local cfg = {}
  merge(cfg, global_cfg)
  merge(cfg, local_cfg or {})
  local cs = {}
  for id, c in pairs(cfg[key]) do
    if c.default then
      cs[id] = c
    end
  end
  return cs
end

function Config.get_all(key)
  local local_cfg, global_cfg = Config.get()
  local cfg = {}
  merge(cfg, global_cfg)
  merge(cfg, local_cfg or {})
  return cfg[key]
end

setmetatable(Config, { __call = function()
  local local_cfg, global_cfg = Config.get()
  local fglobal_cfg, errmsg = format(global_cfg)
  Logs.assert(fglobal_cfg, 1, errmsg)
  Logs.info(colors.FG_MAGENTA, colors.BOLD, "Global configurations:\n\n",
    colors.RESET, fglobal_cfg)
  if local_cfg then
    local flocal_cfg, errmsg = format(local_cfg)
    Logs.assert(flocal_cfg, 1, errmsg)
    Logs.info(colors.FG_MAGENTA, colors.BOLD, "Local configurations:\n\n",
      colors.RESET, flocal_cfg)
  end
end })

return Config
