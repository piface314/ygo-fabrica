--- A `Shape` transforms data into a vips Image
--- @class Shape
--- @field label string
--- @field fn fun(...): Image
local Shape = {}

--- Creates a new `Shape` defined by `fn`.
--- `label` is just a string for debugging purposes.
--- @param label string
--- @param fn fun(...): Image
--- @return Shape
function Shape.new(label, fn)
  return setmetatable({label = label, fn = fn}, Shape)
end

--- Returns a string representation of a `Shape`
--- @return string
function Shape:__tostring() return '$:' .. self.label end

--- Shortcut to shape.fn(...)
--- @return Image
function Shape:__call(...) return self.fn(...) end

setmetatable(Shape, {__call = function(_, ...) return _.new(...) end})

return Shape