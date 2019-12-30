

local MetaLayer = {}

local function constructor(shape, ...)
  return setmetatable({
    shape = shape,
    values = { ... }
  }, MetaLayer)
end
setmetatable(MetaLayer, { __call = constructor })

function MetaLayer:__tostring()
  local s = {}
  for _, v in ipairs(self.values) do table.insert(s, tostring(v)) end
  return ("@%s(%s)"):format(self.shape, table.concat(s, ", "))
end

return constructor
