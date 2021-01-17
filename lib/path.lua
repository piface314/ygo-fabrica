local path = setmetatable({}, {__index = require 'path'})

local program_root = os.getenv('YGOFAB_ROOT')

--- Joins strings into a path, relative to the **p**rogram **r**oot folder
--- @return string path
function path.prjoin(...)
  return path.join(program_root or '.', ...)
end

return path
