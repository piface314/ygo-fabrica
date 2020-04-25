

local MetaLayer = {}
MetaLayer.__index = MetaLayer

function MetaLayer.new(shape, ...)
  return setmetatable({
    shape = shape,
    values = { ... },
    transformations = {}
  }, MetaLayer)
end

function MetaLayer:__tostring()
  local s = {}
  for _, v in ipairs(self.values) do table.insert(s, tostring(v)) end
  return ("@%s(%s)"):format(self.shape, table.concat(s, ", "))
end

function MetaLayer:add_value(val)
  table.insert(self.values, val)
end

function MetaLayer:set_value(i, val)
  self.values[i] = val
end

function MetaLayer:get_value(i)
  return self.values[i]
end

function MetaLayer:add_transformation(id, fn)
  self.transformations[id] = fn or true
end

function MetaLayer:get_transformation(id)
  return self.transformations[id]
end

return MetaLayer
