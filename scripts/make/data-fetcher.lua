local toml = require 'toml'
local Logs = require 'lib.logs'


local DataFetcher = {}

local insert = table.insert

local function read_file(fp)
  local f, msg = io.open(fp, "r")
  Logs.assert(f, 1, msg)
  local str = f:read("*a")
  f:close()
  return str
end

local function merge(files)
  local raw = ""
  for _, fp in ipairs(files) do
    raw = raw .. read_file(fp) .. "\n"
  end
  return toml.parse(raw)
end

function DataFetcher.get(files)
  return merge(files)
end

return DataFetcher
