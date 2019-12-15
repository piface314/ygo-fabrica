

local ArgParser = {}
ArgParser.__index = ArgParser

local insert = table.insert

local function constructor()
  return setmetatable({
    argtree = {}
  }, ArgParser)
end
setmetatable(ArgParser, { __call = constructor })

local function create_command(self, command)
  local t = self.argtree
  for c in command:gmatch("%a[%w-]*") do
    if not t[c] then
      t[c] = {}
    end
    t = t[c]
  end
  t._command = true
  return t
end

function ArgParser:add_command(command, ...)
  local t = create_command(self, command)
  local flags = { ... }
  local i = 1
  while flags[i] and flags[i + 1] do
    t[flags[i]] = flags[i + 1]
    i = i + 2
  end
end

function ArgParser:parse(...)
  local command, i = {}, 0
  local current_flag, params_to_read = nil, 0
  local t = self.argtree
  for _, arg in ipairs({ ... }) do
    local sub = t[arg]
    local is_flag = arg:match("^%-+")
    if is_flag then
      if not sub then
        return nil, ("invalid flag %q"):format(arg)
      elseif params_to_read > 0 then
        return nil, ("not enough args for %q flag"):format(current_flag)
      end
      current_flag = arg
      params_to_read = sub
      command[i][current_flag] = {}
    elseif params_to_read > 0 then
      insert(command[i][current_flag], arg)
      params_to_read = params_to_read - 1
    elseif sub then
      t = sub
      i = i + 1
      command[i] = t._command and { _name = arg, _args = {} } or arg
    elseif not command[i] or not t._command then
      return nil, ("invalid arg %q"):format(arg)
    else
      insert(command[i]._args, arg)
    end
  end
  if params_to_read > 0 then
    return nil, ("not enough args for %q flag"):format(current_flag)
  end
  return command
end

return ArgParser
