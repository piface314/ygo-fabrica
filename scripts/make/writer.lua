local fs = require 'lib.fs'
local path = fs.path
local sqlite = require 'lsqlite3complete'
local Logs = require 'lib.logs'
local GameConst = require 'scripts.game-const'


local Writer = {}

local insert, concat = table.insert, table.concat

local tables = {'texts', 'datas'}

local function open_cdb(cdbfp)
  local db, err, msg = sqlite.open(cdbfp)
  Logs.assert(db, err, msg)
  local sqlf = io.open(path.prjoin("res", "new", "create-cdb.sql"), "r")
  local create_sql = sqlf:read("*a")
  sqlf:close()
  db:exec(create_sql)
  return db
end

local cols = {
  texts = { "id", "name", "desc", "str1", "str2", "str3", "str4", "str5", "str6", "str7",
    "str8", "str9", "str10", "str11", "str12", "str13", "str14", "str15", "str16" },
  datas = { "id", "ot", "alias", "setcode", "type", "atk", "def", "level",
  "race", "attribute", "category" }
}

local function get_val_fmt(n)
  return "(" .. ("\"%s\","):rep(n):sub(1, -2) .. ")"
end

local delete_sql = [[DELETE FROM %s WHERE id NOT IN (%s)]]
local replace_sqls, val_fmt = {}, {}
for t, cs in pairs(cols) do
  replace_sqls[t] = ([[REPLACE INTO %s (%s) VALUES %%s]]):format(t, concat(cs, ","))
  val_fmt[t] = get_val_fmt(#cs)
end

local function get_tuple(table, entry)
  local tuple = {}
  for _, k in ipairs(cols[table]) do
    local v = entry[k]
    if type(v) == 'string' then
      v = v:gsub('"', '""')
    end
    insert(tuple, v)
  end
  return tuple
end

local function get_cmd_and_ids(table, entries)
  local tuples, ids = {}, {}
  for _, entry in pairs(entries) do
    insert(tuples, val_fmt[table]:format(unpack(get_tuple(table, entry))))
    insert(ids, entry.id)
  end
  return replace_sqls[table]:format(concat(tuples, ",")), ids
end

local function clean_cdb(cdb, table, ids)
  local del = delete_sql:format(table, concat(ids, ","))
  local err = cdb:exec(del)
  if err ~= sqlite.OK then
    Logs.warning("Error while cleaning .cdb. Error code: ", err)
  end
end

local function write_cdb(cdbfp, entries, clean)
  local cdb = open_cdb(cdbfp)
  for _, table in ipairs(tables) do
    local command, ids = get_cmd_and_ids(table, entries)
    local err = cdb:exec(command)
    if err ~= sqlite.OK then
      Logs.warning("Error while writing .cdb. Error code: ", err)
    elseif clean then
      clean_cdb(cdb, table, ids)
    end
  end
  cdb:close()
end

local script_template = "-- %s\
local s, id = GetID()\
function s.initial_effect(c)\
  %s\
end\
"
local st_activate = "-- activate\
  local e1 = Effect.CreateEffect(c)\
  e1:SetType(EFFECT_TYPE_ACTIVATE)\
  e1:SetCode(EVENT_FREE_CHAIN)\
  c:RegisterEffect(e1)"
local function write_scripts(entries)
  for _, entry in pairs(entries) do
    local t, types = entry.type, GameConst.code.type
    local script
    if bit.band(t, types.MONSTER) ~= 0 and bit.band(t, types.NORMAL) == 0 then
      script = script_template:format(entry.name, "-- effects")
    elseif bit.band(t, types.SPELL + types.TRAP) ~= 0 then
      script = script_template:format(entry.name, st_activate)
    end
    local fp = path.join("script", ("c%d.lua"):format(entry.id))
    if script and not fs.exists(fp) then
      local f = io.open(fp, "w")
      if f then
        f:write(script)
        f:close()
      end
    end
  end
end

local function sets_to_code(sets)
  local setcodes = {}
  for id, set in pairs(sets) do
    local code, name = tonumber(set.code or ""), set.name
    if code and name then
      setcodes[code] = name
    end
  end
  return setcodes
end

local function gsub_sets(f, setcodes)
  local unwritten = {}
  for code, name in pairs(setcodes) do unwritten[code] = name end
  local lines = ""
  if f then
    for line in f:lines() do
      local code = tonumber(line:match("^%s*!setname%s+(0x%x+).*$") or "")
      local name = setcodes[code]
      if name then
        unwritten[code] = nil
        lines = lines .. ("!setname 0x%04x %s\n"):format(code, name)
      else
        lines = lines .. line .. "\n"
      end
    end
    f:close()
  end
  for code, name in pairs(unwritten) do
    lines = lines .. ("!setname 0x%04x %s\n"):format(code, name)
  end
  return lines
end

function Writer.write_sets(sets)
  local setcodes = sets_to_code(sets)
  if not next(setcodes) then return end
  local fp = path.join("expansions", "strings.conf")
  local f = io.open(fp, "r")
  local text = gsub_sets(f, setcodes)
  local f = io.open(fp, "w")
  if not f then return end
  f:write(text)
  f:close()
end

function Writer.write_entries(cdbfp, entries, clean)
  write_cdb(cdbfp, entries, clean)
  write_scripts(entries)
end

return Writer
