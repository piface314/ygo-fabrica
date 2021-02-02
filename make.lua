package.path = './?.lua;./?/init.lua;./T/share/lua/5.1/?.lua;./T/share/lua/5.1/?/init.lua;'
package.cpath = './T/lib/lua/5.1/?.so;'

local Spec = require 'spec'
local Interpreter = require 'lib.interpreter'
local Logs, i18n

local SEP = package.config:sub(1, 1)
local WIN = SEP == '\\'
package.path = package.path:gsub('/', SEP):gsub('T', Spec.rocks_tree)
package.cpath = package.cpath:gsub('/', SEP):gsub('T', Spec.rocks_tree)

local exec, cp, os_name

local cmd_build = {}
local cmd_install = {}
local cmd_config = {}

cmd_build.file_list = {
  'lib', 'locale', 'modules', 'res', 'scripts', 'CHANGELOG.md',
  'LICENSE', 'README.md', 'spec.lua', 'make.lua'
}

cmd_install.file_list = {
  'lib', 'locale', 'modules', 'res', 'scripts', 'CHANGELOG.md', 'LICENSE', 'README.md'
}

if WIN then
  table.insert(cmd_build.file_list, 'install.cmd')
  cmd_install.bin = [[
@echo off
setlocal
call :setESC > nul 2> nul
set "YGOFAB_ROOT=$root"
set "LUA_PATH=%YGOFAB_ROOT%/?.lua;%YGOFAB_ROOT%/?/init.lua;%YGOFAB_ROOT%/modules/share/lua/5.1/?.lua;%YGOFAB_ROOT%/modules/share/lua/5.1/?/init.lua"
set "LUA_CPATH=%YGOFAB_ROOT%/modules/lib/lua/5.1/?.dll"
set "PATH=%YGOFAB_ROOT%/luajit;%YGOFAB_ROOT%/vips/bin;%PATH%"
luajit "%YGOFAB_ROOT%/scripts/$script.lua" %*
endlocal
@echo on
]]
  function exec(command, ...)
    local code1, _, code2 = os.execute(command:format(...))
    return (code1 or code2) == 0
  end
  function cp(src, dst, file)
    if file then
      local src_file = src:match('.*\\(.-)$') or src
      return exec('copy /y "%s" "%s"', src, dst .. '\\' .. src_file)
    else
      return exec('xcopy "%s" "%s" /s/h/e/k/c/y/i', src, dst .. '\\' .. src)
    end
  end
  function cmd_build.luajit()
    -- TODO
  end
  function cmd_build.vips()
    -- TODO
  end
else
  table.insert(cmd_build.file_list, 'install')
  cmd_install.bin = [[
#!/usr/bin/env bash
export YGOFAB_ROOT="$root"
export LUA_PATH="${YGOFAB_ROOT}/?.lua;${YGOFAB_ROOT}/?/init.lua;${YGOFAB_ROOT}/modules/share/lua/5.1/?.lua;${YGOFAB_ROOT}/modules/share/lua/5.1/?/init.lua"
export LUA_CPATH="${YGOFAB_ROOT}/modules/lib/lua/5.1/?.so"
luajit "${YGOFAB_ROOT}/scripts/$script.lua" $@
]]
  function exec(command, ...) return os.execute(command:format(...)) == 0 end
  function cp(src, dst) return exec('cp -ar "%s" "%s"', src, dst) end
  function cmd_build.luajit()
    local path = require 'lib.path'
    table.insert(cmd_build.file_list, 'luajit')
    if path.exists('luajit') and path.isdir('luajit') then return end
    local luajit = Spec.build.luajit_version
    local ok = exec('wget "http://luajit.org/download/%s.tar.gz"', luajit)
      and exec('tar -zxf "%s.tar.gz"', luajit)
      and exec('rm "%s.tar.gz"', luajit)
      and exec('mv %s ./luajit', luajit)
    Logs.assert(ok, i18n 'build.luajit_error')
  end
  function cmd_build.vips()
    local path = require 'lib.path'
    table.insert(cmd_build.file_list, 'vips')
    if path.exists('vips') and path.isdir('vips') then return end
    local version = Spec.build.vips_version
    local name = 'vips-' .. version
    local ok = exec('wget "https://github.com/libvips/libvips/releases/download/v%s/%s.tar.gz"', version, name)
      and exec('tar -zxf "%s.tar.gz"', name)
      and exec('rm "%s.tar.gz"', name)
      and exec('mv %s ./vips', name)
    Logs.assert(ok, i18n 'build.vips_error')
  end
