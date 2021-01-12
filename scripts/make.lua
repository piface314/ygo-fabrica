local path = require'lib.fs'.path
local Logs = require 'lib.logs'
local Config = require 'scripts.config'
local DataFetcher = require 'scripts.make.data-fetcher'
local Parser = require 'scripts.make.parser'
local Encoder = require 'scripts.make.encoder'
local Writer = require 'scripts.make.writer'
local i18n = require 'lib.i18n'

local function get_expansions(all, id)
  return Config.groups.from_flag.get_many('expansion', all or id and {id})
end

local function get_files(recipe)
  local files = {}
  Logs.assert(type(recipe) == 'table', i18n 'make.recipe_not_list')
  for _, file in ipairs(recipe) do
    table.insert(files, file)
  end
  return files
end

return function(flags, exp)
  local all = flags['--all']
  local expansions = get_expansions(all, exp)
  for id, expansion in pairs(expansions) do
    local cdbfp = path.join('expansions', id .. '.cdb')
    Logs.info(i18n('make.status', {id}))
    local files = get_files(expansion.recipe)
    local data = DataFetcher.get(files)
    local sets, cards = Parser.parse(data)
    local entries = Encoder.encode(sets, cards)
    Writer.write_sets(sets)
    Writer.write_entries(cdbfp, entries, flags['--clean'])
  end
end
