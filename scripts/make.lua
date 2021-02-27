local path = require'lib.path'
local Logs = require 'lib.logs'
local Config = require 'scripts.config'
local DataFetcher = require 'scripts.make.data-fetcher'
local Parser = require 'scripts.make.parser'
local Encoder = require 'scripts.make.encoder'
local Writer = require 'scripts.make.writer'
local i18n = require 'i18n'
local fun = require 'lib.fun'

local function get_expansions(all, id)
  return Config.groups.from_flag.get_many('expansion', all or id and {id})
end

local function get_files(recipe)
  Logs.assert(type(recipe) == 'table', i18n 'make.recipe_not_list')
  return table.copy(recipe)
end

local key_to_string = {counter = 'counter', set = 'setname'}

return function(flags, exp)
  local all = flags['--all']
  local overwrite = flags['--overwrite'] or flags['-ow']
  local expansions = get_expansions(all, exp)
  for id, expansion in pairs(expansions) do
    local cdbfp = path.join('expansions', id .. '.cdb')
    local strfp = path.join('expansions', id .. '-strings.conf')
    Logs.info(i18n('make.status', {id}))
    local files = get_files(expansion.recipe)
    local data = DataFetcher.get(files)
    local cards = Parser.parse(data, 'card')
    local strings = fun.iter(key_to_string):map(function(ink, outk)
      return outk, Parser.parse(data, ink)
    end):tomap()
    Encoder.set_locale(expansion.locale or i18n.getLocale())
    local entries = Encoder.encode(cards, strings.setname)
    Writer.write_strings(strfp, strings, overwrite)
    Writer.write_entries(cdbfp, entries, overwrite)
    Writer.write_scripts(entries)
    Logs.ok(i18n 'make.done')
  end
end
