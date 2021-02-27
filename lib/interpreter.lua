--- Parses and runs commands, as given in `arg`, allowing flags
--- to be configured
--- @class Interpreter
--- @field commands table
local Interpreter = {}
Interpreter.__index = Interpreter

Interpreter.flag_prefixes = {'%-%-', '%-'}

local unpack = unpack or table.unpack

--- Creates a new instance of `Interpreter`
--- @return Interpreter interpreter
function Interpreter.new()
  return setmetatable({commands = {[''] = {}}}, Interpreter)
end

--- Sets a new list of prefixes that denote a flag
--- @param prefixes string[]
function Interpreter.set_flag_prefixes(prefixes)
  Interpreter.flag_prefixes = prefixes
end

--- Checks if `token` denotes a flag in `Interpreter.exec`
--- @param token string
--- @return boolean is_flag
function Interpreter.check_flag(token)
  for _, prefix in ipairs(Interpreter.flag_prefixes) do
    if token:match('^' .. prefix) then
      return true
    end
  end
  return false
end

--- Creates an empty command node in the command tree
--- @param command string
--- @return table node
function Interpreter:create_node(command)
  local node = self.commands['']
  for token in command:gmatch('%a[%w-]*') do
    if not node[token] then
      node[token] = {}
    end
    node = node[token]
  end
  node['@'] = {}
  return node
end

--- Configures a new `command`, assigning it `fn` as the function that
--- should be run. The following arguments must be an alternating list
--- of a string representing a flag, followed by a number defining how
--- many arguments that flag needs
--- @param command string
--- @param fn function
--- @vararg string|number
function Interpreter:add_command(command, fn, ...)
  local node = self:create_node(command)
  local flags, node_flags = {...}, {}
  local i = 1
  while flags[i] and flags[i + 1] do
    node_flags[flags[i]] = flags[i + 1]
    i = i + 1
  end
  node['@'].fn = fn
  node['@'].flags = node_flags
end

--- Executes a configured command, given a list of tokens
--- @vararg string
--- @return string|nil errmsg
function Interpreter:exec(...)
  local tokens, i = {...}, 1
  local cmd = ''
  local node = self.commands[cmd]
  local token = tokens[i]
  while token do
    cmd = cmd ~= '' and cmd .. ' ' .. token or token
    if node[token] then
      node = node[token]
    elseif node['@'] then
      break
    else
      return 'invalid_command', cmd
    end
    i = i + 1
    token = tokens[i]
  end
  local command = node['@']
  if not command then
    return 'invalid_command', cmd
  end
  local args, flags = {}, {}
  local current_flag, rem_f_args = nil, 0
  while token do
    if self.check_flag(token) then
      local flag_v = command.flags[token]
      if not flag_v then
        return 'invalid_flag', token
      end
      if rem_f_args > 0 then
        return 'missing_flag_args', current_flag
      end
      rem_f_args = flag_v
      current_flag = token
      flags[current_flag] = {}
    elseif current_flag then
      table.insert(flags[current_flag], token)
      rem_f_args = rem_f_args - 1
      if rem_f_args == 0 then
        current_flag = nil
      end
    else
      table.insert(args, token)
    end
    i = i + 1
    token = tokens[i]
  end
  if rem_f_args > 0 then
    return 'missing_flag_args', current_flag
  end
  command.fn(flags, unpack(args))
end

return Interpreter
