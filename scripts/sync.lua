local Logs = require 'lib.logs'
local Config = require 'scripts.config'
local fs = require 'lib.fs'
local path = fs.path
local i18n = require 'lib.i18n'

local function cp(src, dst)
  local fsrc = io.open(src, 'rb')
  if not fsrc then
    return 0
  end
  local fdst = io.open(dst, 'wb')
  if not fdst then
    return 0
  end
  fdst:write(fsrc:read('*a'))
  fsrc:close()
  fdst:close()
  return 1
end

-- TODO: Refactor this into something simpler, and using the progress bar
local function copy_dir(pattern, src, dst, tags)
  local function cpd()
    local to_copy = {}
    local copied, total = 0, 0
    for entry in fs.dir(src) do
      if entry:match(pattern) then
        table.insert(to_copy, entry)
        total = total + 1
      end
    end
    for _, file in ipairs(to_copy) do
      copied = copied + cp(path.join(src, file), path.join(dst, file))
    end
    return copied, total
  end
  local s, copied, total = pcall(cpd)
  if s then
    Logs.info(('%d out of %d %s copied for %q'):format(copied, total, tags[1],
                                                       tags[2]))
    if copied == 0 then
      Logs.warning('No ', tags[1], ' copied for this gamedir.')
    end
  else
    Logs.warning(('Failed while copying %s for %q:\n'):format(tags[1], tags[2]),
                 copied)
  end
end

local function copy_scripts(gamedir, gpath)
  copy_dir('c%d+%.lua', 'script', path.join(gpath, 'script'),
           {'scripts', gamedir})
end

local function copy_pics(gamedir, gpath, picset, pscfg)
  if not pscfg.ext then
    pscfg.ext = 'jpg'
  end
  copy_dir('%d+%.' .. pscfg.ext, path.join('pics', picset),
           path.join(gpath, 'pics'), {'pics', gamedir})
  if pscfg.field then
    copy_dir('%d+%.' .. pscfg.ext, path.join('pics', picset, 'field'),
             path.join(gpath, 'pics', 'field'), {'field pics', gamedir})
  end
end

local function copy_expansion(gamedir, gpath, exp)
  local expansion = exp .. '.cdb'
  local src = path.join('expansions', expansion)
  local dst = path.join(gpath, 'expansions', expansion)
  if cp(src, dst) == 1 then
    Logs.info('Copied expansion for "', gamedir, '"')
  else
    Logs.warning('Failed to copy expansion')
  end
end

local function get_set_codes()
  local src = io.open(path.join('expansions', 'strings.conf'))
  if not src then
    return
  end
  local setcodes, unwritten = {}, {}
  for line in src:lines() do
    local code, name = line:match('^%s*!setname%s+(0x%x+)%s*(.*)$')
    code = tonumber(code)
    if code and name then
      setcodes[code], unwritten[code] = name, name
    end
  end
  src:close()
  return setcodes, unwritten
end

local function get_merged_sets(fp, setcodes, unwritten)
  local f, lines = io.open(fp), ''
  if f then
    for line in f:lines() do
      local code = tonumber(line:match('^%s*!setname%s+(0x%x+).*$') or '')
      local name = setcodes[code]
      if name then
        unwritten[code] = nil
        lines = lines .. ('!setname 0x%04x %s\n'):format(code, name)
      else
        lines = lines .. line .. '\n'
      end
    end
    f:close()
  end
  for code, name in pairs(unwritten) do
    lines = lines .. ('!setname 0x%04x %s\n'):format(code, name)
  end
  return lines
end

local function copy_strings(gamedir, gpath)
  local setcodes, unwritten = get_set_codes()
  if not setcodes then
    return
  end
  local target = path.join(gpath, 'expansions', 'strings.conf')
  local lines = get_merged_sets(target, setcodes, unwritten)
  local dst = io.open(target, 'w')
  if not dst then
    return
  end
  dst:write(lines)
  -- Logs.info('Written strings.conf for "', gamedir, '"')
  dst:close()
end

return function(flags)
  local fg, fp, fe = flags['-Gall'] or flags['-g'], flags['-p'], flags['-e']
  local no_script = flags['--no-script']
  local no_pics = flags['--no-pics']
  local no_exp = flags['--no-exp']
  local no_string = flags['--no-string']
  local gamedirs = Config.groups.from_flag.get_many('gamedir', fg)
  local picset, pscfg, exp
  if not no_pics then
    picset, pscfg = Config.groups.from_flag.get_one('picset', fp)
  end
  if not no_exp then
    exp = Config.groups.from_flag.get_one('expansion', fe)
  end
  for gd, gdcfg in pairs(gamedirs) do
    Logs.info(i18n('sync.status', {picset, exp, gd}))
    if not no_script then
      copy_scripts(gd, gdcfg.path)
    end
    if not no_pics then
      copy_pics(gd, gdcfg.path, picset, pscfg)
    end
    if not no_exp then
      copy_expansion(gd, gdcfg.path, exp)
    end
    if not no_string then
      copy_strings(gd, gdcfg.path)
    end
  end
  Logs.ok(i18n 'sync.done')
end
