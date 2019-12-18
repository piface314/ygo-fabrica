local path = require 'path'
local toml = require 'toml'
local Logs = require 'scripts.logs'
local colors = require 'scripts.colors'


local Config = {}

local FIELDS = {
  gamedir = { path = true },
  picset = { mode = true, size = true, ext = true }
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
    Logs.warning("Failed to load \"", path, "\"")
    return nil
  end
  local config = toml.parse(cfg:read('*a'))
  cfg:close()
  validate(config)
  return config
end

function Config.merge(dst, src)
  for k, v in pairs(src) do
    if type(v) == 'table' then
      if type(dst[k]) ~= 'table' then
        dst[k] = {}
      end
      Config.merge(dst[k], v)
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
    list = ("  %s%s%s:%s\n%s")
      :format(colors.FG_MAGENTA, colors.BOLD, title, colors.RESET, list)
  else
    list = ("  %s%s[!]%s You have no %s configured.\n")
      :format(colors.FG_YELLOW, colors.BOLD, colors.RESET, title:lower())
  end
  return list
end

local function format(cfg)
  local gamedirs = format_list(cfg.gamedir, "Game directories", function(k, v)
      return ("    %s: %q%s\n"):format(k, v.path, v.default and " (default)" or "")
    end)
  local picsets = format_list(cfg.picset, "Pic sets", function(k, v)
      return ("    %s: %s %s%s%s\n"):format(k, v.mode, v.size,
        v.field and " --field" or "", v.default and " (default)" or "")
    end)
  return gamedirs .. "\n" .. picsets
end

function Config.get(pwd)
  local empty = {}
  validate(empty)
  local global_cfg = load_file("config.toml") or empty
  local local_cfg = pwd and load_file(path.join(pwd, "config.toml")) or empty
  return local_cfg, global_cfg
end

return setmetatable(Config, { __call = function(_, pwd)
  local local_cfg, global_cfg = Config.get(pwd)
  local fglobal_cfg, errmsg = format(global_cfg)
  Logs.assert(fglobal_cfg, 1, errmsg)
  Logs.info("Global configurations:\n\n", fglobal_cfg)
  if pwd then
    local flocal_cfg, errmsg = format(local_cfg)
    Logs.assert(flocal_cfg, 1, errmsg)
    Logs.info("Local configurations:\n\n", flocal_cfg)
  end
end })
