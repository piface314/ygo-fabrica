local fs = require 'lib.fs'
local path = fs.path
local Zip = require 'lib.zip'
local Config = require 'scripts.config'
local Logs = require 'lib.logs'
local i18n = require 'lib.i18n'
local fun = require 'lib.fun'
require 'lib.table'

local function create_zip(fp)
  local zipfile, err = Zip.new(fp)
  Logs.assert(zipfile, i18n 'export.zip_create_error', ' ', err)
  return zipfile
end

local function get_outdir(flag_o)
  return flag_o and flag_o[1] or '.'
end

local function get_output(outdir, exp, picset)
  local zipname = ('%s-%s'):format(exp, picset)
  return path.join(outdir, zipname .. '.zip'), zipname
end

local function scan_dir(dir, pattern, out)
  local files = fun {}
  for entry in fs.dir(dir) do
    if entry:match(pattern) then
      files:push({path.join(dir, entry), path.join(out, entry)})
    end
  end
  return files
end

local function scan_scripts()
  Logs.info(i18n 'export.scan_scripts')
  return scan_dir('script', 'c%d+%.lua', 'script')
end

local function scan_pics(id, picset)
  Logs.info(i18n 'export.scan_pics')
  local pattern = '%d+%.' .. (picset.ext or 'jpg')
  local pics = scan_dir(path.join('pics', id), pattern, 'pics')
  if picset.field then
    Logs.info(i18n 'export.scan_fields')
    return pics, scan_dir(path.join('pics', id, 'field'), pattern,
                          path.join('pics', 'field'))
  end
  return pics
end

local function get_expansion_file(exp)
  exp = exp .. '.cdb'
  local fp = path.join('expansions', exp)
  return fun {{fp, fp}}
end

return function(flags)
  local fe, fp = flags['-Eall'] or flags['-e'], flags['-Pall'] or flags['-p']
  local verbose = flags['-v'] or flags['--verbose']
  local outdir = get_outdir(flags['-o'])
  local picsets = Config.groups.from_flag.get_many('picset', fp)
  local expansions = Config.groups.from_flag.get_many('expansion', fe)
  local has_any = next(expansions) and next(picsets)
  local scripts = has_any and scan_scripts()
  for exp, _ in pairs(expansions) do
    local exp_file = get_expansion_file(exp)
    for id, picset in pairs(picsets) do
      Logs.info(i18n('export.status', {exp, id}))
      local out, zipname = get_output(outdir, exp, id)
      local zipfile = create_zip(out)
      local files = fun {exp_file, scripts, scan_pics(id, picset)}
                      :reduce(fun {}, fun 'a, b -> a .. b')
      local bar = Logs.bar(#files)
      for _, f in ipairs(files) do
        f = {f[1], path.join(zipname, f[2])}
        bar:update('', verbose and i18n('export.file_srcdst', f))
        local ok, err = zipfile:add(unpack(f))
        Logs.assert(ok, i18n 'export.zip_add_error', ' ', err)
      end
      bar:finish()
      zipfile:close()
    end
  end
  if has_any then
    Logs.ok(i18n 'export.done')
  end
end
