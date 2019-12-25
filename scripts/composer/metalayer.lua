

-- local MetaLayer = {}

local function constructor(shape, ...)
  return { shape = shape, values = { ... } }
end
-- setmetatable(MetaLayer, { __call = constructor })

return constructor
