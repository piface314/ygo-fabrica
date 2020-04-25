

local Interpreter = {}
Interpreter.__index = Interpreter

local insert = table.insert
local unpack = unpack or table.unpack

function Interpreter.new()
  return setmetatable({
    argtree = {},
    commands = {}
  }, Interpreter)
end

local function create_command(self, command, fn)
  local at, ct = self.argtree, self.commands
  local ckeys, i = {}, 0
  for c in command:gmatch("%a[%w-]*") do
    i = i + 1
    ckeys[i] = c
  end
  for k, c in ipairs(ckeys) do
    if not at[c] then at[c] = {} end
    at = at[c]
    if k < i then
      if not ct[c] then ct[c] = {} end
      ct = ct[c]
    else
      ct[c] = fn
    end
  end
  if i == 0 then self.commands = fn end
  at._command = true
  return at
end

function Interpreter:add_command(command, fn, ...)
  local at = create_command(self, command, fn)
  local flags = { ... }
  local i = 1
  while flags[i] and flags[i + 1] do
    at[flags[i]] = flags[i + 1]
    i = i + 2
  end
end

function Interpreter:add_fallback(subcommand, fn)
  local ct = self.commands
  for c in subcommand:gmatch("%a[%w-]*") do
    if type(ct) ~= 'table' or not ct[c] then return end
    ct = ct[c]
  end
  setmetatable(ct, { __index = function() return fn end })
end

function Interpreter:parse(...)
  local command, args, flags = {}, {}, {}
  local current_flag, params_to_read = nil, 0
  local t = self.argtree
  for _, arg in ipairs({ ... }) do
    local sub = t[arg]
    local is_flag = arg:match("^%-+")
    if is_flag then
      if not sub then
        return ("invalid flag %q"):format(arg)
      elseif params_to_read > 0 then
        return ("not enough args for %q flag"):format(current_flag)
      end
      current_flag = arg
      params_to_read = sub
      flags[current_flag] = {}
    elseif params_to_read > 0 then
      insert(flags[current_flag], arg)
      params_to_read = params_to_read - 1
    elseif sub then
      t = sub
      insert(command, arg)
    elseif not t._command then
      return ("invalid command %q"):format(arg)
    else
      insert(args, arg)
    end
  end
  if params_to_read > 0 then
    return ("not enough args for %q flag"):format(current_flag)
  end
  return nil, command, args, flags
end

function Interpreter:exec(command, args, flags)
  local ct, i = self.commands, 0
  while type(ct) ~= 'function' do
    i = i + 1
    ct = ct[command[i]]
  end
  return ct(flags, unpack(args))
end

return Interpreter
