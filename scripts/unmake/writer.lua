local i18n = require 'i18n'
local fun = require 'lib.fun'
local Logs = require 'lib.logs'

local Writer = {}

local key_order = {
  "id", "alias", "ot", "name",
  "setnumber", "setcode", "type", "category",
  "attribute", "race", "level", "rank",
  "link-rating", "link-arrows", "pendulum-scale",
  "atk", "def", "strings",
  "pendulum-effect", "effect", "flavor-text",
  "year", "author", "holo",
}

local function fmt_hex(v) return ("0x%x"):format(v) end
local function fmt_str(v) return ("%q"):format(v) end
local function fmt_bool(v) return tostring(v) end
local function fmt_dec(v) return type(v) == "number" and tostring(v) or fmt_str(v) end
local function fmt_long_str(v) return ("'''\n%s\n'''"):format(v) end
local function fmt_decs(v)
  if type(v) ~= "table" then return fmt_dec(v) end
  return "[" .. table.concat(fun.iter(v):map(fmt_dec):totable(), ", ") .. "]"
end
local function fmt_strs(v)
  if type(v) ~= "table" then return fmt_str(v) end
  return "[" .. table.concat(fun.iter(v):map(fmt_str):totable(), ", ") .. "]"
end
local format = {
  id = fmt_dec, alias = fmt_dec, ot = fmt_str, name = fmt_str,
  setnumber = fmt_str, setcode = fmt_hex, type = fmt_str, category = fmt_str,
  attribute = fmt_str, race = fmt_str, level = fmt_dec, rank = fmt_dec,
  ["link-rating"] = fmt_dec, ["link-arrows"] = fmt_str, ["pendulum-scale"] = fmt_decs,
  atk = fmt_dec, def = fmt_dec, strings = fmt_strs, ["pendulum-effect"] = fmt_long_str,
  effect = fmt_long_str, ["flavor-text"] = fmt_long_str,
  year = fmt_dec, author = fmt_str, holo = fmt_bool
}

local function sort_cards(cards)
  return table.sort(cards, function(a, b) return a.id < b.id end)
end

local function write_card(f, card)
  f:write("[[card]]\n")
  for _, k in ipairs(key_order) do
    if card[k] then
      f:write(k .. " = ")
      f:write(format[k](card[k]))
      f:write("\n")
    end
  end
  f:write("\n")
end

local function write_cards(f, cards)
  for _, card in ipairs(cards) do
    write_card(f, card)
  end
end

function Writer.write(tomlfp, cards)
  cards = sort_cards(cards)
  local f = io.open(tomlfp, 'w')
  Logs.assert(f, i18n('unmake.file_error', {tomlfp}))
  write_cards(f, cards)
  f:close()
end

return Writer