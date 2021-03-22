---Performs a shallow copy on a table, preserving metatables.
---@param t table table to be copied
---@return table
function table.copy(t)
  local copy = setmetatable({}, getmetatable(t))
  for k, v in pairs(t) do copy[k] = v end
  return copy
end

---Performs a deep copy on a table, preserving metatables.
---@param t table table to be copied
---@return table
function table.deepcopy(t)
  if type(t) ~= 'table' then return t end
  local copy = setmetatable({}, getmetatable(t))
  for k, v in pairs(t) do copy[k] = table.deepcopy(v) end
  return copy
end

---Merges table `src` into `dst`, creating new tables as necessary.
---@param dst table destination table
---@param src table source table
---@return table
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

---Merges any number of tables. Latest tables take precedence.
---Internal metatables are not preserved. The resulting table and any subtables
---are all new tables, so they can be mutated freely without interfering with their
---original counterparts.
---@vararg table
---@return table
function table.merge(...)
  local merged = {}
  for _, t in ipairs({...}) do
    merged = merge(merged, t)
  end
  return merged
end

local sort = table.sort
---Sorts list elements in a given order, in-place, from `list[1]` to `list[#list]`.
---@param list table
---@param comp fun(a: any, b: any): boolean
---@return table sorted
function table.sort(list, comp)
  sort(list, comp)
  return list
end