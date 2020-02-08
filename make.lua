local Logs = require 'lib.logs'
local dependencies = require 'dependencies'


local IS_WIN = package.config:sub(1,1) == "\\"

local build = {}
build.base = "./build"
build.tree = build.base .. "/lua-modules"

local err = nil

function build.folder(folder)
  if os.execute(("mkdir %s"):format(folder)) ~= 0 then
    err = "Failed to create folder " .. folder
    return false
  else
    return true
  end
end

function build.dependencies()
  for _, dep in ipairs(dependencies) do
    local err = os.execute(("luarocks install %s --tree=%s"):format(dep, build.tree))
    if err ~= 0 then
      err = "Failed to install dependency " .. dep
      return false
    end
  end
  return true
end

function build.path_req()
  local f, errmsg = io.open(build.tree .. "/set-paths.lua", "w")
  if not f then
    err = errmsg
    return false
  end
  f:write([[
local version = _VERSION:match("%d+%.%d+")
package.path = ("lua-modules/share/lua/%s/?.lua;lua-modules/share/lua/%s/?/init.lua;%s")
  :format(version, version, package.path)
package.cpath = ("lua-modules/lib/lua/%s/?.so;%s"):format(version, package.cpath)]])
  f:close()
  return true
end

function build.start()
  Logs.assert(build.folder(build.base) and build.folder(build.tree) and
    build.dependencies() and build.path_req(), 1, err)
end

local install = {}
install.base = IS_WIN and "C:/Program Files/YGOFabrica" or "/usr/local/ygofab"
install.bin = IS_WIN and install.base or "/usr/local/bin"

function install.start()

end

local command = arg[1]
if command == 'build' then
  build.start()
elseif command == 'install' then
  install.start()
else
  Logs.assert(false, 1, "Please specify `build` or `install`")
end
