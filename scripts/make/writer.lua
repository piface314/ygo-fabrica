local sqlite = require 'lsqlite3complete'
local Logs = require 'scripts.logs'


local Writer = {}

local insert, concat = table.insert, table.concat

local tables = {'texts', 'datas'}

local drop = [[DROP TABLE IF EXISTS %s]]
local function open_cdb(cdbfp, clean)
  local db, err, msg = sqlite.open(cdbfp)
  Logs.assert(db, err, msg)
  local sqlf = io.open(path.join("res", "new", "create-cdb.sql"), "r")
  local create_sql = sqlf:read("*a")
  sqlf:close()
  if clean then
    local drops = {}
    for _, t in ipairs(tables) do insert(drops, drop:format(t)) end
    db:exec(concat(drops, ";"))
  end
  db:exec(create_sql)
  return db
end

local function get_val_fmt(n)
  local s = ("\"%s\","):rep(n):sub(1, -2)
  return "(" .. s .. ")"
end

local cols = {
  texts = { "id", "name", "desc", "str1", "str2", "str3", "str4", "str5", "str6", "str7",
    "str8", "str9", "str10", "str11", "str12", "str13", "str14", "str15", "str16" },
  datas = { "id", "ot", "alias", "setcode", "type", "atk", "def", "level",
  "race", "attribute", "category" }
}

local sqls = {}
for k, v in pairs(cols) do
  sqls[k] = ([[REPLACE INTO %s (%s) VALUES %%s]]):format(k, concat(v, ","))
end

local val_fmt = { texts = get_val_fmt(19), datas = get_val_fmt(11) }

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

local function get_command(table, entries)
  local tuples = {}
  for _, entry in pairs(entries) do
    insert(tuples, val_fmt[table]:format(unpack(get_tuple(table, entry))))
  end
  return sqls[table]:format(concat(tuples, ","))
end

function Writer.write(cdbfp, entries, clean)
  local cdb = open_cdb(cdbfp, clean)
  for _, table in ipairs(tables) do
    local command = get_command(table, entries)
    local err = cdb:exec(command)
    if err ~= sqlite.OK then
      Logs.warning("Error while writing .cdb. Error code: ", err)
    end
  end
  cdb:close()
end

return Writer
