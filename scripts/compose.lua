local path = require'lib.path'
local Composer = require 'scripts.composer'
local Config = require 'scripts.config'
local Logs = require 'lib.logs'
local i18n = require 'i18n'

return function(flags)
  local imgfolder = path.join('artwork')
  local fe = flags['-Eall'] or flags['-e']
  local fp = flags['-Pall'] or flags['-p']
  local exps = Config.groups.from_flag.get_many('expansion', fe)
  local picsets = Config.groups.from_flag.get_many('picset', fp)
  for picset, pscfg in pairs(picsets) do
    local outfolder = path.join('pics', picset)
    for eid, exp in pairs(exps) do
      Logs.info(i18n('compose.status', {picset, eid}))
      local cdbfp = path.join('expansions', eid .. '.cdb')
      local options = table.deepcopy(pscfg)
      options.holo = options.holo == false and 0 or 1
      options.locale = options.locale or exp.locale
      Composer.compose(pscfg.mode, imgfolder, cdbfp, outfolder, options)
    end
  end
end
