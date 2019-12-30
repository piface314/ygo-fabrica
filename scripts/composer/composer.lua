local DataFetcher = require 'scripts.composer.data-fetcher'
local Decoder = require 'scripts.composer.decoder'


local Composer = {}

function Composer.main(imgfolder, cdbfp, mode, year, author)
  author = author and author:upper()
  local data = DataFetcher.get(imgfolder, cdbfp)
  for _, d in ipairs(data) do
    local layers = Decoder.decode(d, mode, year, author)
    print(">>")
    for _, layer in ipairs(layers) do print(layer) end
    print()
  end
end

return Composer
