local Logs = require 'lib.logs'
local i18n = require 'i18n'

local Parser = {}

local concat = table.concat

local function apply_macro(macro, argv)
  local s = macro:gsub('($+)(%d+)', function(esc, i)
    local v = argv[tonumber(i)] or ''
    if esc:len() % 2 == 1 then return esc:sub(1, -2) .. v end
  end)
  for i in ipairs(argv) do argv[i] = nil end
  return s
end

local function parse(macros, str)
  local unresolved = {}
  local function parse(macros, str, cursor, up_sep)
    local cursor, len = cursor or 1, str:len()
    local function char() return str:sub(cursor, cursor) end
    local function step(n) cursor = cursor + (n or 1) end

    local out, esc = '', nil
    local argv, macro, sep = {}, nil, nil
    while cursor <= len and char() ~= up_sep do
      if macro then
        if char() == '}' then
          local m = macros[macro]
          if m then
            Logs.assert(not unresolved[macro], i18n('make.parser.cyclic_macro', {macro}))
            unresolved[macro] = true
            out = out .. parse(macros, apply_macro(m, argv))
            unresolved[macro] = nil
          else
            out = out .. ('${%s%s%s}'):format(macro, sep or '', concat(argv, sep))
          end
          macro = nil
        elseif char():match('[%w_-]') then
          macro = macro .. char()
        elseif char():match('[${]') then
          out = out .. '${' .. macro
          macro = nil
          step(-1)
        elseif not sep or char() == sep then
          sep = sep or char()
          step()
          argv[#argv + 1], cursor = parse(macros, str, cursor, sep)
          step(-1)
        end
      elseif esc then
        if char() == '{' then
          macro = ''
        else
          out = out .. (up_sep and '$' or '') .. char()
        end
        esc = false
      elseif char() == '$' then
        esc = true
      elseif up_sep and char() == '}' then
        break
      else
        out = out .. char()
      end
      step()
    end
    return out, cursor
  end
  local out = parse(macros, str)
  return out
end

local function scan(macros, group)
  for _, entry in pairs(group) do
    for fname, field in pairs(entry) do
      if type(field) == 'string' then
        entry[fname] = parse(macros, field)
      end
    end
  end
end

function Parser.parse(data, key)
  local macros, v = data.macro or {}, data[key] or {}
  scan(macros, v)
  return v
end

return Parser
