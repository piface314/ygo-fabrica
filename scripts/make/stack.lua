

local Stack = {}
Stack.__index = Stack

function Stack.new()
  return setmetatable({ n = 0 }, Stack)
end

function Stack:push(item)
  if item ~= nil then
    self.n = self.n + 1
    self[self.n] = item
  end
end

function Stack:pop()
  if self.n == 0 then return nil end
  local item = self[self.n]
  self[self.n] = nil
  self.n = self.n - 1
  return item
end

function Stack:clear()
  self.n = 0
end

function Stack:contains(key)
  for _, item in ipairs(self) do
    if item == key then
      return true
    end
  end
  return false
end

return Stack
