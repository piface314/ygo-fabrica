local path = require 'path'
local Composer = require 'scripts.composer.composer'
local Config = require 'scripts.config'
local Logs = require 'lib.logs'
require 'lib.table'


local PWD
local keys = table.keys

local function get_expansions(flag_e)
  local all = flag_e and not flag_e[1]
  local expansion = flag_e and flag_e[1]
  if all then
    local exps = Config.get_all(PWD, 'expansion')
    return keys(exps)
  elseif expansion then
    local exp = Config.get_one(PWD, 'expansion', expansion)
    Logs.assert(exp, 1, "Expansion \"", expansion, "\" is not configured.")
    return { expansion }
  else
    local exps = Config.get_defaults(PWD, 'expansion')
    return keys(exps)
  end
end

local function get_picsets(flag_p)
  local all = flag_p and not flag_p[1]
  local picset = flag_p and flag_p[1]
  if all then
    return Config.get_all(PWD, 'picset')
  elseif picset then
    local ps = Config.get_one(PWD, 'picset', picset)
    Logs.assert(ps, 1, "Pic set \"", picset, "\" is not configured.")
    return { [picset] = ps }
  else
    return Config.get_defaults(PWD, 'picset')
  end
end

return function(pwd, flags)
  PWD = pwd
  local _, pack_name = path.split(pwd)
  local imgfolder = path.join(pwd, "artwork")
  local fe = flags['-Eall'] or flags['-e']
  local fp = flags['-Pall'] or flags['-p']
  local exps = get_expansions(fe)
  local picsets = get_picsets(fp)
  for picset, pscfg in pairs(picsets) do
    local outfolder = path.join(pwd, "pics", picset)
    for _, exp in pairs(exps) do
      Logs.info("Composing \"", picset, "\" with ", exp,"...")
      cdbfp = path.join(pwd, "expansions", exp .. ".cdb")
      Composer.compose(pscfg.mode, imgfolder, cdbfp, outfolder, pscfg)
    end
  end
end
