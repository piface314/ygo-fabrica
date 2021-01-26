local colors = require 'lib.colors'
local i18n = require 'lib.i18n'

local Logs = {}

local err_cb = {}

-- TODO: provide a function that fits strings into a tabular form,
-- wrapping long strings and keeping columns organized.

--- Registers a callback `cb` to be run after an error occurs
--- @param cb function
function Logs.add_post_error_cb(cb)
  table.insert(err_cb, cb)
end

--- Checks if `v` is a true value. If it's not, calls Logs.error
--- @param v any
function Logs.assert(v, ...)
  if not v then
    Logs.error(...)
  end
end

--- Displays an error message and exits the program with error code 1
function Logs.error(...)
  io.stderr:write(colors.FG_RED, colors.BOLD, '[', i18n 'logs.err', '] ', colors.RESET, ...)
  io.stderr:write('\n')
  for _, cb in ipairs(err_cb) do cb() end
  os.exit(1)
end

--- Shows a success message and writes any number of strings to the standard output,
--- adding a newline at the end.
function Logs.ok(...)
  io.write(colors.FG_GREEN, colors.BOLD, '[', i18n 'logs.ok', '] ', colors.RESET, ...)
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
  io.write(colors.FG_YELLOW, colors.BOLD, '[!] ', colors.RESET, ...)
  io.write('\n')
end

--- Returns a string formatted like an error
function Logs.error_s(...)
  local s = {colors.FG_RED, colors.BOLD, '[', i18n 'logs.err', '] ', colors.RESET, ...}
  return table.concat(s)
end

--- Returns a string formatted like a warning
function Logs.warning_s(...)
  local s = {colors.FG_YELLOW, colors.BOLD, '[!] ', colors.RESET, ...}
  return table.concat(s)
end

--- Returns a string formatted like a success message
function Logs.ok_s(...)
  local s = {colors.FG_GREEN, colors.BOLD, '[', i18n 'logs.ok', '] ', colors.RESET, ...}
  return table.concat(s)
end

local BAR_WIDTH = 32
local round = math.ceil
local CHAR, SPACE = '#', ' '
local FMT_WD = #(colors.FG_GREEN .. colors.BOLD .. colors.RESET)
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
    local qt_fill = round(rate * BAR_WIDTH)
    local fill, miss = CHAR:rep(qt_fill), SPACE:rep(BAR_WIDTH - qt_fill)
    local s = bar_string:format(rate * 100, colors.FG_GREEN .. colors.BOLD,
                                fill, miss, colors.RESET, progress, n,
                                label or '')
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

return Logs
