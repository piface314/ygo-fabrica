function table.merge(...)
  local nt = {}
  local function merge(dst, src)
    for k, v in pairs(src) do
      if type(v) == 'table' then
        dst[k] = type(dst[k]) == 'table' and dst[k] or {}
        merge(dst[k], v)
      else
        dst[k] = v
      end
    end
  end
  for _, t in ipairs({...}) do
    merge(nt, t)
  end
  return nt
end

function table.keys(t)
  local keys = {}
  for k in pairs(t) do
    keys[#keys + 1] = k
  end
  return keys
end

function table.sorted_keys(t)
  local keys = table.keys(t)
  table.sort(keys)
  return keys
end

function table.copy(t)
  if type(t) ~= 'table' then
    return t
  end
  local nt = {}
  for k, v in pairs(t) do
    nt[k] = table.copy(v)
  end
  return nt
end

function table.filter(t, f)
  local nt = {}
  for k, v in pairs(t) do
    if f(v, k) then
      nt[k] = v
    end
  end
  return nt
end
