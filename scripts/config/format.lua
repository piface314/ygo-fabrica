local Schema = require 'scripts.config.schema'
local Logs = require 'lib.logs'
local colors = require 'lib.colors'
local fun = require 'lib.fun'
local i18n = require 'i18n'

local function format_value(v)
  if type(v) == 'table' then
    local list = fun.iter(v):map(format_value):totable()
    return '[' .. table.concat(list, ', ') .. ']'
  elseif type(v) == 'string' then
    return ('%q'):format(v)
  end
  return v
end

--- Returns the keys from a config schema
--- @param key string
--- @return string[]
local function get_schema_struct_keys(key)
  local struct = table.deepcopy(Schema.default.items[key].items.items)
  struct.default = nil
  return table.sort(fun.iter(struct):totable())
end

local function format_entry(st_keys, m, mk)
  local e = m[mk]
  local header = ('  %s%s:\n'):format(mk, e.default and ' (default)' or '')
  local fmt_es = fun.iter(st_keys)
    :filter(function(sk) return e[sk] ~= nil end)
    :map(function(sk) return ('    %s: %s\n'):format(sk, format_value(e[sk])) end)
    :totable()
  return header .. table.concat(fmt_es)
end

local function format_map(key, m)
  local fmt_map = '%s=== %s ===%s\n'
  local struct_keys = get_schema_struct_keys(key)
  local entry_keys = table.sort(fun.iter(m):totable())
  fmt_map = fmt_map:format(colors.FG_MAGENTA, key, colors.RESET)

  if #entry_keys == 0 then
    local warn = colors.FG_YELLOW .. '[!] ' .. colors.RESET
    return fmt_map .. '  ' .. warn .. i18n('config.none', {key}) .. '\n'
  end

  local fmt_entries = fun.iter(entry_keys):map(function(mk)
    return format_entry(struct_keys, m, mk)
  end):totable()

  return fmt_map .. table.concat(fmt_entries, '\n')
end

local CFG_KEYS = {'locale', 'expansion', 'gamedir', 'picset'}
local format = setmetatable(fun.iter(CFG_KEYS):map(function(k)
    return k, function(cfg) return format_map(k, cfg) end
  end):tomap(), {
  __call = function(self, cfg)
    local fmt_cfgs = fun.iter(CFG_KEYS):map(function(k)
      return self[k](cfg[k]):gsub('(.-\n)', '  %1')
    end):totable()
    return table.concat(fmt_cfgs, '\n')
  end
})

function format.locale(l)
  local fmt_locale = '%s=== locale ===%s\n  %s\n'
  return fmt_locale:format(colors.FG_MAGENTA, colors.RESET, l or '?')
end

return function(global_cfg, local_cfg)
  local fglobal_cfg = format(global_cfg)
  Logs.info(colors.FG_MAGENTA, colors.BOLD, i18n 'config.globals', '\n',
            colors.RESET, fglobal_cfg)
  if local_cfg then
    local flocal_cfg = format(local_cfg)
    Logs.info(colors.FG_MAGENTA, colors.BOLD, i18n 'config.locals', '\n\n',
              colors.RESET, flocal_cfg)
  end
end
