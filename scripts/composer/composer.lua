local DataFetcher = require 'scripts.composer.data-fetcher'
local Decoder = require 'scripts.composer.decoder'
local Assembler = require 'scripts.composer.assembler'
local Printer = require 'scripts.composer.printer'
local Logs = require 'lib.logs'
local i18n = require 'lib.i18n'

local Composer = {}

local modes = {anime = true, proxy = true}
local function check_mode(mode)
  return modes[mode]
end

local function check_folders(imgfolder, outfolder)
  Logs.assert(imgfolder ~= outfolder, i18n('compose.output_conflict'))
end

function Composer.compose(mode, imgfolder, cdbfp, outfolder, options)
  Logs.assert(check_mode(mode), i18n('compose.unknown_mode', {mode}))
  check_folders(imgfolder, outfolder)
  local data = DataFetcher.get(imgfolder, cdbfp)
  local metalayers_set, n = {}, 0
  Decoder.configure(mode, options)
  for _, d in ipairs(data) do
    local metalayers, msg = Decoder.decode(d)
    if metalayers then
      metalayers_set[d.id] = metalayers
      n = n + 1
    else
      Logs.warning(i18n('compose.decode_fail', {d.id}), msg)
    end
  end
  Assembler.configure(mode, options)
  Printer.configure(outfolder, options)
  local bar = Logs.bar(n)
  bar:print()
  for id, metalayers in pairs(metalayers_set) do
    bar:update(i18n('compose.generating', {id}))
    local img, field = Assembler.assemble(metalayers)
    Printer.print(id, img)
    if field then
      Printer.print_field(id, field)
    end
  end
  bar:finish(i18n('compose.done'))
end

return Composer
