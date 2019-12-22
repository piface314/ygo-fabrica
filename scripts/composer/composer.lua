local DataFetcher = require 'scripts.composer.data-fetcher'


local Composer = {}

function Composer.main(imgfolder, cdbfp)
  local data = DataFetcher.get(imgfolder, cdbfp)
end

return Composer
