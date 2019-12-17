local path = require 'path'
local toml = require 'toml'
local Logs = require 'scripts.logs'
local colors = require 'scripts.colors'


local Config = {}

local FIELDS = {
  gamedir = { path = true },
  picset = { mode = true, size = true }
}

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
    Logs.info("Failed to load \"", path, "\"")
    return nil
  end
  local config = toml.parse(cfg:read('*a'))
  cfg:close()
  validate(config)
  return config
end

local function merge(dst, src)
  for k, v in pairs(src) do
    if type(v) == 'table' then
      if type(dst[k]) ~= 'table' then
        dst[k] = {}
      end
      merge(dst[k], v)
    else
      dst[k] = v
    end
  end
end

local function format_list(cfg, title, fmt)
  local list = {}
  for k, v in pairs(cfg) do
    list[#list + 1] = fmt(k, v)
  end
  if list and #list > 0 then
    table.sort(list)
    list = table.concat(list)
    list = ("%s%s%s:%s\n%s")
      :format(colors.FG_MAGENTA, colors.BOLD, title, colors.RESET, list)
  else
    list = ("%s%s[!]%s You have no %s configured.\n")
      :format(colors.FG_YELLOW, colors.BOLD, colors.RESET, title:lower())
  end
  return list
end

local function format(cfg)
  local gamedirs = format_list(cfg.gamedir, "Game directories", function(k, v)
      return ("%s: %q%s\n"):format(k, v.path, v.default and " (default)" or "")
    end)
  local picsets = format_list(cfg.picset, "Pic sets", function(k, v)
      return ("%s: %s %s%s%s\n"):format(k, v.mode, v.size,
        v.field and " --field" or "", v.default and " (default)" or "")
    end)
  return gamedirs .. "\n" .. picsets
end

function Config.get(pwd, is_inside_project)
  local global_cfg = load_file("config.toml")
  local local_cfg = is_inside_project
    and load_file(path.join(pwd, "config.toml")) or {}
  local config = {}
  merge(config, global_cfg)
  merge(config, local_cfg)
  return config
end

return setmetatable(Config, { __call = function(_, pwd, is_inside_project)
  local config = Config.get(pwd, is_inside_project)
  local fconfig, errmsg = format(config)
  Logs.assert(fconfig, 1, errmsg)
  Logs.info("Active configurations:\n\n", fconfig)
end })
