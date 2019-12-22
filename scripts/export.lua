local path = require 'path'
local zip = require 'ZipWriter'
local fs = require 'lfs'
local Config = require 'scripts.config'
local Logs = require 'scripts.logs'


local insert = table.insert

local PWD

local function get_picsets(flag_p)
  local all = flag_p and not flag_p[1]
  local picset = flag_p and flag_p[1]
  if all then
    return Config.get_all(PWD, 'picset')
  elseif picset then
    local ps = Config.get_one(PWD, 'picset', picset)
    Logs.assert(ps, 1, "Pic set \"", picset, "\" is not configured.")
    return { [picset] = ps }
  else
    return Config.get_defaults(PWD, 'picset')
  end
end

local function get_outdir(flag_o)
  return flag_o and flag_o[1] or PWD
end

local function get_output(outdir, pack_name, picset)
  local zipname = ("%s-%s"):format(pack_name, picset)
  return path.join(outdir, zipname .. ".zip"), zipname
end

local function create_zip(fp)
  local zipfile = zip.new()
  local f, errmsg = io.open(fp, 'w+b')
  Logs.assert(f, 1, errmsg)
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

local function add_dir(pattern, dir, zipfile, zipdir, tag)
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
  local s, added, total = pcall(add)
  if s then
    Logs.info(("%d out of %d %s added"):format(added, total, tag))
    if added == 0 then
      Logs.warning("No ", tag," added. Something seems wrong...")
    end
  else
    Logs.warning(("Failed while adding %s:\n"):format(tag), added)
  end
end

local function add_scripts(zipname, zipfile)
  add_dir("c%d+%.lua", path.join(PWD, "script"), zipfile,
    path.join(zipname, "script"), "scripts")
end

local function add_pics(zipname, zipfile, picset, pscfg)
  add_dir("%d+%." .. pscfg.ext, path.join(PWD, "pics", picset), zipfile,
    path.join(zipname, "pics"), "pics")
  if pscfg.field then
    add_dir("%d+%." .. pscfg.ext, path.join(PWD, "pics", picset, "field"),
      zipfile, path.join(zipname, "pics", "field"), "field pics")
  end
end

local function add_expansion(zipname, zipfile, pack_name)
  local exp = pack_name .. ".cdb"
  local desc, r, errmsg = reader(path.join(PWD, exp), false)
  if r then
    zipfile:write(path.join(zipname, "expansions", exp), desc, r)
    Logs.info("Added expansion")
  else
    Logs.warning("Failed to add expansion:\n", errmsg)
  end
end

return function(pwd, flags)
  PWD = pwd
  local _, pack_name = path.split(pwd)
  local fp, fo = flags['-Pall'] or flags['-p'], flags['-o']
  local outdir = get_outdir(fo)
  local picsets = get_picsets(fp)
  for id, pscfg in pairs(picsets) do
    Logs.info("Exporting for ", id)
    local out, zipname = get_output(outdir, pack_name, id)
    local zipfile = create_zip(out)
    add_scripts(zipname, zipfile)
    add_pics(zipname, zipfile, id, pscfg)
    add_expansion(zipname, zipfile, pack_name)
    zipfile:close()
  end
  if not next(picsets) then
    Logs.warning("No picset was found")
  else
    Logs.ok("Export complete!")
  end
end
