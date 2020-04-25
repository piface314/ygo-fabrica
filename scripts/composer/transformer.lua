

local Transformer = {}
Transformer.__index = Transformer

function Transformer.new()
  return setmetatable({
    values = {}
  }, Transformer)
end

function Transformer.pendulum_size(pendulum_effect)
  return pendulum_effect and #pendulum_effect > 176 and "m" or "s"
end

function Transformer:add_value(id, t)
  self.values[id] = t
end

function Transformer:transform(metalayers)
  for id, t in pairs(self.values) do
    for _, metalayer in ipairs(metalayers) do
      local transformation = metalayer:get_transformation(id)
      if transformation then
        if type(transformation) == 'function' then
          transformation(metalayer, t)
        else
          metalayer:add_value(t)
        end
      end
    end
  end
end

return Transformer
