--- Adds functional style support to tables
--- @class Fun
local Fun = {}
function Fun:__index(key)
  local m = Fun[key]
  return m or self(key)
end

--- Shortcut to rawget(self, key)
--- @param key any
--- @return any
function Fun:__call(key)
  return rawget(self, key)
end

--- Binds a table to a Fun object
--- @param t table
--- @return Fun
local function bind(t) return setmetatable(t, Fun) end

--- Returns an empty Fun
--- @return Fun
local function new() return bind({}) end

--- Runs an iterator function until it returns `nil`, saving its return values.
--- Acts like a `for` construction.
--- @param iter function
--- @param o any
--- @param v any
--- @return Fun
local function gen(iter, o, v)
  local out = new()
  while true do
    local vals = {iter(o, v)}
    if vals[1] == nil then break end
    v = vals[1]
    out:push(#vals > 1 and vals or vals[1])
  end
  return out
end

--- Creates a list out of a numeric for range.
---@param st number
---@param en number
---@param step? number
---@return Fun
local function range(st, en, step)
  assert(type(en) == 'number', 'fun: range end must be a number')
  if not step or type(step) ~= 'number' then step = 1 end
  local out = new()
  for i = st, en, step do
    out[#out + 1] = i
  end
  return out
end

local FS_TEMPLATE = [[
local __UP = {...}
return function(%s) return %s end]]
--- Parses a string into a one line function returning the given expression.
--- Upvalues can be passed as additional parameters, and are referenced in
--- the string with `$`. Like: `$1` means the first upvalue.
--- If the generated function contains an error, that error will be thrown.
--- @param s string
--- @return function
local function strfn(s, ...)
  local params, ret = s:match('^%s*%(?(.-)%)?%s*%->%s*(.+)$')
  assert(params, 'fun: malformed function')
  local exp = ret:gsub('$(%d+)', function(i) return '(__UP['..i..'])' end)
  local fs = FS_TEMPLATE:format(params, exp)
  local f, err = load(fs)
  assert(f, 'fun: ' .. (err or ''))
  return f(...)
end

--- Returns a shallow copy of the table
--- @return Fun
function Fun:copy()
  local out = new()
  for i, v in pairs(self) do out[i] = v end
  return out
end

--- Returns a deep copy of the table. Internal metatables are preserved.
--- @return Fun
function Fun:deepcopy()
  local function copy(t)
    if type(t) ~= 'table' then
      return t
    end
    local nt = setmetatable({}, getmetatable(t))
    for k, v in pairs(t) do
      nt[k] = copy(v)
    end
    return nt
  end
  return copy(self)
end

--- Maps each value in the table with function `f` into a new table.
--- `f` receives each value as the first argument, and each index as the second.
--- @param f fun(val: any, key: any): any
--- @return Fun
function Fun:map(f)
  local out = new()
  for k, v in pairs(self) do
    out[k] = f(v, k)
  end
  return out
end

--- Filters and table into a new one containing only values that make `f` return `true`.
--- `f` receives each value as the first argument, and each index as the second.
--- If parameter `as_array` is provided, the table will be treated as an array if `true`,
--- or treated as a hash if `false`. If not provided, the table will be inferred as an
--- array if it contains an element at index `1`.
--- @param f fun(val: any, key: any): boolean
--- @param as_array boolean
--- @return Fun
function Fun:filter(f, as_array)
  local out = new()
  if as_array == nil then as_array = self[1] ~= nil end
  for k, v in pairs(self) do
    if f(v, k) then
      out[as_array and #out + 1 or k] = v
    end
  end
  return out
end

--- Reduces an table to a single value, according to a starting value `st`, and to a function `f`,
--- that receives an accumulator value and the first parameter and the current value as the second
--- @generic A
--- @param st A
--- @param f fun(acc: A, val: any): A
--- @return A
function Fun:reduce(st, f)
  for _, v in pairs(self) do
    st = f(st, v)
  end
  return st
end

--- Executes function `fn` on each element of the table
--- @param fn fun(val: any, key: any)
function Fun:foreach(fn)
  for k, v in pairs(self) do
    fn(v, k)
  end
end

--- Inserts element `v` at the end of the table/array.
--- Note that this operation mutates the table and returns itself.
--- @param v any
--- @return Fun
function Fun:push(v)
  self[#self+1] = v
  return self
end

--- Merges current table with any number of tables.
--- Latest tables take precedence. Internal metatables are not preserved
--- @vararg table
--- @return Fun
function Fun.merge(...)
  local function merge(dst, src)
    for k, v in pairs(src) do
      if type(v) == 'table' then
        dst[k] = type(dst[k]) == 'table' and dst[k] or {}
        merge(dst[k], v)
      else
        dst[k] = v
      end
    end
    return dst
  end
  return bind(bind {...}:reduce({}, merge))
end

--- Sorts the table/array.
--- @param comp function
--- @return Fun
function Fun:sort(comp)
  local a = self:copy()
  table.sort(a, comp)
  return a
end

--- Returns an array with the table keys.
--- @return Fun
function Fun:keys()
  local keys = new()
  for k in pairs(self) do
    keys[#keys + 1] = k
  end
  return keys
end

--- Returns an array with the table values.
--- @return Fun
function Fun:vals()
  local vals = new()
  for _, v in pairs(self) do
    vals[#vals + 1] = v
  end
  return vals
end

--- Maps each value in the table with function `f` into a new hash.
--- `f` receives each value as the first argument, and each key as the second.
--- The first value returned by `f` is used as the key, and the second and the value
--- @param f fun(val: any, key: any): any, any
--- @return Fun
function Fun:hashmap(f)
  local hash = new()
  for k, v in pairs(self) do
    local nk, nv = f(v, k)
    if nk ~= nil then
      hash[nk] = nv
    end
  end
  return hash
end

--- Returns a string representation of the table as an array
--- @return string
function Fun:array_tostring()
  local function str(v)
    return type(v) == 'string' and '"' .. v .. '"' or tostring(v)
  end
  return '[' .. table.concat(self:map(str), ', ') .. ']'
end

--- Returns a string representation of the table as a hash
--- @return string
function Fun:hash_tostring()
  local function str(v, k)
    return k .. ' = ' .. (type(v) == 'string' and '"' .. v .. '"' or tostring(v))
  end
  local s = self:map(str):reduce('', strfn 'a,b -> a..", "..b'):sub(3)
  return '{' .. s .. '}'
end

--- Returns a string representation of the table, inferring if it's an array or hash
--- @return string
function Fun:__tostring()
  return self[1] == nil and self:hash_tostring() or self:array_tostring()
end

--- Concatenates two arrays into a new one (Values can be either plain tables or `Fun` objects).
--- Only works on arrays.
--- @param a Fun|table
--- @param b Fun|table
--- @return Fun
function Fun.__concat(a, b)
  local a_t, b_t = type(a), type(b)
  assert(a_t == 'table' and a_t == b_t,
         'fun: attempt to concat a `Fun` value with a non-table value')
  local t = {}
  for _, v in ipairs(a) do t[#t + 1] = v end
  for _, v in ipairs(b) do t[#t + 1] = v end
  return bind(t)
end

local constructors = {
  ['string'] = strfn,
  ['function'] = gen,
  ['table'] = bind,
  ['number'] = range
}

--- If `v` is a string, parses that string into a function defined by that string.
--- If `v` is a table, makes `v` an instance of `Fun`.
--- If `v` is a function, that function is treated as a generator for values that are placed in an array.
--- If `v` is a number, uses that number and its following argument to form a range of numbers.
--- @param v string|table
--- @return Fun
return function(v, ...)
  local t = type(v)
  local cons = constructors[t]
  assert(cons, ('fun: bad argument #1 (expected string|table|function|number, got %s)'):format(t))
  return cons(v, ...)
end