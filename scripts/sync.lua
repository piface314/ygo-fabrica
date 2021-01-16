local Logs = require 'lib.logs'
local Config = require 'scripts.config'
local Export = require 'scripts.export'
local path = require 'lib.fs'.path
local i18n = require 'lib.i18n'
local fun = require 'lib.fun'

local STRING_KEYS = fun {setname = true, counter = true}
local function get_lines(fp)
  local src = io.open(fp)
  if not src then return end
  local lines = STRING_KEYS:map(fun '_ -> {}')
  local unwritten = STRING_KEYS:map(fun '_ -> {}')
  for line in src:lines() do
    local key, code, val = line:match('^%s*!(%w+)%s+(0x%x+)%s*(.-)%s*$')
    code = tonumber(code)
    if STRING_KEYS[key] and code and val then
      lines[key][code], unwritten[key][code] = val, val
    end
  end
  src:close()
  return lines, unwritten
end

local fmt_line = fun '... -> ("!%s 0x%04x %s"):format(...)'
local function get_merged_lines(fp, rlines, unwritten)
  local f, wlines = io.open(fp), fun {}
  if f then
    for line in f:lines() do
      local key, code = line:match('^%s*!(%w+)%s+(0x%x+).*$')
      code = tonumber(code or '')
      local val = rlines[key] and rlines[key][code]
      if val then
        unwritten[key][code] = nil
        wlines:push(fmt_line(key, code, val))
      else
        wlines:push(line)
      end
    end
    f:close()
  end
  for key, t in pairs(unwritten) do
    for code, val in pairs(t) do
      wlines:push(fmt_line(key, code, val))
    end
  end
  return table.concat(wlines, '\n')
end

local function copy_strings(eid, gid, gpath)
  local src_fp = path.join('expansions', eid .. '-strings.conf')
  local rlines, unwritten = get_lines(src_fp)
  if not rlines then return end
  local dst_fp = path.join(gpath, 'expansions', 'strings.conf')
  local wlines = get_merged_lines(dst_fp, rlines, unwritten)
  local dst = io.open(dst_fp, 'w')
  if not dst then return end
  Logs.info(i18n 'sync.writing_string')
  dst:write(wlines)
  dst:close()
end

return function(flags)
  local fg, fp, fe = flags['-Gall'] or flags['-g'], flags['-p'], flags['-e']
  local no_string = flags['--no-string']
  local verbose = flags['--verbose']
  local gamedirs = Config.groups.from_flag.get_many('gamedir', fg)
  local pid, picset = Config.groups.from_flag.get_one('picset', fp)
  local eid, exp = Config.groups.from_flag.get_one('expansion', fe)
  for gid, gamedir in pairs(gamedirs) do
    Logs.info(i18n('sync.status', {pid, eid, gid}))
    local outdir = path.join(gamedir.path, 'expansions')
    Export.export(outdir, {[eid] = exp}, {[pid] = picset}, verbose)
    if not no_string then
      copy_strings(eid, gid, gamedir.path)
    end
  end
  Logs.ok(i18n 'sync.done')
end
