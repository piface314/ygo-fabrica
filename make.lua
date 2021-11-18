package.path = './?.lua;./?/init.lua;./T/share/lua/5.1/?.lua;./T/share/lua/5.1/?/init.lua;'
package.cpath = './T/lib/lua/5.1/?.ext;'

local Spec = require 'spec'
local Interpreter = require 'lib.interpreter'
local Logs, i18n, path

local SEP = package.config:sub(1, 1)
local WIN = SEP == '\\'
package.path = package.path:gsub('/', SEP):gsub('T', Spec.rocks_tree)
package.cpath = package.cpath:gsub('/', SEP):gsub('T', Spec.rocks_tree)

local cp, check_cmd

local cmd_build = {}
local cmd_install = {}
local cmd_config = {}

cmd_build.file_list = {
  'lib', 'locale', 'modules', 'res', 'scripts', 'CHANGELOG.md',
  'LICENSE', 'README.md', 'spec.lua', 'make.lua', 'make-locale.lua'
}

cmd_install.file_list = {
  'lib', 'locale', 'modules', 'res', 'scripts', 'CHANGELOG.md', 'LICENSE', 'README.md'
}

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

local function exec(command, ...)
  local code1, _, code2 = os.execute(command:format(...))
  return code1 == 0 or code2 == 0
end

local function chmod(fp) return WIN or exec('chmod +x "%s"', fp) end

if WIN then
  package.cpath = package.cpath:gsub('%.ext', '.dll')
  table.insert(cmd_build.file_list, 'install.cmd')
  cmd_install.bin = [[
@echo off
call :setESC > nul 2> nul
chcp 65001 > nul 2> nul
setlocal
set "YGOFAB_ROOT=$root"
set "LUA_PATH=%YGOFAB_ROOT%/?.lua;%YGOFAB_ROOT%/?/init.lua;%YGOFAB_ROOT%/modules/share/lua/5.1/?.lua;%YGOFAB_ROOT%/modules/share/lua/5.1/?/init.lua"
set "LUA_CPATH=%YGOFAB_ROOT%/modules/lib/lua/5.1/?.dll"
set "PATH=%YGOFAB_ROOT%/luajit;%YGOFAB_ROOT%/vips/bin;%PATH%"
luajit "%YGOFAB_ROOT%/scripts/$script.lua" %*
endlocal
@echo on
]]
  function cp(src, dst, file)
    if file then
      return exec('xcopy "%s" "%s" /q/y', src, dst)
    else
      local folder_name = src:match('[^\\]+$')
      return exec('xcopy "%s" "%s" /q/s/h/e/k/c/y/i', src, dst .. '\\' .. folder_name)
    end
  end
  function check_cmd(command) return exec('where >nul 2>nul "%s"', command) end

  exec 'chcp 65001 > nul 2> nul'

  function cmd_build.luajit()
    table.insert(cmd_build.file_list, 'luajit')
    if path.isdir('luajit') then return end
    local luajit = 'LuaJIT-' .. Spec.build.luajit_version
    local ok = exec('certutil -urlcache -split -f "http://luajit.org/download/%s.zip"', luajit)
      and exec('"C:\\Program Files\\7-Zip\\7z" x %s.zip -xr!contact.png', luajit)
      and exec('del /q/f "%s.zip"', luajit)
    Logs.assert(ok, i18n 'build.luajit_error')
    ok = exec('cd "%s\\src" && msvcbuild && cd ..\\..', luajit)
      and cp(luajit .. '\\src\\jit', 'luajit')
      and cp(luajit .. '\\src\\lua51.dll', 'luajit', true)
      and cp(luajit .. '\\src\\luajit.exe', 'luajit', true)
      and exec('rmdir /q/s "%s"', luajit)
    Logs.assert(ok, i18n 'build.luajit_error')
  end
  function cmd_build.vips()
    table.insert(cmd_build.file_list, 'vips')
    if path.isdir('vips') then return end
    local version = Spec.build.vips_version
    local vips_file = 'vips-dev-w64-web-' .. version .. '.zip'
    local vips = 'vips-dev-' .. version:match('^(.+%..+)%..+$')
    local ok = exec('certutil -urlcache -split -f "https://github.com/libvips/libvips/releases/download/v%s/%s"', version, vips_file)
      and exec('"C:\\Program Files\\7-Zip\\7z" x %s', vips_file)
      and exec('del /f/q "%s"', vips_file)
      and cp(vips .. '\\bin', 'vips')
      and cp(vips .. '\\etc', 'vips')
      and cp(vips .. '\\AUTHORS', 'vips', true)
      and cp(vips .. '\\COPYING', 'vips', true)
      and exec('rmdir /q/s "%s"', vips)
    Logs.assert(ok, i18n 'build.vips_error')
  end
  function cmd_install.luajit(base)
    if check_cmd('luajit') then return end
    Logs.assert(path.isdir('luajit') and cp('luajit', base), i18n('cp_error', {'luajit'}))
  end
  function cmd_install.vips(base)
    if check_cmd('vips') then return end
    Logs.assert(path.isdir('vips') and cp('vips', base), i18n('cp_error', {'vips'}))
  end
  function cmd_install.pathenv(base)
    local pipe = io.popen('reg query HKCU\\Environment /v PATH')
    pipe:read('*l'); pipe:read('*l')
    local pathvar = pipe:read('*l'):match('%s*[%w_]+%s*[%w_]+%s*(.*)') or ''
    pipe:close()
    for fp in pathvar:gmatch '(.-);' do
      if fp == base then return end
    end
    local bup_fp = 'path-var-backup'
    Logs.assert(write(bup_fp, pathvar), i18n 'install.path_backup_error')
    Logs.warning(i18n('install.path_backup', {bup_fp}))
    Logs.assert(exec('setx PATH "%s;%s"', base, pathvar), i18n 'install.path_error')
  end
