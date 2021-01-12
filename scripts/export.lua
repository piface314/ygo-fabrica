local fs = require 'lib.fs'
local path = fs.path
local zip = require 'ZipWriter'
local Config = require 'scripts.config'
local Logs = require 'lib.logs'
local i18n = require 'lib.i18n'
require 'lib.table'

local function get_outdir(flag_o)
  return flag_o and flag_o[1] or ""
end

local function get_output(outdir, exp, picset)
  local zipname = ("%s-%s"):format(exp, picset)
  return path.join(outdir, zipname .. ".zip"), zipname
end

local function create_zip(fp)
  local zipfile = zip.new()
  local f, errmsg = io.open(fp, 'w+b')
  Logs.assert(f, errmsg)
  zipfile:open_stream(f, true)
  return zipfile
end

local function reader(fp, istext)
  local f, errmsg = io.open(fp, 'rb')
  if not f then
    return nil, nil, errmsg
  end
  local chunk_size = 1024
  local desc = {
    istext = istext, isfile = true, isdir = false,
    exattrib = { zip.NIX_FILE_ATTR.IFREG, zip.NIX_FILE_ATTR.IRUSR,
      zip.NIX_FILE_ATTR.IWUSR, zip.NIX_FILE_ATTR.IRGRP, zip.DOS_FILE_ATTR.ARCH }
  }
  return desc, function()
    local chunk = f:read(chunk_size)
    if chunk then return chunk end
    f:close()
  end
end

-- TODO: Refactor this into something simpler, and using the progress bar
local function add_dir(pattern, dir, zipfile, zipdir)
  local function add()
    local added, total = 0, 0
    for entry in fs.dir(dir) do
      if entry:match(pattern) then
        local desc, r = reader(path.join(dir, entry), true)
        if r then
          zipfile:write(path.join(zipdir, entry), desc, r)
          added = added + 1
        end
        total = total + 1
      end
    end
    return added, total
  end
  pcall(add)
end

local function add_scripts(zipname, zipfile)
  add_dir("c%d+%.lua", "script", zipfile, path.join(zipname, "script"))
end

local function add_pics(zipname, zipfile, picset, pscfg)
  if not pscfg.ext then pscfg.ext = "jpg" end
  add_dir("%d+%." .. pscfg.ext, path.join("pics", picset), zipfile,
    path.join(zipname, "pics"))
  if pscfg.field then
    add_dir("%d+%." .. pscfg.ext, path.join("pics", picset, "field"),
      zipfile, path.join(zipname, "pics", "field"))
  end
end

local function add_expansion(zipfile, exp)
  exp = exp .. ".cdb"
  local desc, r, errmsg = reader(path.join("expansions", exp), false)
  if r then
    zipfile:write(path.join("expansions", exp), desc, r)
    Logs.info("Added expansion")
  else
    Logs.warning("Failed to add expansion:\n", errmsg)
  end
end

return function(flags)
  local fe, fp, fo = flags['-Eall'] or flags['-e'], flags['-Pall'] or flags['-p'], flags['-o']
  local outdir = get_outdir(fo)
  local picsets = Config.groups.from_flag.get_many('picset', fp)
  local expansions = Config.groups.from_flag.get_many('expansion', fe)
  for exp, _ in pairs(expansions) do
    for id, pscfg in pairs(picsets) do
      Logs.info(i18n('export.status', {exp, id}))
      local out, zipname = get_output(outdir, exp, id)
      local zipfile = create_zip(out)
      add_scripts(zipname, zipfile)
      add_pics(zipname, zipfile, id, pscfg)
      add_expansion(zipfile, exp)
      zipfile:close()
    end
  end
  if next(expansions) and next(picsets) then
    Logs.ok(i18n 'export.done')
  end
end
