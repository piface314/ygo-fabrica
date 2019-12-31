local DataFetcher = require 'scripts.composer.data-fetcher'
local Decoder = require 'scripts.composer.decoder'
local Assembler = require 'scripts.composer.assembler'
local Printer = require 'scripts.composer.printer'
local Logs = require 'scripts.logs'


local Composer = {}

function Composer.compose(imgfolder, cdbfp, mode, outfolder, options)
  author = author and author:upper()
  local data = DataFetcher.get(imgfolder, cdbfp)
  local metalayers_set = {}
  for _, d in ipairs(data) do
    local metalayers, msg = Decoder.decode(mode, d)
    if metalayers then
      metalayers_set[d.id] = metalayers
    else
      Logs.warning(("Failed at decoding %s: "):format(data.id), msg)
    end
  end
  Printer.set_out_folder(outfolder)
  Printer.set_extension(options.ext)
  Printer.set_size(options.size)
  for id, metalayers in pairs(metalayers_set) do
    local img = Assembler.assemble(mode, metalayers, opt)
    Printer.print(id, img)
  end
end

return Composer
