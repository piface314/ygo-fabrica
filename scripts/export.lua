local path = require 'lib.path'
local Zip = require 'lib.zip'
local Config = require 'scripts.config'
local Logs = require 'lib.logs'
local i18n = require 'i18n'
local fun = require 'lib.fun'

local Export = {}

---@param fp string
---@return Zip
local function create_zip(fp)
  path.mkdir(path.dirname(fp))
  local zipfile, err = Zip.new(fp)
  Logs.assert(zipfile, i18n 'export.zip_create_error', ' ', err)
  return zipfile
end

local function get_outpattern(flag_o)
  local out = flag_o and flag_o[1] or './'
  return out:match('%.zip$') and out or path.join(out, '@e-@p.zip')
end

local function get_output(outpattern, exp, picset)
  return (outpattern:gsub('@e', exp):gsub('@p', picset))
end

local function scan_dir(dir, pattern, out)
  return fun.iter(path.each(dir .. path.DIR_SEP))
    :filter(function(fp) return path.basename(fp):match(pattern) end)
    :map(function(fp) return {fp, path.join(out, path.basename(fp))} end)
    :totable()
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

local function get_expansion_file(eid)
  local exp = eid .. '.cdb'
  local fp = path.join('expansions', exp)
  return {{fp, fp}}
end

local function get_strings_file(eid)
  local fp = path.join('expansions', eid .. '-strings.conf')
  return path.exists(fp) and {{fp, fp}} or {}
end

function Export.export(outpattern, expansions, picsets, verbose)
  if not next(expansions) or not next(picsets) then
    return false
  end
  local scripts = scan_scripts()
  for eid, _ in pairs(expansions) do
    local exp_file = get_expansion_file(eid)
    local str_file = get_strings_file(eid)
    for pid, picset in pairs(picsets) do
      Logs.info(i18n('export.status', {eid, pid}))
      local zipfile = create_zip(get_output(outpattern, eid, pid))
      local files = fun.chain(exp_file, str_file, scripts, scan_pics(pid, picset)):totable()
      local bar = Logs.bar(#files)
      local errors = {}
      for _, f in ipairs(files) do
        local src, dst = unpack(f)
        bar:update(src, verbose and i18n('export.file_srcdst', f))
        local ok, err = zipfile:add(src, dst)
        if not ok then table.insert(errors, err .. '\n') end
      end
      bar:finish()
      if #errors > 0 then
        local warn = i18n('export.zip_add_error', {count = #errors})
        Logs.warning(warn, '\n', unpack(errors))
      end
      zipfile:close()
    end
  end
  return true
end

function Export.run(flags)
  local fe, fp = flags['-Eall'] or flags['-e'], flags['-Pall'] or flags['-p']
  local verbose = flags['--verbose']
  local outpattern = get_outpattern(flags['-o'])
  local picsets = Config.groups.from_flag.get_many('picset', fp)
  local expansions = Config.groups.from_flag.get_many('expansion', fe)
  if Export.export(outpattern, expansions, picsets, verbose) then
    Logs.ok(i18n 'export.done')
  end
end

setmetatable(Export, {__call = function(_, ...) return _.run(...) end})
return Export
