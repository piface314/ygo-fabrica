local Layer = require 'scripts.composer.layer'
local Logs = require 'lib.logs'
local fun = require 'lib.fun'
local i18n = require 'lib.i18n'
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
local Decoder = {}
Decoder.__index = Decoder

local bad_mode = fun 't -> {arg="mode",caller="Decoder.new",exp="string",got=t}'
local bad_states = fun 't -> {arg="states",caller="Decoder.new",exp="table",got=t}'
local bad_state = fun 't -> {arg="state",caller="Decoder.add_state",exp="function",got=t}'
local bad_base = fun 't -> {arg="base",caller="Decoder.set_base",exp="Image",got=t}'
local nil_state_id = i18n('nil_argument', {arg = 'state_id', caller = 'Decoder.add_state'})
local function check_layer(i, layer)
  if type(layer) == 'table' and getmetatable(layer) == Layer then
    return layer
  elseif type(layer) == 'string' then
    return nil, layer
  end
  return nil, layer and i18n('compose.decoder.not_layer', {i, type(layer)})
end

--- Creates a new `Decoder` that defines `mode`
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
    for state_id, state in pairs(states) do
      d:add_state(state_id, state)
    end
  end
  if base then d:set_base(base) end
  if initial_state then d:set_inital(initial_state) end
  return d
end

function Decoder:__tostring()
  return ('%s@Decoder'):format(self.mode)
end

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
  Logs.assert(self.states[state_id], i18n('compose.decoder.state_key_err', {state_id}))
  self.initial = state_id
end

--- Turns a `card` into a list of `Layer`s
--- @param card CardData
--- @return Fun
function Decoder:decode(card, options)
  local current_state = self.states[self.initial]
  local layers = fun {}
  while current_state do
    local transition, i = {current_state(card, options)}, 2
    while transition[i] do
      local layer, errmsg = check_layer(i, transition[i])
      if not layer then return nil, errmsg end
      layers:push(layer)
      i = i + 1
    end
    current_state = self.states[transition[1]]
  end
  return #layers > 0 and layers
end

--- Reduces a list of `Layer`s into a single card image
--- @param layers Fun
--- @return Image
function Decoder:render(layers)
  return layers:reduce(self.base, function (img, layer)
    return img:composite(layer:render(), 'over')
  end)
end

setmetatable(Decoder, {__call = function(_, ...) return _.new(...) end})

return Decoder
