local Stack = require 'scripts.make.stack'
local Logs = require 'lib.logs'


local Parser = {}

local concat = table.concat

local function apply_macro(macro, argv)
	return (macro:gsub("($+)(%d+)", function(esc, i)
			local v = argv[tonumber(i)] or ""
			if esc:len() % 2 == 1 then
				return esc:sub(1, -2) .. v
			end
		end))
end

local function parse(macros, str)
  local stack = Stack.new()
  local function parse(macros, str, cursor, up_sep)
    local cursor, len = cursor or 1, str:len()

    local function char(i)
  		i = i or 0
  		return str:sub(cursor + i, cursor + i)
  	end

    local function step(n) cursor = cursor + (n or 1) end

    local function in_bounds()
  		if up_sep then
  			return cursor <= len and char() ~= up_sep
  		else
  			return cursor <= len
  		end
  	end

    local out, esc = ""
    local argi, argv, macro, sep = 0, {}
    while in_bounds() do
      if macro then
  			if char() == "}" then
  				local m = macros[macro]
  				if m then
  					Logs.assert(not stack:contains(macro), 1, macro, ": cyclic macro")
  					stack:push(macro)
  					out = out .. parse(macros, apply_macro(m, argv))
  					stack:pop()
  				else
  					out = out .. ("${%s%s%s}"):format(macro, sep or "", concat(argv, sep))
  				end
          macro = nil
        elseif char():match("[%w_-]") then
          macro = macro .. char()
        elseif char():match("[${]") then
          out = out .. "${" .. macro
  				macro = nil
  				step(-1)
        elseif not sep or char() == sep then
          argi = argi + 1
  				sep = sep or char()
  				step()
  				argv[argi], cursor = parse(macros, str, cursor, sep)
  				step(-1)
  			end
  		elseif esc then
  			if char() == "{" then
  				macro = ""
  			else
  				out = out .. (up_sep and "$" or "") .. char()
  			end
  			esc = false
      elseif char() == "$" then
        esc = true
      elseif up_sep and char() == "}" then
  			break
  		else
        out = out .. char()
      end
      step()
    end
    return out, cursor
  end
  local out = parse(macros, str)
  stack:clear()
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

function Parser.parse(data)
  local macros, cards, sets = data.macro or {}, data.card or {}, data.set or {}
  scan(macros, sets)
  scan(macros, cards)
  return sets, cards
end

return Parser
