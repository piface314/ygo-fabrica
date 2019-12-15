local colors = require 'colors'

return function(v, code, ...)
  if not v then
    io.stderr:write(colors.FG_RED, colors.BOLD, "[ERROR] ", colors.RESET, ...)
    io.stderr:write("\n")
    os.exit(code or 1)
  end
end
