local cl = require 'lib.colors'
local i18n = require 'i18n'
local utf8 = require 'utf8'

local Logs = {}

local err_cb = {}

--- Registers a callback `cb` to be run after an error occurs
--- @param cb function
function Logs.add_post_error_cb(cb)
  table.insert(err_cb, cb)
end

--- Checks if `v` is a true value. If it is, returns `v`, otherwise calls Logs.error
--- @param v any
--- @return any v
function Logs.assert(v, ...)
  if not v then Logs.error(...) end
  return v
end

--- Displays an error message and exits the program with error code 1
function Logs.error(...)
  io.stderr:write(cl.FG_RED, cl.BOLD, '[', i18n 'logs.err', '] ', cl.RESET, ...)
  io.stderr:write('\n')
  for _, cb in ipairs(err_cb) do cb() end
  os.exit(1)
end

--- Shows a success message and writes any number of strings to the standard output,
--- adding a newline at the end.
function Logs.ok(...)
  io.write(cl.FG_GREEN, cl.BOLD, '[', i18n 'logs.ok', '] ', cl.RESET, ...)
  io.write('\n')
end

--- Writes any number of strings to the standard output, adding a newline at the end.
function Logs.info(...)
  io.write(...)
  io.write('\n')
end

--- Shows a warning message and writes any number of strings to the standard output,
--- adding a newline at the end.
function Logs.warning(...)
  io.write(cl.FG_YELLOW, cl.BOLD, '[!] ', cl.RESET, ...)
  io.write('\n')
end

--- Returns a string formatted like an error
function Logs.error_s(...)
  local s = {cl.FG_RED, cl.BOLD, '[', i18n 'logs.err', '] ', cl.RESET, ...}
  return table.concat(s)
end

--- Returns a string formatted like a warning
function Logs.warning_s(...)
  local s = {cl.FG_YELLOW, cl.BOLD, '[!] ', cl.RESET, ...}
  return table.concat(s)
end

--- Returns a string formatted like a success message
function Logs.ok_s(...)
  local s = {cl.FG_GREEN, cl.BOLD, '[', i18n 'logs.ok', '] ', cl.RESET, ...}
  return table.concat(s)
end

local BAR_WIDTH = 32
local CHAR, SPACE = '#', ' '
local FMT_WD = #(cl.FG_GREEN .. cl.BOLD .. cl.RESET)
--- Creates a progress bar with `n` steps. This bar can be printed and updated.
--- @param n number
--- @return table bar
function Logs.bar(n)
  local bar = {}
  local progress = 0
  local bar_string = '\r%5.1f%% [%s%s%s%s] %' .. #tostring(n) .. 'd/%d %s'
  local prev_s = 0
  n = math.max(0, n)
  function bar:print(label, prelabel)
    local rate = math.min(progress / n, 1)
    local qt_fill = math.ceil(rate * BAR_WIDTH)
    local fill, miss = CHAR:rep(qt_fill), SPACE:rep(BAR_WIDTH - qt_fill)
    local s = bar_string:format(rate * 100, cl.FG_GREEN .. cl.BOLD, fill, miss,
      cl.RESET, progress, n, label or '')
    prelabel = prelabel and prelabel .. '\n' or ''
    io.write('\r', SPACE:rep(prev_s), '\r', prelabel, s)
    io.flush()
    prev_s = #s - FMT_WD
  end
  function bar:update(label, prelabel, i)
    progress = math.min(progress + (i or 1), n)
    self:print(label, prelabel)
  end
  function bar:finish(label, prelabel)
    self:print(label, prelabel)
    print()
  end
  return bar
end

local function is_break(c, br) return br and utf8.match(c, '[-,/]') end
local function is_space(c) return utf8.match(c, '[　 ]') end
local function trim(s) return utf8.match(s, '^[ 　]*(.*)$') end
local function fits(l, bf, w) return (l and utf8.len(l[#l]) or 0) + utf8.len(bf) < w end

--- Wraps `text` in a maximum of `width` characters, returning a table with
--- each line, without trailing `\n` characters.
--- @param width number
--- @param text string
--- @param br boolean if `true`, some special characters will break words
--- @return string[]
function Logs.wrap(width, text, br)
  local lines, buffer = {''}, ''
  local function newline() lines[#lines + 1] = '' end
  local function commit(v, b) lines[#lines], buffer = lines[#lines] .. v, b end
  for _, c in utf8.next, text do
    c = utf8.char(c)
    if c == '\n' then
      commit(buffer, ''); newline()
    elseif fits(lines, buffer, width) then
      if is_break(c, br) then commit(buffer .. c, '')
      elseif is_space(c) then commit(buffer, c)
      else                    commit('', buffer .. c) end
    elseif fits(nil, buffer, width) then
      newline()
      if is_break(c, br) then commit(trim(buffer) .. c, '')
      elseif is_space(c) then commit(trim(buffer), c)
      else                    commit('', trim(buffer) .. c) end
    else
      commit(buffer, c)
      newline()
    end
  end
  commit(buffer)
  return lines
end

--- Turns a matrix of strings into tabular format, using `limit` as the maximum
--- width of each column. The returned value can be directly printed by doing:
--- ```lua
--- io.write(unpack(Logs.tabular(limit, text)))
--- ```
--- If a column limit is set to `0`, that column will have flexible width.
--- @param limit number[]
--- @param text string[][]
--- @param opts table
--- @return string[]
function Logs.tabular(limit, text, opts)
  local width, s, opts = {}, {}, opts or {}
  for j, w in ipairs(limit) do
    if w <= 0 then
      for _, row in ipairs(text) do
        w = math.max(w, #tostring(row[j]))
      end
    end
    width[j] = w
  end
  for _, row in ipairs(text) do
    local row_lines, height = {}, 0
    for j, cell in ipairs(row) do
      row_lines[j] = Logs.wrap(width[j], tostring(cell), opts.breaks)
      height = math.max(height, #row_lines[j])
    end
    for i = 1, height do
      for j, lines in ipairs(row_lines) do
        local l = lines[i] or ''
        s[#s + 1] = l
        s[#s + 1] = (' '):rep(width[j] - utf8.len(l) + 1)
      end
      s[#s + 1] = '\n'
    end
    if opts.in_newline then s[#s + 1] = '\n' end
  end
  if opts.in_newline then s[#s] = nil end
  s[#s] = nil
  return s
end

return Logs
