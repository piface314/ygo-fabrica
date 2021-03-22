local Layer = require 'scripts.composer.layer'
local Logs = require 'lib.logs'
local Locale = require 'locale'
local fun = require 'lib.fun'
local i18n = require 'i18n'
local vips = require 'vips'

--- @alias State fun(card: CardData, opts: table): any, Layer

--- A `Decoder` defines a new mode for YGOFabrica Composer module.
--- It works as an automaton that takes as input card data extracted
--- from a database and outputs a list of `Layer`s, that will be
--- transformed into a final card image.
--- @class Decoder
--- @field mode string
--- @field states table<string, State>
--- @field initial string
--- @field base Image
--- @field locale string
local Decoder = {}
Decoder.__index = Decoder

local function badarg_t(a, c, e, g) return {arg = a, caller = c, exp = e, got = g} end
local function bad_mode(t) return badarg_t('mode', 'Decoder.new', 'string', t) end
local function bad_states(t) return badarg_t('states', 'Decoder.new', 'table', t) end
local function bad_state(t) return badarg_t('state', 'Decoder.add_state', 'function', t) end
local function bad_base(t) return badarg_t('base', 'Decoder.set_base', 'Image', t) end
local nil_state_id = i18n('nil_argument', {arg = 'state_id', caller = 'Decoder.add_state'})

local function check_transition(state, transition)
  if transition[1] or type(transition[2]) ~= 'string' then return true end
  local ok, errmsg = pcall(i18n, transition[2], transition[3])
  errmsg = ok and i18n('compose.decoder.error', {state}) .. errmsg
             or i18n('compose.decoder.unknown_error', {state})
  return false, errmsg
end

local function check_layer(state, i, layer)
  if Layer.is_layer(layer) then return layer end
  return nil, i18n('compose.decoder.not_layer',
    {arg = i, state = state, got = type(layer)})
end

--- Creates a new `Decoder` that defines a `mode`
--- @param mode string
--- @param base? Image
--- @param initial_state? string
--- @param states? table<string, State>
--- @return Decoder
function Decoder.new(mode, base, initial_state, states)
  local t_mode, t_states = type(mode), type(states)
  Logs.assert(t_mode == 'string', i18n('bad_argument', bad_mode(t_mode)))
  local d = setmetatable({mode = mode, states = {}}, Decoder)
  if states then
    Logs.assert(t_states == 'table', i18n('bad_argument', bad_states(t_states)))
    for state_id, state in pairs(states) do d:add_state(state_id, state) end
  end
  if base then d:set_base(base) end
  if initial_state then d:set_inital(initial_state) end
  return d
end

function Decoder:__tostring() return ('%s@Decoder'):format(self.mode) end

--- Sets a base Image that will be placed below `Layer`s
--- @param base Image
function Decoder:set_base(base)
  Logs.assert(vips.Image.is_Image(base), i18n('bad_argument', bad_base(type(base))))
  self.base = base
end

--- Adds a new state to the `Decoder`. Each state is identified by
--- its `state_id` and it is defined by a function that takes a single
--- parameter - a table containing arbitrary card data - and whose
--- return values must be:
--- 1. the next state id;
--- 2. any number of `Layer`s;
--- @param state_id any
--- @param state State
function Decoder:add_state(state_id, state)
  local t_state = type(state)
  Logs.assert(state_id ~= nil, nil_state_id)
  Logs.assert(t_state == 'function', i18n('bad_argument', bad_state(t_state)))
  self.states[state_id] = state
end

--- Sets which state is the initial state
--- @param state_id any
function Decoder:set_inital(state_id)
  Logs.assert(self.states[state_id],
    i18n('compose.decoder.state_key_err', {state_id}))
  self.initial = state_id
end

--- Sets which locale should be used when decoding and rendering cards
--- @param locale string
function Decoder:set_locale(locale) self.locale = locale end

--- Turns a `card` into a list of `Layer`s
--- @param card CardData
--- @param options table
--- @return Layer[]
function Decoder:decode(card, options)
  local locale = Locale.get()
  local state_id = self.initial
  local state, layers = self.states[state_id], {}
  while state do
    Locale.set(self.locale)
    local transition = {state(card, options)}
    Locale.set(locale)
    local ok, errmsg = check_transition(state_id, transition)
    if not ok then return nil, errmsg end
    for i = 2, #transition do
      local layer, errmsg = check_layer(state_id, i, transition[i])
      if not layer then return nil, errmsg end
      table.insert(layers, layer)
    end
    state_id = transition[1]
    state = self.states[state_id]
  end
  return #layers > 0 and layers
end

--- Reduces a list of `Layer`s into a single card image
--- @param layers Layer[]
--- @return Image
function Decoder:render(layers)
  local locale = Locale.get()
  Locale.set(self.locale)
  local image = fun.iter(layers):reduce(self.base, function(img, layer)
    return img:composite(layer:render(), 'over')
  end)
  Locale.set(locale)
  return image
end

setmetatable(Decoder, {__call = function(_, ...) return _.new(...) end})

return Decoder
