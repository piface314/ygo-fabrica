local path = require 'lib.fs'.path
local Logs = require 'lib.logs'
local Config = require 'scripts.config'
local DataFetcher = require 'scripts.make.data-fetcher'
local Parser = require 'scripts.make.parser'
local Encoder = require 'scripts.make.encoder'
local Writer = require 'scripts.make.writer'


local insert = table.insert

local function get_expansions(all, expansion)
  if all then
    return Config.get_all('expansion')
  elseif expansion then
    local exp = Config.get_one('expansion', expansion)
    Logs.assert(exp, 1, 'Expansion "', expansion, '" is not configured.')
    return { [expansion] = exp }
  else
    return Config.get_defaults('expansion')
  end
end

local function get_files(recipe)
  local files = {}
  Logs.assert(type(recipe) == 'table', 1, "Recipe must be a list of filenames")
  for _, file in ipairs(recipe) do
    insert(files, file)
  end
  return files
end

return function(flags, exp)
  local expansions = get_expansions(flags['--all'], exp)
  for id, expansion in pairs(expansions) do
    local cdbfp = path.join("expansions", id .. ".cdb")
    Logs.info('Making "', id, '"...')
    local files = get_files(expansion.recipe)
    local data = DataFetcher.get(files)
    local sets, cards = Parser.parse(data)
    local entries = Encoder.encode(sets, cards)
    Writer.write_sets(sets)
    Writer.write_entries(cdbfp, entries, flags['--clean'])
  end
end
