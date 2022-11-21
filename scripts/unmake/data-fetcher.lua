local sqlite = require 'lsqlite3complete'
local Logs = require 'lib.logs'
local i18n = require 'i18n'
local fun = require 'lib.fun'

local DataFetcher = {}

local function get_custom_cols(cdb)
  return fun.iter(cdb:nrows 'PRAGMA table_info(custom)')
    :map(function(col) return col.name, true end)
    :tomap()
end

local SELECT_TEMPLATE = 'SELECT * FROM %s'
local function read_cdb(cdb)
  local sql = SELECT_TEMPLATE:format('texts NATURAL JOIN datas')
  local s, cards = pcall(function()
    local custom_cols = get_custom_cols(cdb)
    local cards = {}
    for row in cdb:nrows(sql) do
      row.id = tostring(row.id)
      cards[row.id] = row
    end
    if next(custom_cols) then
      for row in cdb:nrows(SELECT_TEMPLATE:format('custom')) do
        for col in pairs(custom_cols) do
          local id, v = tostring(row.id), row[col]
          cards[id][col] = v
        end
      end
    end
    cdb:close()
    return cards
  end)
  Logs.assert(s, i18n 'unmake.data_fetcher.read_db_fail', s and '' or cards)
  cards = fun.iter(cards):map(function(_, c) return c end):totable()
  return table.sort(cards, function(a, b) return a.id < b.id end)
end

function DataFetcher.get(cdbfp)
  local cdb = sqlite.open(cdbfp)
  Logs.assert(cdb and cdb:isopen(), i18n 'unmake.data_fetcher.closed_db')
  return read_cdb(cdb)
end

return DataFetcher