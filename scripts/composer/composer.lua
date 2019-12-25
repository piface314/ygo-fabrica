local DataFetcher = require 'scripts.composer.data-fetcher'
local Decoder = require 'scripts.composer.decoder'


local Composer = {}

function Composer.main(imgfolder, cdbfp, mode)
  local data = DataFetcher.get(imgfolder, cdbfp)
  for _, d in ipairs(data) do
    local layers = Decoder.decode(d, mode)
  end
end

return Composer