else
  package.cpath = package.cpath:gsub('%.ext', '.so')
  table.insert(cmd_build.file_list, 'install')
  cmd_install.bin = [[
#!/usr/bin/env bash
export YGOFAB_ROOT="$root"
export LUA_PATH="${YGOFAB_ROOT}/?.lua;${YGOFAB_ROOT}/?/init.lua;${YGOFAB_ROOT}/modules/share/lua/5.1/?.lua;${YGOFAB_ROOT}/modules/share/lua/5.1/?/init.lua"
export LUA_CPATH="${YGOFAB_ROOT}/modules/lib/lua/5.1/?.so"
luajit "${YGOFAB_ROOT}/scripts/$script.lua" $@
]]
  function cp(src, dst) return exec('cp -ar "%s" "%s"', src, dst) end
  function check_cmd(command) return exec('command -v "%s" >/dev/null 2>&1', command) end
  function cmd_build.luajit() end
  function cmd_build.vips() end
  function cmd_install.luajit() end --merged with cmd_install.vips
  function cmd_install.vips()
    local install_script = read('install')
    Logs.assert(install_script, i18n 'build.install_script_error')
    install_script = install_script
      :gsub('\nluajit_version=".-"\n', '\nluajit_version="' .. Spec.build.luajit_version .. '"\n')
      :gsub('\nvips_version=".-"\n', '\nvips_version="' .. Spec.build.vips_version .. '"\n')
    Logs.assert(write('install', install_script), i18n 'build.install_script_error')
  end
  function cmd_install.pathenv() end
end

local function require_missing(locale_f)
  local ok
  ok, Logs = pcall(require, 'lib.logs')
  if not ok then return false end
  ok, path = pcall(require, 'path')
  if not ok then return false end
  i18n = require 'i18n'
  i18n.loadFile('make-locale.lua')
  i18n.setFallbackLocale('en')
  i18n.setLocale(locale_f and locale_f[1] or 'en')
  return true
end

function cmd_build.run(flags)
  local dep = flags['-d'] or flags['--deps']
  local rel = flags['-r'] or flags['--release']
  local both = not (dep or rel)
  if both or dep then
    cmd_build.dependencies(Spec.build.dependencies)
    assert(require_missing(flags['--locale']))
    cmd_build.adjust_i18n()
    cmd_build.dependencies(Spec.dependencies)
    cmd_build.adjust_toml()
    cmd_build.spec()
  else
    assert(require_missing(flags['--locale']))
  end
  if both or rel then
    cmd_build.luajit()
    cmd_build.vips()
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
  local out = f:gsub(line, 'return type(str) == \'string\'', 1)
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
  local target = Spec.build.target:gsub('%%{version}', Spec.version)
  local build_fp = path.join('build', target)
  Logs.assert(path.mkdir(build_fp), i18n('mkdir_error', {build_fp}))
  for _, fp in ipairs(cmd_build.file_list) do
    Logs.assert(cp(fp, build_fp, path.isfile(fp)), i18n('cp_error', {fp}))
  end
  for fp in path.each(path.join(build_fp, 'res', 'composer', 'fonts', '*tf')) do
    path.remove(fp)
  end
  if WIN then
    local Zip = require 'lib.zip'
    local z, err = Zip.new(target .. '.zip')
    Logs.assert(z, i18n 'build.release_error', ': ', err)
    z:add(build_fp, target)
    Logs.assert(z:close() > 0, i18n 'build.release_error')
  else
    local ok = exec('cd build && tar -zcf ../%s.tar.gz %s; cd ..', target, target)
    Logs.assert(ok, i18n 'build.release_error')
  end
end

function cmd_install.run(flags, base)
  assert(require_missing(flags['--locale']))
  base = base or Spec.install_path
  cmd_install.base(base)
  cmd_install.fonts()
  cmd_install.copy(base)
  cmd_install.luajit(base)
  cmd_install.vips(base)
  cmd_install.bins(base)
  cmd_install.pathenv(base)
  Logs.ok(i18n 'install.ok')
end

function cmd_install.base(base)
  Logs.assert(path.mkdir(base), i18n('mkdir_error', {base}))
end

function cmd_install.fonts()
  if path.isdir('fonts') then
    local target = path.join('res', 'composer')
    Logs.assert(cp('fonts', target), i18n('cp_error', {'fonts'}))
  end
end

function cmd_install.copy(base)
  base = base or Spec.install_path
  for _, fp in ipairs(cmd_install.file_list) do
    Logs.assert(cp(fp, base, path.isfile(fp)), i18n('cp_error', {fp}))
  end
end

function cmd_install.bins(base)
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
  config = config:format(i18n 'config.comment.header', locale and locale[1] or 'en',
    i18n 'config.comment.gamedir', gamepath or '', i18n 'config.comment.picset')
  Logs.assert(path.mkdir(Spec.config_path), i18n('mkdir_error', {Spec.config_path}))
  Logs.assert(write(path.join(Spec.config_path, 'config.toml'), config), i18n 'config.error')
  Logs.ok(i18n 'config.ok')
end

local interpreter = Interpreter.new()
interpreter:add_command('build', cmd_build.run, '-d', 0, '--deps', 0, '-r', 0, '--release', 0, '--locale', 1)
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