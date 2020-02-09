local Logs = require 'lib.logs'
local Interpreter = require 'lib.interpreter'
local dependencies = require 'dependencies'


local IS_WIN = package.config:sub(1,1) == "\\"

local err = nil

local mkdir_cmd = IS_WIN and [[if not exist "%s" mkdir %s]] or "mkdir -p %s"
local function create_folder(folder)
  err = "Failed to create folder " .. folder
  return os.execute(mkdir_cmd:format(folder, folder)) == 0
end

local cp_cmd = IS_WIN and "xcopy %q %q /s/h/e/k/f/c" or "cp -avr %s %s"
local function cp(src, dst)
  err = ("Failed to copy %q to %q"):format(src, dst)
  return os.execute(cp_cmd:format(src, dst)) == 0
end

local function write_file(fp, content)
  local f, errmsg = io.open(fp, "w")
  if not f then
    err = errmsg
    return false
  end
  f:write(content)
  f:close()
  return true
end

local function chmod(fp)
  err = "Failed to give execute permission to " .. fp
  return os.execute(("chmod +x %s"):format(fp)) == 0
end

local build = {}
build.tree = "./lua-modules"

function build.tree_folder() return create_folder(build.tree) end

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

function build.correct_toml()
  local toml_fp = build.tree .. "/share/lua/5.1/toml.lua"
  local toml_lib, errmsg = io.open(toml_fp)
  if not toml_lib then err = errmsg; return false end
  local t = toml_lib:read("*a")
  toml_lib:close()
  local pf, sf = t:match("^(.*local function parseNumber%(%).-)(%s+while%(bounds%(%)%) do.*)$")
  local add = "\
\t\tlocal prefixes = { ['0x'] = 16, ['0o'] = 8, ['0b'] = 2 }\
\t\tlocal base = prefixes[char(0) .. char(1)]\
\t\tif base then\
\t\t\tstep(2)\
\t\t\tlocal digits = ({ [2] = '[01]', [8] = '[0-7]', [16] = '%x' })[base]\
\t\t\twhile(bounds()) do\
\t\t\t\tif char():match(digits) then\
\t\t\t\t\tnum = num .. char()\
\t\t\t\telseif char():match(ws) or char() == '#' or char():match(nl)\
\t\t\t\t\tor char() == ',' or char() == ']' or char() == '}' then\
\t\t\t\t\tbreak\
\t\t\t\telseif char() ~= '_' then\
\t\t\t\t\terr('Invalid number')\
\t\t\t\tend\
\t\t\t\tstep()\
\t\t\tend\
\t\t\tif num == '' then\
\t\t\t\terr('Invalid number')\
\t\t\tend\
\t\t\treturn {value = tonumber(num, base), type = 'int'}\
\t\tend"
  return write_file(toml_fp, ("%s%s%s"):format(pf, add, sf))
end

function build.path_req()
  return write_file(build.tree .. "/set-paths.lua", [[
local version = _VERSION:match("%d+%.%d+")
package.path = ("lua-modules/share/lua/%s/?.lua;lua-modules/share/lua/%s/?/init.lua;%s")
  :format(version, version, package.path)
package.cpath = ("lua-modules/lib/lua/%s/?.so;%s"):format(version, package.cpath)]])
end

function build.start()
  Logs.assert(build.tree_folder() and build.dependencies()
    and build.correct_toml() and build.path_req(), 1, err)
  Logs.ok("YGOFabrica has been successfully built!")
end

local install = {}
install.base = IS_WIN and "C:/Program Files/YGOFabrica" or "/usr/local/ygofab"

function install.set_paths(base)
  install.base = base or install.base
  install.bin = IS_WIN and install.base or "/usr/local/bin"
end

function install.base_folder()
  return create_folder(install.base)
end

function install.copy()
  return cp("lua-modules", install.base)
    and cp("lib", install.base)
    and cp("res", install.base)
    and cp("scripts", install.base)
    and cp("LICENSE", install.base)
    and cp("README.md", install.base)
end

function install.bins()
  if IS_WIN then

  else
    local bin = ([[
#!/usr/bin/env bash
ygofab_home=%s
back=$PWD
cd $ygofab_home
luajit -l lua-modules.set-paths scripts/%%s.lua $back $@
cd $back
]]):format(install.base)
    return write_file(install.bin .. "/ygofab", bin:format("ygofab"))
      and write_file(install.bin .. "/ygopic", bin:format("ygopic"))
      and chmod(install.bin .. "/ygofab") and chmod(install.bin .. "/ygopic")
  end
end

function install.start(_, base)
  install.set_paths(base)
  Logs.assert(install.base_folder() and install.copy() and install.bins(), 1, err)
  Logs.ok("YGOFabrica has been successfully installed!", IS_WIN and (" Now add " ..
    install.bin .. " to your PATH so you can run `ygofab` and `ygopic` from cmd.") or "")
end

local config = {}

function config.write(gamepath)
  err = "Please specify your game path"
  if not gamepath then return false end
  local home = IS_WIN and --[[HOME .. ]]"/ygofab" or (os.getenv("HOME") .. "/ygofab")
  return create_folder(home)
    and write_file(home .. "/config.toml", ([[
# Global configurations for YGOFabrica

# Define one or more game directories
[gamedir.main]
path = '%s'
default = true

# Define one or more picsets
[picset.regular]
mode = 'proxy'
size = '256x'
ext = 'jpg'
field = true
default = true
]]):format(gamepath))
end

function config.start(_, gamepath)
  Logs.assert(config.write(gamepath), 1, err)
  Logs.ok("YGOFabrica has been successfully configured!")
end

local interpreter = Interpreter()
interpreter:add_command('build', build.start)
interpreter:add_command('install', install.start)
interpreter:add_command('config', config.start)
interpreter:add_fallback('', function()
  Logs.assert(false, 1, "Please specify `build`, `install` or `config`")
end)
local errmsg, cmd, args, flags = interpreter:parse(unpack(arg))
Logs.assert(not errmsg, 1, errmsg)
interpreter:exec(cmd, args, flags)
