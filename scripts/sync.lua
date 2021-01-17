local Logs = require 'lib.logs'
local Config = require 'scripts.config'
local Export = require 'scripts.export'
local MakeWriter = require 'scripts.make.writer'
local path = require 'lib.fs'.path
local i18n = require 'lib.i18n'

local function copy_strings(eid, gid, gpath)
  local src_fp = path.join('expansions', eid .. '-strings.conf')
  local dst_fp = path.join(gpath, 'expansions', 'strings.conf')
  if MakeWriter.merge_strings(src_fp, dst_fp) then
    Logs.info(i18n 'sync.writing_string')
  end
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
