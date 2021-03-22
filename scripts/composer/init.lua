local DataFetcher = require 'scripts.composer.data-fetcher'
local Printer = require 'scripts.composer.printer'
local Logs = require 'lib.logs'
local i18n = require 'i18n'
local path = require 'lib.path'
local fun = require 'lib.fun'

local Composer = {}

--- @type Decoder
local field_decoder = require 'scripts.composer.field-decoder'

local modes = fun.iter(path.each(path.prjoin('scripts', 'composer', 'modes', '')))
  :map(function(fp) return dofile(path.join(fp, 'decoder.lua')) end)
  :map(function(d) return d.mode, d end)
  :tomap()

--- Returns the `Decoder` of the specified mode
--- @param mode string
--- @return Decoder
local function get_mode(mode)
  local decoder = modes[mode]
  Logs.assert(decoder, i18n('compose.unknown_mode', {mode}))
  return decoder
end

local function show_layers(card, layers)
  local label = card.id
  local sl = fun.iter(layers):map(tostring):totable()
  local s = table.concat(sl, '\n'  .. (' '):rep(#label + 2) .. ', ')
  return ('%s: [ %s ]'):format(label, s)
end

local function decode(decoder, cards, options)
  local bar, prelabel = Logs.bar(#cards), nil
  local cards_layered = fun.iter(cards):map(function(card)
    local id = card.id
    bar:update(i18n('compose.decoding', {id}), prelabel)
    prelabel = nil
    local layers, err = decoder:decode(card, options)
    local field_l = options.field and field_decoder:decode(card, options)
    if err then
      prelabel = Logs.warning_s(i18n('compose.decode_fail', {id}), err)
    elseif options.verbose then
      prelabel = show_layers(card, layers)
    end
    return {id, layers, field_l}
  end):filter(function(t) return t[2] end):totable()
  bar:finish(i18n 'compose.done', prelabel)
  return cards_layered
end

local function render(decoder, cards)
  local bar = Logs.bar(#cards)
  local pics = fun.iter(cards):map(function(t)
    local id, layers, field_l = unpack(t)
    bar:update(i18n('compose.rendering', {id}))
    local field_pic = field_l and field_decoder:render(field_l)
    return {id, decoder:render(layers), field_pic}
  end):totable()
  bar:finish(i18n 'compose.done')
  return pics
end

local function print_pics(pics)
  local bar = Logs.bar(#pics)
  for _, t in ipairs(pics) do
    local id, pic, field_pic = unpack(t)
    bar:update(i18n('compose.printing', {id}))
    Printer.print(id, pic)
    Printer.print_field(id, field_pic)
  end
  bar:finish(i18n 'compose.done')
end

--- Generates card pics with a given `mode`, taking images from `imgfolder`,
--- combining them with data found in a card database in `cdbfp`, and
--- outputting them to `outfolder`. `options` can be specified for customization.
--- @param mode "'proxy'" | "'anime'"
--- @param imgfolder string
--- @param cdbfp string
--- @param outfolder string
--- @param options table
function Composer.compose(mode, imgfolder, cdbfp, outfolder, options)
  local decoder = get_mode(mode)
  Logs.assert(imgfolder ~= outfolder, i18n 'compose.output_conflict')
  decoder:set_locale(options.locale)
  field_decoder:set_locale(options.locale)
  local cards = DataFetcher.get(imgfolder, cdbfp)
  local cards_layered = decode(decoder, cards, options)
  local pics = render(decoder, cards_layered)
  Printer.configure(outfolder, options)
  print_pics(pics)
end

return Composer
