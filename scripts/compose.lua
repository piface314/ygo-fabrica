local Composer = require 'scripts.composer.composer'
local Config = require 'scripts.config'
local path = require 'path'


local PWD

return function(pwd, flags)
  local _, pack_name = path.split(pwd)
  local imgfolder = path.join(pwd, "artwork")
  local cdbfp = path.join(pwd, pack_name .. ".cdb")
  Composer.main(imgfolder, cdbfp)
end
