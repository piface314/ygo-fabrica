local Logs = require 'lib.logs'
local i18n = require 'i18n'
local fun = require 'lib.fun'

local Parser = {}

local function resolve(macro, argv)
  local s = macro:gsub('($+)(%d+)', function(esc, i)
    local v = argv[tonumber(i)] or ''
    if esc:len() % 2 == 1 then return esc:sub(1, -2) .. v end
  end)
  for i in ipairs(argv) do argv[i] = nil end
  return s
end

local function parse(macros, str)
  local unresolved = {}
  local function parse(str, cursor, up_sep)
    local function char() return str:sub(cursor, cursor) end
    local function step(n) cursor = cursor + (n or 1) end
    local out, esc, len = '', nil, str:len()
    local argv, macro, sep = {}, nil, nil
    cursor = cursor or 1
    while cursor <= len and char() ~= up_sep do
      if macro then
        if char() == '}' then
          local m = macros[macro]
          if m then
            Logs.assert(not unresolved[macro], i18n('make.parser.cyclic_macro', {macro}))
            unresolved[macro] = true
            out = out .. parse(resolve(m, argv))
            unresolved[macro] = nil
          else
            out = out .. ('${%s%s%s}'):format(macro, sep or '', table.concat(argv, sep))
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
          argv[#argv + 1], cursor = parse(str, cursor, sep)
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
  return parse(str)
end

local function scan(macros, v)
  local t = type(v)
  if t == 'table' then
    return fun.iter(next, v):map(function(k, v) return k, scan(macros, v) end):tomap()
  elseif t == 'string' then
    return parse(macros, v)
  else
    return v
  end
end

function Parser.parse(data, key)
  local macros, v = data.macro or {}, data[key] or {}
  return scan(macros, v)
end

return Parser
