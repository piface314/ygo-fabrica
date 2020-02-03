

local Stack = {}
Stack.__index = Stack

function Stack.new()
  local inst = { items = {}, n = 0 }
  setmetatable(inst, Stack)
  return inst
end

function Stack:push(item)
  if item ~= nil then
    self.n = self.n + 1
    self.items[self.n] = item
  end
end

function Stack:pop()
  if self.n == 0 then return nil end
  local item = self.items[self.n]
  self.items[self.n] = nil
  self.n = self.n - 1
  return item
end

function Stack:clear()
  self.n = 0
  self.items = {}
end

function Stack:contains(key)
  for _, item in ipairs(self.items) do
    if item == key then
      return true
    end
  end
  return false
end

return Stack
