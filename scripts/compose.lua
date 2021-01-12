local path = require'lib.fs'.path
local Composer = require 'scripts.composer.composer'
local Config = require 'scripts.config'
local Logs = require 'lib.logs'
local i18n = require 'lib.i18n'
require 'lib.table'

return function(flags)
  local imgfolder = path.join('artwork')
  local fe = flags['-Eall'] or flags['-e']
  local fp = flags['-Pall'] or flags['-p']
  local exps = Config.groups.from_flag.get_many('expansion', fe)
  local picsets = Config.groups.from_flag.get_many('picset', fp)
  for picset, pscfg in pairs(picsets) do
    local outfolder = path.join('pics', picset)
    for exp, _ in pairs(exps) do
      Logs.info(i18n('compose.status', {picset, exp}))
      local cdbfp = path.join('expansions', exp .. '.cdb')
      Composer.compose(pscfg.mode, imgfolder, cdbfp, outfolder, pscfg)
    end
  end
end
