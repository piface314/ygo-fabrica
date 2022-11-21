local Logs = require 'lib.logs'
local DataFetcher = require 'scripts.unmake.data-fetcher'
local Decoder = require 'scripts.unmake.decoder'
local Writer = require 'scripts.unmake.writer'
local i18n = require 'i18n'


return function(flags, cdbfp, tomlfp)
  Logs.assert(cdbfp, i18n 'unmake.no_cdbfp')
  Logs.assert(tomlfp, i18n 'unmake.no_tomlfp')
  Logs.info(i18n('unmake.status', {tomlfp}))
  local data = DataFetcher.get(cdbfp)
  local cards = Decoder.decode(data)
  Writer.write(tomlfp, cards)
  Logs.ok(i18n 'unmake.done')
end
