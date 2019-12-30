local path = require 'path'
local fs = require 'lfs'
local Composer = require 'scripts.composer.composer'
local Config = require 'scripts.config'
local Logs = require 'scripts.logs'


local PWD

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
  local cdbfp = path.join(pwd, pack_name .. ".cdb")
  local fp = flags['-Pall'] or flags['-p']
  local picsets = get_picsets(fp)
  for picset, pscfg in pairs(picsets) do
    Composer.main(imgfolder, cdbfp, pscfg.mode, pscfg.year, pscfg.author)
  end
end
