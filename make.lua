package.path = './?/init.lua;' .. package.path
local Logs = require 'lib.logs'
local Interpreter = require 'lib.interpreter'
local Spec = require 'spec'
local Locale = require 'locale'

local SEP = package.config:sub(1, 1)
local IS_WIN = SEP == "\\"
local function exec(command)
  if IS_WIN then
    local code1, _, code2 = os.execute(command)
    return (code1 or code2) == 0
  else
    return os.execute(command) == 0
  end
end

local err = nil

local mkdir_cmd = IS_WIN and [[if not exist %q mkdir %q]] or "mkdir -p %s"
local function create_folder(folder)
  err = "Failed to create folder " .. folder
  return exec(mkdir_cmd:format(folder, folder))
end

local function cp(src, dst, file)
  err = ("Failed to copy %q to %q"):format(src, dst)
  if IS_WIN then
    if file then
      local src_file = src:match(".*\\(.-)$") or src
      return exec(("copy /y %q %q"):format(src, dst .. "\\" .. src_file))
    else
      return exec(("xcopy %q %q /s/h/e/k/c/y/i"):format(src, dst .. "\\" .. src))
    end
  else
    return exec(("cp -ar %s %s"):format(src, dst))
  end
end

local function read_file(fp)
  local f, errmsg = io.open(fp, 'r')
  if not f then
    err = errmsg
    return false
  end
  local content = f:read('*a')
  f:close()
  return content
end

local function write_file(fp, content)
  local f, errmsg = io.open(fp, 'w')
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
  return exec(("chmod +x %s"):format(fp))
end

local build = { tree = "modules" }
local install = {}
local config = {}
local fonts = {}

if IS_WIN then
  install.base = Spec.install_path.windows
  config.base = Spec.config_path.windows
else
  install.base = Spec.install_path.linux
  config.base = Spec.config_path.linux
end

function build.tree_folder() return create_folder(build.tree) end

function build.dependencies()
  for _, dep in ipairs(Spec.dependencies) do
    local ok = exec(("luarocks install %s --tree=%s"):format(dep, build.tree))
    if not ok then
      err = "Failed to install dependency " .. dep
      return false
    end
  end
  return true
end

function build.adjust_toml()
  local toml_fp = build.tree .. "/share/lua/5.1/toml.lua"
  local toml_lib, errmsg = io.open(toml_fp)
  if not toml_lib then err = errmsg; return false end
  local t = toml_lib:read("*a")
  toml_lib:close()
  t = t:gsub('while(not char():match(nl)) do', 'while(not char():match(nl) and cursor <= toml:len()) do')
  local pf, m, sf = t:match("^(.*local function parseNumber%(%)(.-))(%s+while%(bounds%(%)%) do.*)$")
  if m:match("prefixes") then return true end
  local add = "\
\t\tlocal prefixes = { ['0x'] = 16, ['0o'] = 8, ['0b'] = 2 }\
\t\tlocal ranges = { [2] = '[01]', [8] = '[0-7]', [16] = '%x' }\
\t\tlocal base = prefixes[char(0) .. char(1)]\
\t\tif base then\
\t\t\tstep(2)\
\t\t\tlocal digits = ranges[base]\
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

function build.start()
  local steps = build.tree_folder() and build.dependencies() and build.adjust_toml()
  Logs.assert(steps, err)
  Logs.ok("YGOFabrica has been successfully built!")
end

function install.set_paths(base)
  install.base = base or install.base
  install.bin = IS_WIN and install.base or Spec.bin_path
end

function install.base_folder()
  return create_folder(install.base)
end

