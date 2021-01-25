local DataFetcher = require 'scripts.composer.data-fetcher'
local Printer = require 'scripts.composer.printer'
local Logs = require 'lib.logs'
local i18n = require 'lib.i18n'
local path = require 'lib.path'
local fun = require 'lib.fun'

local Composer = {}

--- @type Decoder
local f_decoder = require 'scripts.composer.field-decoder'

local modes = fun(path.each(path.prjoin('scripts', 'composer', 'modes', '')))
  :map(function(fp) return dofile(path.join(fp, 'decoder.lua')) end)
  :hashmap(fun 'd -> d.mode, d')

--- Returns the `Decoder` of the specified mode
---@param mode string
---@return Decoder
local function get_mode(mode)
  local decoder = modes(mode)
  Logs.assert(decoder, i18n('compose.unknown_mode', {mode}))
  return decoder
end

local function show_layers(card, layers)
  local label = card.id
  local sl = layers:map(fun 'l -> tostring(l)')
  local s = table.concat(sl, '\n'  .. (' '):rep(#label + 2) .. ', ')
  Logs.info(('%s: [ %s ]'):format(label, s))
end

function Composer.compose(mode, imgfolder, cdbfp, outfolder, options)
  local decoder = get_mode(mode)
  Logs.assert(imgfolder ~= outfolder, i18n 'compose.output_conflict')
  local cards = DataFetcher.get(imgfolder, cdbfp)
  local bar = Logs.bar(#cards)
  local cards_layered = cards:map(function(card)
    local id = card.id
    bar:update(i18n('compose.decoding', {id}))
    local layers, err = decoder:decode(card, options)
    local field_layers = options.field and f_decoder:decode(card)
    if err then
      Logs.warning(i18n('compose.decode_fail', {id}), err)
    elseif options.verbose then
      show_layers(card, layers)
    end
    return {id, layers, field_layers}
  end):filter(fun 't -> t[2]')
  bar:finish(i18n 'compose.done')
  Printer.configure(outfolder, options)
  bar = Logs.bar(#cards_layered)
  local pics = cards_layered:map(function(t)
    local id, layers, field_layers = unpack(t)
    bar:update(i18n('compose.rendering', {id}))
    local field_pic = field_layers and f_decoder:render(field_layers)
    return {id, decoder:render(layers), field_pic}
  end)
  bar:finish(i18n 'compose.done')
  bar = Logs.bar(#pics)
  pics:foreach(function(t)
    local id, pic, field_pic = unpack(t)
    bar:update(i18n('compose.printing', {id}))
    Printer.print(id, pic)
    Printer.print_field(id, field_pic)
  end)
  bar:finish(i18n 'compose.done')
end

return Composer