end

local function chmod(fp) return not WIN or exec('chmod +x "%s"', fp) end

local function read(fp)
  local f, e = io.open(fp, 'r')
  if not f then return false, e end
  local content = f:read('*a')
  f:close()
  return content
end

local function write(fp, content)
  local f, e = io.open(fp, 'w')
  if not f then return false, e end
  f:write(content)
  f:close()
  return true
end

local function require_missing(locale)
  local ok
  ok, Logs = pcall(require, 'lib.logs')
  if not ok then return false end
  i18n = require 'i18n'
  i18n.loadFile('make-locale.lua')
  i18n.setFallbackLocale('en')
  i18n.setLocale(locale)
  return true
end

function cmd_build.run(flags)
  cmd_build.dependencies(Spec.build.dependencies)
  assert(require_missing(flags['--locale']))
  cmd_build.adjust_i18n()
  cmd_build.dependencies(Spec.dependencies)
  cmd_build.adjust_toml()
  cmd_build.spec()
  if flags['-r'] or flags['--release'] then
    if not flags['--slim'] then
      cmd_build.luajit()
      cmd_build.vips()
    end
    cmd_build.release()
  end
  Logs.ok(i18n 'build.ok')
end

function cmd_build.dependencies(dep_list)
  local fail = i18n and i18n 'build.dep_error' or 'failed to build dependencies'
  local tree = Spec.rocks_tree
  for _, dep in ipairs(dep_list) do
    assert(exec('luarocks install %s --tree="%s"', dep, tree), fail)
  end
end

function cmd_build.adjust_i18n()
  local fp = Spec.rocks_tree .. '/share/lua/5.1/i18n/init.lua'
  local f = Logs.assert(read(fp), i18n 'build.i18n_error')
  local line = 'return type%(str%) == \'string\' and #str > 0'
  local out = f:gsub(line, 'return type(str) == \'string\'')
  Logs.assert(write(fp, out), i18n 'build.i18n_error')
end

function cmd_build.adjust_toml()
  local fp = Spec.rocks_tree .. '/share/lua/5.1/toml.lua'
  local f = Logs.assert(read(fp), i18n 'build.toml_error')
  f = f:gsub('while(not char():match(nl)) do', 'while(not char():match(nl) and cursor <= toml:len()) do')
  local pf, m, sf = f:match('^(.*local function parseNumber%(%)(.-))(%s+while%(bounds%(%)%) do.*)$')
  if m:match('prefixes') then return end
  local add = '\
\t\tlocal prefixes = { ["0x"] = 16, ["0o"] = 8, ["0b"] = 2 }\
\t\tlocal ranges = { [2] = "[01]", [8] = "[0-7]", [16] = "%x" }\
\t\tlocal base = prefixes[char(0) .. char(1)]\
\t\tif base then\
\t\t\tstep(2)\
\t\t\tlocal digits = ranges[base]\
\t\t\twhile(bounds()) do\
\t\t\t\tif char():match(digits) then\
\t\t\t\t\tnum = num .. char()\
\t\t\t\telseif char():match(ws) or char() == "#" or char():match(nl)\
\t\t\t\t\tor char() == "," or char() == "]" or char() == "}" then\
\t\t\t\t\tbreak\
\t\t\t\telseif char() ~= "_" then\
\t\t\t\t\terr("Invalid number")\
\t\t\t\tend\
\t\t\t\tstep()\
\t\t\tend\
\t\t\tif num == "" then\
\t\t\t\terr("Invalid number")\
\t\t\tend\
\t\t\treturn {value = tonumber(num, base), type = "int"}\
\t\tend'
  local out = ('%s%s%s'):format(pf, add, sf)
  Logs.assert(write(fp, out), i18n 'build.toml_error')
end

