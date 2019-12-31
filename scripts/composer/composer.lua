local DataFetcher = require 'scripts.composer.data-fetcher'
local Decoder = require 'scripts.composer.decoder'
local Assembler = require 'scripts.composer.assembler'
local Printer = require 'scripts.composer.printer'
local Logs = require 'scripts.logs'


local Composer = {}

local modes = { anime = true, proxy = true }

function Composer.compose(imgfolder, cdbfp, mode, outfolder, options)
  Logs.assert(modes[mode], 1, "unknown mode \"", mode, '"')
  local data = DataFetcher.get(imgfolder, cdbfp)
  local metalayers_set, n = {}, 0
  Decoder.set_mode(mode)
  for _, d in ipairs(data) do
    local metalayers, msg = Decoder.decode(d)
    if metalayers then
      metalayers_set[d.id] = metalayers
      n = n + 1
    else
      Logs.warning(("Failed at decoding %s: "):format(data.id), msg)
    end
  end
  Assembler.set_mode(mode)
  Assembler.set_options(options)
  Printer.set_out_folder(outfolder)
  Printer.set_extension(options.ext)
  Printer.set_size(options.size)
  local i = 0
  for id, metalayers in pairs(metalayers_set) do
    local img = Assembler.assemble(metalayers)
    Printer.print(id, img)
    i = i + 1
  end
end

return Composer
