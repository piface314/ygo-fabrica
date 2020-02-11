local GameConst = require 'scripts.game-const'


local Codes = {}

local codes = {}

local function normalize(s)
  return s:gsub("[-_]", ""):lower()
end

local function normalize_keys(t)
  local normalized = {}
  for k, v in pairs(t) do
    normalized[normalize(k)] = v
  end
  return normalized
end

for k, t in pairs(GameConst.code) do
  codes[k] = normalize_keys(t)
end

function Codes.combine(group, keys)
  local c = 0
  local code_group = codes[group]
  for key in keys:gmatch("[%a-_]+") do
    key = normalize(key)
    c = bit.bor(c, (code_group[key] or 0))
  end
  return c
end

return Codes
