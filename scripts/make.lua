local toml = require 'toml'
local path = require 'path'
local Logs = require 'scripts.logs'
local Config = require 'scripts.config'
local DataFetcher = require 'scripts.make.data-fetcher'
local MacroExpander = require 'scripts.make.macro-expander'


local PWD

local insert = table.insert

local function get_expansions(all, expansion)
  if all then
    return Config.get_all(PWD, 'expansion')
  elseif expansion then
    local exp = Config.get_one(PWD, 'expansion', expansion)
    Logs.assert(exp, 1, "Expansion \"", expansion, "\" is not configured.")
    return { [expansion] = exp }
  else
    return Config.get_defaults(PWD, 'expansion')
  end
end

local function get_files(recipe)
  local files = {}
  Logs.assert(type(recipe) == 'table', 1, "Recipe must be a list of filenames")
  for _, file in ipairs(recipe) do
    insert(files, path.join(PWD, file))
  end
  return files
end

return function(pwd, flags, exp)
  PWD = pwd
  local expansions = get_expansions(flags['--all'], exp)
  for id, exp in pairs(expansions) do
    Logs.info("Making \"", id, "\"...")
    local files = get_files(exp.recipe)
    local data = DataFetcher.get(files)
    local sets, cards = MacroExpander.expand(data)
    print(toml.encode(sets))
    print(toml.encode(cards))
  end
end