function install.spec()
  local info = read_file("lib/version.lua")
  if not info then return false end
  local data = {
    number = Spec.version,
    name = Spec.version_name
  }
  info = info:gsub([[([_%w]+)%s*=%s*(['"]).-%2]], function(key)
    local v = data[key]
    if not v then return nil end
    return ("%s = %q"):format(key, v)
  end)
  return write_file("lib/version.lua", info)
end

function install.copy()
  return cp("modules", install.base)
    and cp("lib", install.base)
    and cp("locale", install.base)
    and cp("res", install.base)
    and cp("scripts", install.base)
    and cp("CHANGELOG.md", install.base, true)
    and cp("LICENSE", install.base, true)
    and cp("README.md", install.base, true)
end

function install.bins()
  if IS_WIN then
    local bin = ([[
@echo off
setlocal
set "YGOFAB_ROOT=$root"
set "LUA_PATH=%YGOFAB_ROOT%/?.lua;%YGOFAB_ROOT%/?/init.lua;%YGOFAB_ROOT%/modules/share/lua/5.1/?.lua;%YGOFAB_ROOT%/modules/share/lua/5.1/?/init.lua"
set "LUA_CPATH=%YGOFAB_ROOT%/modules/lib/lua/5.1/?.dll"
set "PATH=%YGOFAB_ROOT%/luajit;%YGOFAB_ROOT%/vips/bin;%PATH%"
luajit "%YGOFAB_ROOT%/scripts/$script.lua" %*
endlocal
@echo on
]]):gsub("$root", install.base)
    os.remove(install.bin .. "\\ygofab.bat")
    os.remove(install.bin .. "\\ygopic.bat")
    return write_file(install.bin .. "\\ygofab.cmd", bin:gsub("$script", "ygofab"))
      and write_file(install.bin .. "\\ygopic.cmd", bin:gsub("$script", "ygopic"))
  else
    local bin = ([[
#!/usr/bin/env bash
export YGOFAB_ROOT="$root"
export LUA_PATH="${YGOFAB_ROOT}/?.lua;${YGOFAB_ROOT}/?/init.lua;${YGOFAB_ROOT}/modules/share/lua/5.1/?.lua;${YGOFAB_ROOT}/modules/share/lua/5.1/?/init.lua"
export LUA_CPATH="${YGOFAB_ROOT}/modules/lib/lua/5.1/?.so"
luajit "${YGOFAB_ROOT}/scripts/$script.lua" $@
]]):gsub("$root", install.base)
    return write_file(install.bin .. "/ygofab", bin:gsub("$script", "ygofab"))
      and write_file(install.bin .. "/ygopic", bin:gsub("$script", "ygopic"))
      and chmod(install.bin .. "/ygofab") and chmod(install.bin .. "/ygopic")
  end
end

function install.start(_, base)
  install.set_paths(base)
  local steps = install.base_folder() and install.spec() and install.copy()
    and install.bins()
  Logs.assert(steps, err)
  Logs.ok("YGOFabrica has been successfully installed!")
end

function config.write(gamepath)
  local base = config.base
  local content = ([[
# Global configurations for YGOFabrica
locale = 'pt'

# Define one or more game directories
[gamedir.main]
path = '''%s'''
default = true

# Define one or more picsets
[picset.regular]
mode = 'proxy'
size = '256x'
ext = 'jpg'
field = true
default = true
]]):format(gamepath or "")
  return create_folder(base) and write_file(base .. "/config.toml", content)
end

function config.start(_, gamepath)
  Logs.assert(config.write(gamepath), err)
  Logs.ok("YGOFabrica has been successfully configured!")
end

function fonts.copy(fp)
  local target = table.concat({install.base, 'res', 'composer', 'fonts'}, SEP)
  return cp(fp or 'fonts', target)
end

function fonts.start(_, fp)
  Logs.assert(fonts.copy(fp), err)
  Logs.ok("Fonts were successfully installed to YGOFabrica!")
end

local interpreter = Interpreter.new()
interpreter:add_command('build', build.start)
interpreter:add_command('install', install.start)
interpreter:add_command('config', config.start)
interpreter:add_command('fonts', fonts.start)
interpreter:add_command('', function()
  Logs.error("Please specify `build`, `install`, `config` or `fonts`")
end)
local errmsg = interpreter:exec(...)
Logs.assert(not errmsg, errmsg)