function cmd_build.spec()
  local info = read('lib/version.lua')
  if not info then return false end
  local data = {number = Spec.version, name = Spec.version_name}
  info = info:gsub([[([_%w]+)%s*=%s*(['"]).-%2]], function(key)
    local v = data[key]
    if not v then return nil end
    return ('%s = \'%s\''):format(key, v)
  end)
  return write('lib/version.lua', info)
end

function cmd_build.release()
  local path = require 'path'
  local target = Spec.build.target
    :gsub('%%{version}', Spec.version)
  local build_fp = path.join('build', target)
  Logs.assert(path.mkdir(build_fp), i18n('mkdir_error', {build_fp}))
  for _, fp in ipairs(cmd_build.file_list) do
    Logs.assert(cp(fp, build_fp, path.isfile(fp)), i18n('cp_error', {fp}))
  end
  if WIN then
    local Zip = require 'lib.zip'
    local z = Zip.new(target .. '-windows.zip')
    Logs.assert(z, i18n 'build.release_error')
    z:add(build_fp, target)
    Logs.assert(z:close() > 0, i18n 'build.release_error')
  else
    local ok = exec('cd build && tar -zcf ../%s-linux.tar.gz %s; cd ..', target, target)
    Logs.assert(ok, i18n 'build.release_error')
  end
end

function cmd_install.run(flags, base)
  assert(require_missing(flags['--locale']))
  cmd_install.base(base)
  cmd_install.fonts()
  cmd_install.copy(base)
  cmd_install.bins(base)
end

function cmd_install.base(base)
  local path = require 'path'
  Logs.assert(path.mkdir(base), i18n('mkdir_error', {base}))
end

function cmd_install.fonts()
  local path = require 'path'
  if path.isdir('fonts') then
    local target = path.join('res', 'composer', 'fonts')
    Logs.assert(cp('fonts', target), i18n('cp_error', {'fonts'}))
  end
end

function cmd_install.copy(base)
  local path = require 'lib.path'
  base = base or Spec.install_path
  for _, fp in ipairs(cmd_install.file_list) do
    Logs.assert(cp(fp, base, path.isfile(fp)), i18n('cp_error', {fp}))
  end
  Logs.assert(not path.exists('luajit') or cp('luajit', base), i18n('cp_error', 'luajit'))
  Logs.assert(not path.exists('vips') or cp('vips', base), i18n('cp_error', 'vips'))
end

function cmd_install.bins(base)
  local path = require 'path'
  local bins = {'ygofab', 'ygopic'}
  local ext = WIN and '.cmd' or ''
  for _, bin in ipairs(bins) do
    local fp = path.join(Spec.bin_path, bin .. ext)
    local b = cmd_install.bin:gsub('$script', bin):gsub('$root', base)
    for f in path.each(path.join(Spec.bin_path, bin .. '*')) do path.remove(f) end
    Logs.assert(write(fp, b) and chmod(fp), i18n 'install.bin_error')
  end
end

function cmd_config.run(flags, gamepath)
  local locale = flags['--locale']
  assert(require_missing(locale))
  local path = require 'path'
  local config = [[
# %s
locale = '%s'

# %s
[gamedir.main]
default = true
path = '''%s'''

# %s
[picset.regular]
default = true
mode = 'proxy'
size = '256x'
ext = 'jpg'
field = true
]]
  config = config:format(i18n 'config.comment.header', locale or 'en',
    i18n 'config.comment.gamedir', gamepath or '', i18n 'config.comment.picset')
  Logs.assert(path.mkdir(Spec.config_path), i18n('mkdir_error', {Spec.config_path}))
  Logs.assert(write(path.join(Spec.config_path, 'config.toml'), config), i18n 'config.error')
end

local interpreter = Interpreter.new()
interpreter:add_command('build', cmd_build.run, '-r', 0, '--release', 0, '--slim', 0, '--locale', 1)
interpreter:add_command('install', cmd_install.run, '--locale', 1)
interpreter:add_command('config', cmd_config.run, '--locale', 1)
interpreter:add_command('', function(flags)
  if require_missing(flags['--locale']) then Logs.error(i18n 'missing_command') end
  error('ERROR: please specify `build`, `install` or `config`.')
end, '--locale', 1)
local errmsg, data = interpreter:exec(...)
local ok = require_missing()
if ok then
  Logs.assert(not errmsg, i18n(('interpreter.%s'):format(errmsg), {data}))
else
  assert(not errmsg, ('ERROR: %s %s'):format(errmsg, data))
end