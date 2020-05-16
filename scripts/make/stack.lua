

--- @class Stack
--- Represents a LIFO list, a stack data structure
local Stack = {}
Stack.__index = Stack

--- Creates an instance of a `Stack`
--- @return Stack stack
function Stack.new()
  return setmetatable({ n = 0 }, Stack)
end

--- Adds `item` to the top of the stack
--- @param item any
function Stack:push(item)
  if item ~= nil then
    self.n = self.n + 1
    self[self.n] = item
  end
end

--- Removes an item from the top of the stack and returns it
--- @return any item
function Stack:pop()
  if self.n == 0 then return nil end
  local item = self[self.n]
  self[self.n] = nil
  self.n = self.n - 1
  return item
end

--- Makes the stack empty
function Stack:clear()
  self.n = 0
end

--- Checks if `key` is in the stack
--- @param key any
--- @return boolean exists
function Stack:contains(key)
  for _, item in ipairs(self) do
    if item == key then
      return true
    end
  end
  return false
end

return Stack
