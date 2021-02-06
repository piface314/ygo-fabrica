local path = setmetatable({}, {__index = require 'path'})

path.program_root = os.getenv('YGOFAB_ROOT')
path.config_root = path.IS_WINDOWS
  and path.join(os.getenv('APPDATA'), 'YGOFabrica')
  or path.join(os.getenv('HOME'), '.config', 'ygofab')

--- Joins strings into a path, relative to the **p**rogram **r**oot folder
--- @return string path
function path.prjoin(...)
  return path.join(path.program_root or '.', ...)
end

--- Joins strings into a path, relative to **g**lobal **c**onfigurations folder.
--- @return string path
function path.gcjoin(...)
  return path.join(path.config_root, ...)
end

return path
