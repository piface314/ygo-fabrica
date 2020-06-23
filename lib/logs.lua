local colors = require 'lib.colors'

local Logs = {}

--- Checks if `v` is a true value. If it's not, displays an error message and
--- exits the program with an error `code`.
--- @param v any
--- @param code number
function Logs.assert(v, code, ...)
  if not v then
    io.stderr:write(colors.FG_RED, colors.BOLD, "[ERROR] ", colors.RESET, ...)
    io.stderr:write("\n")
    os.exit(code or 1)
  end
end

--- Shows a success message and writes any number of strings to the standard output,
--- adding a newline at the end.
function Logs.ok(...)
  io.write(colors.FG_GREEN, colors.BOLD, "[OK] ", colors.RESET, ...)
  io.write("\n")
end

--- Writes any number of strings to the standard output, adding a newline at the end.
function Logs.info(...)
  io.write(...)
  io.write("\n")
end

--- Shows a warning message and writes any number of strings to the standard output,
--- adding a newline at the end.
function Logs.warning(...)
  io.write(colors.FG_YELLOW, colors.BOLD, "[!] ", colors.RESET, ...)
  io.write("\n")
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
  local bar_string = "\r%5.1f%% [%s%s%s%s] %" .. #tostring(n) .. "d/%d %s"
  local prev_s = 0
  function bar:print(label)
    local rate = progress / n
    local qt_fill = round(rate * BAR_WIDTH)
    local fill, miss = CHAR:rep(qt_fill), SPACE:rep(BAR_WIDTH - qt_fill)
    local s = bar_string:format(rate * 100, colors.FG_GREEN .. colors.BOLD, fill, miss,
      colors.RESET, progress, n, label or "")
    io.write("\r", SPACE:rep(prev_s))
    io.write(s)
    io.flush()
    prev_s = #s - FMT_WD
  end
  function bar:update(label, i)
    progress = progress + (i or 1)
    if progress > n then progress = n end
    self:print(label)
  end
  function bar:finish(label)
    self:print(label)
    print()
  end
  return bar
end

return Logs
