local path = require 'lib.path'
local sqlite = require 'lsqlite3complete'
local Logs = require 'lib.logs'
local i18n = require 'i18n'
local fun = require 'lib.fun'

local tables = {
  texts = {
    'id', 'name', 'desc', 'str1', 'str2', 'str3', 'str4', 'str5', 'str6',
    'str7', 'str8', 'str9', 'str10', 'str11', 'str12', 'str13', 'str14',
    'str15', 'str16'
  },
  datas = {
    'id', 'ot', 'alias', 'setcode', 'type', 'atk', 'def', 'level', 'race',
    'attribute', 'category'
  }
}

local custom_cols = {
  holo = 'INTEGER',
  year = 'INTEGER',
  author = 'TEXT',
  setnumber = 'TEXT'
}

local DELETE_SQL = 'DELETE FROM %s WHERE id NOT IN (%s);'
local REPLACE_SQL = 'REPLACE INTO %s (%s) VALUES %s;'
local CUSTOM_ADDCOL_SQL = 'ALTER TABLE custom ADD COLUMN %s %s;'
local CUSTOM_TABLE_SQL = [[
CREATE TABLE IF NOT EXISTS custom (
  id INTEGER NOT NULL,
  PRIMARY KEY(id)
);]]

--- Returns an SQL statement to write `tuples` into the specified table
--- @param table_name string
--- @param col_names string[]
--- @param tuples string[]
--- @return string
local function get_replace_sql(table_name, col_names, tuples)
  col_names = table.concat(col_names, ',')
  tuples = table.concat(tuples, ',')
  return REPLACE_SQL:format(table_name, col_names, tuples)
end

--- Formats an entry to a tuple
--- @param cols string[] list of column names
--- @param entry table card data entry
--- @return string
local function get_tuple(cols, entry)
  local vals = fun.iter(cols):map(function(col)
    local v = entry[col]
    return type(v) == 'string' and '"' .. v:gsub('"', '""') .. '"' or v or 'NULL'
  end):totable()
  return '(' .. table.concat(vals, ',') .. ')'
end

--- Opens a card database from a filepath and returns its handle
--- @param cdbfp string card database file path
--- @return Database
local function open_cdb(cdbfp)
  local cdb, _, msg = sqlite.open(cdbfp)
  Logs.assert(cdb, msg)
  local sqlf = io.open(path.prjoin('res', 'new', 'create-cdb.sql'), 'r')
  local create_sql = sqlf:read('*a')
  sqlf:close()
  local err = cdb:exec(create_sql)
  Logs.assert(err == sqlite.OK, i18n 'make.writer.create_error', cdb:errmsg())
  return cdb
end

--- Returns column names that are missing from the custom table
--- @param cdb Database
--- @return table
local function get_missing_custom_cols(cdb)
  local missing = fun.iter(custom_cols):tomap()
  for col in cdb:nrows 'PRAGMA table_info(custom)' do
    missing[col.name] = nil
  end
  return missing
end

--- Writes data related to the custom table, returning true if
--- any custom data was written.
--- @param cdb Database database handle
--- @param entries CardData[]
--- @return boolean
local function write_custom(cdb, entries)
  local cols, missing = {}, get_missing_custom_cols(cdb)
  for _, e in pairs(entries) do
    for c in pairs(custom_cols) do cols[c] = e[c] end
  end
  if next(cols) == nil then return false end
  local add_sql = table.concat(fun.iter(cols)
    :filter(function(c) return missing[c] ~= nil end)
    :map(function(c) return CUSTOM_ADDCOL_SQL:format(c, custom_cols[c]) end)
    :totable())
  cols = fun.chain({'id'}, cols):totable()
  local tuples = fun.iter(entries):map(function(e) return get_tuple(cols, e) end):totable()
  local repl_sql = get_replace_sql('custom', cols, tuples)
  local sql = CUSTOM_TABLE_SQL .. add_sql .. repl_sql
  local err = cdb:exec(sql)
  if err ~= sqlite.OK then
    Logs.warning(i18n 'make.writer.custom_error', cdb:errmsg())
    return false
  end
  return true
end

--- Cleans rows that were not written by `ygofab make`
--- @param cdb Database database handle
--- @param ctables string[] names of SQLite tables to be cleaned
--- @param entries CardData[] entries that were written
local function clean_cdb(cdb, ctables, entries)
  local ids = table.concat(fun.iter(entries):map(function(e) return e.id end):totable(), ',')
  local dels = fun.iter(ctables):map(function(t) return DELETE_SQL:format(t, ids) end):totable()
  local err = cdb:exec(table.concat(dels))
  if err ~= sqlite.OK then
    Logs.warning(i18n 'make.writer.clean_error', cdb:errmsg())
  end
end

--- Writes `entries` to a card database (.cdb file)
--- @param cdbfp string card database file path
--- @param entries CardData[] entries to be written
--- @param overwrite boolean if `true`, old .cdb is overwritten
local function write_cdb(cdbfp, entries, overwrite)
  local cdb = open_cdb(cdbfp)
  if next(entries) == nil then
    Logs.warning(i18n 'make.writer.no_data')
    return
  end
  local sql = fun.iter(tables):map(function(t, cols)
    local tuples = fun.iter(entries):map(function(e) return get_tuple(cols, e) end)
    return get_replace_sql(t, cols, tuples:totable())
  end):totable()
  local err = cdb:exec(table.concat(sql))
  if err ~= sqlite.OK then
    Logs.warning(i18n 'make.writer.write_error', cdb:errmsg())
    return cdb:close()
  end
  local ctables = fun.iter(tables):totable()
  if write_custom(cdb, entries) then table.insert(ctables, 'custom') end
  if overwrite then clean_cdb(cdb, ctables, entries) end
  cdb:close()
end

return write_cdb