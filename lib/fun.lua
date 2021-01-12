--- Adds functional style support for tables that represent lists/arrays
--- @class Fun
local Fun = {}
Fun.__index = Fun

--- Returns an empty Fun
--- @return Fun
local function new()
  return setmetatable({}, Fun)
end

--- Binds a table to a Fun object
--- @param t table
--- @return Fun
local function bind(t)
  return setmetatable(t, Fun)
end

--- Returns the array itself, without the metatable
--- @return table
function Fun:get()
  return setmetatable(self, nil)
end

--- Parses a string into a function. If the generated function contains an error, that
--- error will be thrown.
--- @param s string
--- @return function
local function strfn(s)
  local params, ret = s:match('%s*%(?(.-)%)?%s*%->%s*(.+)')
  local fs = ('return function(%s) return %s end'):format(params, ret)
  local f, err = load(fs)
  assert(f, err)
  return f()
end

--- Maps each value in the array with function `f` into a new array.
--- `f` receives each value as the first argument, and each index as the second.
--- @param f function
--- @return Fun
function Fun:map(f)
  local out = new()
  for i, v in ipairs(self) do
    out[i] = f(v, i)
  end
  return out
end

--- Filters and array into a new one containing only values that make `f` return `true`.
--- `f` receives each value as the first argument, and each index as the second.
--- @param f function
--- @return Fun
function Fun:filter(f)
  local out = new()
  for i, v in ipairs(self) do
    if f(v, i) then
      out[#out + 1] = v
    end
  end
  return out
end

--- Reduces an array to a single value, according to a starting value `st`, and to a function `f`,
--- that receives an accumulator value and the first parameter and the current value as the second.
--- @param st any
--- @param f function
--- @return any
function Fun:reduce(st, f)
  local out = st
  for _, v in ipairs(self) do
    out = f(out, v)
  end
  return out
end

--- Executes function `fn` on each element of the array
--- @param fn function
function Fun:foreach(fn)
  for i, v in ipairs(self) do
    fn(v, i)
  end
end

--- Inserts element `v` at the end of the array
--- @param v any
function Fun:push(v)
  table.insert(self, v)
end

--- Returns a string representation of the array
--- @return string
function Fun:__tostring()
  local function str(v)
    return type(v) == 'string' and '"' .. v .. '"' or tostring(v)
  end
  return '[' .. table.concat(self:map(str), ', ') .. ']'
end

--- Concatenates two arrays into a new one (Values can be either plain tables or `Fun` objects)
--- @param a Fun|table
--- @param b Fun|table
--- @return Fun
function Fun.__concat(a, b)
  local a_t, b_t = type(a), type(b)
  assert(a_t == 'table' and a_t == b_t,
         'attempt to concat a `Fun` value with a non-table value')
  local t = {}
  for _, v in ipairs(a) do t[#t + 1] = v end
  for _, v in ipairs(b) do t[#t + 1] = v end
  return bind(t)
end

--- If `p` is a string, parses that string into a function defined by that string.
--- If `p` is a table, makes `p` an instance of `Fun`
---@param p string|table
---@return Fun
return function(p)
  if type(p) == 'string' then
    return strfn(p)
  else
    return bind(p)
  end
end
