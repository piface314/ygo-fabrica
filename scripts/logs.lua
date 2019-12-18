local colors = require 'scripts.colors'

local Logs = {}

function Logs.assert(v, code, ...)
  if not v then
    io.stderr:write(colors.FG_RED, colors.BOLD, "[ERROR] ", colors.RESET, ...)
    io.stderr:write("\n")
    os.exit(code or 1)
  end
end

function Logs.ok(...)
  io.write(colors.FG_GREEN, colors.BOLD, "[OK] ", colors.RESET, ...)
  io.write("\n")
end

function Logs.info(...)
  io.write(...)
  io.write("\n")
end

function Logs.warning(...)
  io.write(colors.FG_YELLOW, colors.BOLD, "[!] ", colors.RESET, ...)
  io.write("\n")
end

return Logs
