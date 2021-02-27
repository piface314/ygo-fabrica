local fun = require 'lib.fun'

--- A `Layer` serves to temporarily hold a `Shape` and some values
--- so that it can later be turned into a proper vips Image.
--- @class Layer
--- @field shape Shape
--- @field values Fun
local Layer = {}
Layer.__index = Layer

--- Creates a new `Layer`
--- @param shape function
--- @return Layer
function Layer.new(shape, ...)
  return setmetatable({shape = shape, values = {...}}, Layer)
end

--- Returns a string representation of a `Layer`
function Layer:__tostring()
  local s = table.concat(fun.iter(self.values):map(tostring):totable(), ',')
  return ('%s(%s)'):format(self.shape, s)
end

--- Renders the `Layer` into a vips Image
--- @return Image
function Layer:render()
  return self.shape(unpack(self.values))
end

--- Checks if the given value is a Layer
--- @param v any
--- @return boolean
function Layer.is_layer(v)
  return type(v) == 'table' and getmetatable(v) == Layer
end

setmetatable(Layer, {__call = function(_, ...) return _.new(...) end})

return Layer
