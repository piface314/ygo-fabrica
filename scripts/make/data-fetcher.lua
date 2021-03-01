local toml = require 'toml'
local Logs = require 'lib.logs'
local i18n = require 'i18n'
local fun = require 'lib.fun'

local DataFetcher = {}

local function errmsg(err)
  if type(err) ~= 'string' then return end
  return err:match('TOML:%s*(.*)$')
end

local function read_file(fp)
  local f, msg = io.open(fp, 'r')
  Logs.assert(f, msg)
  local str = f:read('*a')
  f:close()
  local s, p = pcall(toml.parse, str)
  Logs.assert(s, i18n 'make.data_fetcher.toml_error', ' ', errmsg(p))
  return p
end

function DataFetcher.get(files)
  return table.merge(fun.iter(files):map(read_file):unpack())
end

return DataFetcher
