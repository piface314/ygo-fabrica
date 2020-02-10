

local function merge(dst, src)
  for k, v in pairs(src) do
    if type(v) == 'table' then
      if type(dst[k]) ~= 'table' then
        dst[k] = {}
      end
      merge(dst[k], v)
    else
      dst[k] = v
    end
  end
end
table.merge = merge

function table.keys(t)
  local keys = {}
  for k in pairs(t) do
    keys[#keys + 1] = k
  end
  return keys
end
