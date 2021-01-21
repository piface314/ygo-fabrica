local path = require 'lib.path'
local sqlite = require 'lsqlite3complete'
local Logs = require 'lib.logs'
local GameConst = require 'scripts.game-const'
local i18n = require 'lib.i18n'
local fun = require 'lib.fun'

local Writer = {}

local cols = fun {
  texts = fun {
    'id', 'name', 'desc', 'str1', 'str2', 'str3', 'str4', 'str5', 'str6',
    'str7', 'str8', 'str9', 'str10', 'str11', 'str12', 'str13', 'str14',
    'str15', 'str16'
  },
  datas = fun {
    'id', 'ot', 'alias', 'setcode', 'type', 'atk', 'def', 'level', 'race',
    'attribute', 'category'
  }
}

local val_fmt = cols:map(fun [[cs -> '(' .. ('"%s",'):rep(#cs):sub(1, -2) .. ')']])
local delete_sql = [[DELETE FROM %s WHERE id NOT IN (%s)]]
local replace_sqls = cols:map(function(cs, t)
  return ([[REPLACE INTO %s (%s) VALUES %%s]]):format(t, table.concat(cs, ','))
end)

local function get_tuple(table, entry)
  return cols[table]:map(function(k)
    local v = entry[k]
    return type(v) == 'string' and v:gsub('"', '""') or v
  end)
end

local function get_replace_cmd(t, entries)
  local tuples = entries:map(function(entry)
    return val_fmt[t]:format(unpack(get_tuple(t, entry)))
  end)
  return replace_sqls[t]:format(table.concat(tuples, ','))
end

local function open_cdb(cdbfp)
  local db, _, msg = sqlite.open(cdbfp)
  Logs.assert(db, msg)
  local sqlf = io.open(path.prjoin('res', 'new', 'create-cdb.sql'), 'r')
  local create_sql = sqlf:read('*a')
  sqlf:close()
  local err = db:exec(create_sql)
  Logs.assert(err == sqlite.OK, i18n('make.writer.create_error', {err}))
  return db
end

local function clean_cdb(cdb, t, entries)
  local ids = entries:map(fun 'e -> e.id')
  local del = delete_sql:format(t, table.concat(ids, ','))
  local err = cdb:exec(del)
  if err ~= sqlite.OK then
    Logs.warning(i18n('make.writer.clean_error', {err}))
  end
end

local function write_cdb(cdbfp, entries, overwrite)
  local cdb = open_cdb(cdbfp)
  for t in pairs(cols) do
    local err = cdb:exec(get_replace_cmd(t, entries))
    if err ~= sqlite.OK then
      Logs.warning(i18n('make.writer.write_error', {err}))
    elseif overwrite then
      clean_cdb(cdb, t, entries)
    end
  end
  cdb:close()
end

local script_template = [[-- %s
local s, id = GetID()
function s.initial_effect(c)
  %s
end]]
local st_activate = [[-- activate
  local e1 = Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  c:RegisterEffect(e1)]]
local types = GameConst.code.type
local function is_effect_monster(t)
  return bit.band(t, types.EFFECT + types.PENDULUM) ~= 0
end
local function is_spell_trap(t)
  return bit.band(t, types.SPELL + types.TRAP) ~= 0
end
local function write_scripts(entries)
  entries:map(function(e)
    return {e, path.join('script', ('c%d.lua'):format(e.id))}
  end):filter(function(t) return not path.exists(t[2]) end)
  :foreach(function(t)
    local entry, fp, script = t[1], t[2], nil
    if is_effect_monster(entry.type) then
      script = script_template:format(entry.name, '-- effects')
    elseif is_spell_trap(entry.type) then
      script = script_template:format(entry.name, st_activate)
    else return end
    local f = io.open(fp, 'w')
    if f then
      f:write(script, '\n')
      f:close()
    end
  end)
end

local STRING_KEYS = fun {setname = true, counter = true}
local function get_string_lines_from_file(fp)
  local src = io.open(fp)
  if not src then return end
  local lines = STRING_KEYS:map(fun '_ -> {}')
  for line in src:lines() do
    local key, code, val = line:match('^%s*!(%w+)%s+(0x%x+)%s*(.-)%s*$')
    code = tonumber(code)
    if STRING_KEYS[key] and code and val then
      lines[key][code] = val
    end
  end
  src:close()
  return lines
end

local fmt_line = fun '... -> ("!%s 0x%04x %s\\n"):format(...)'
local function fmt_lines(rlines)
  local wlines = fun {}
  for key, t in pairs(rlines) do
    for code, val in pairs(t) do
      wlines:push(fmt_line(key, code, val))
    end
  end
  return wlines:reduce('', fun 'a, s -> a .. s')
end

local function merge_lines_with_file(fp, rlines)
  local f, wlines = io.open(fp), ''
  if f then
    wlines = fun(f:lines())
      :map(fun 'l -> {l, l:match("^%s*!(%w+)%s+(0x%x+).*$")}')
      :map(function(t)
        local line, key, code = t[1], t[2], tonumber(t[3] or nil)
        local val = rlines[key] and rlines[key][code]
        if val then
          rlines[key][code] = nil
          return fmt_line(key, code, val)
        else
          return line .. '\n'
        end
      end):reduce('', fun 'a, s -> a .. s')
    f:close()
  end
  return wlines .. fmt_lines(rlines)
end

local function get_string_lines(strings)
  return strings:map(function(entries)
    return fun(entries):hashmap(fun 'e -> tonumber(e.code or nil), e.name')
  end):filter(fun 'g -> next(g) ~= nil')
end

function Writer.merge_strings(src_fp, dst_fp)
  local rlines = get_string_lines_from_file(src_fp)
  if not rlines then return false end
  local wlines = merge_lines_with_file(dst_fp, rlines)
  local dst = io.open(dst_fp, 'w')
  if not dst then return false end
  dst:write(wlines)
  dst:close()
  return true
end

function Writer.write_strings(fp, strings, ow)
  local rlines = get_string_lines(strings)
  if not next(rlines) then return end
  local wlines = ow and fmt_lines(rlines) or merge_lines_with_file(fp, rlines)
  local dst = io.open(fp, 'w')
  if not dst then
    return Logs.warning(i18n 'make.writer.strings_fail')
  end
  Logs.info(i18n 'make.writer.strings')
  dst:write(wlines)
  dst:close()
end

function Writer.write_entries(cdbfp, entries, overwrite)
  write_cdb(cdbfp, entries, overwrite)
  write_scripts(entries)
end

return Writer
