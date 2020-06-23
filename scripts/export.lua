local fs = require 'lib.fs'
local path = fs.path
local zip = require 'ZipWriter'
local Config = require 'scripts.config'
local Logs = require 'lib.logs'
require 'lib.table'


local function get_expansions(flag_e)
  local all = flag_e and not flag_e[1]
  local expansion = flag_e and flag_e[1]
  if all then
    local exps = Config.get_all('expansion')
    return table.keys(exps)
  elseif expansion then
    local exp = Config.get_one('expansion', expansion)
    Logs.assert(exp, 1, 'Expansion "', expansion, '" is not configured.')
    return { expansion }
  else
    local exps = Config.get_defaults('expansion')
    return table.keys(exps)
  end
end

local function get_picsets(flag_p)
  local all = flag_p and not flag_p[1]
  local picset = flag_p and flag_p[1]
  if all then
    return Config.get_all('picset')
  elseif picset then
    local ps = Config.get_one('picset', picset)
    Logs.assert(ps, 1, 'Pic set "', picset, '" is not configured.')
    return { [picset] = ps }
  else
    return Config.get_defaults('picset')
  end
end

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
      Logs.warning("No ", tag," added.")
    end
  else
    Logs.warning(("Failed while adding %s:\n"):format(tag), added)
  end
end

local function add_scripts(zipname, zipfile)
  add_dir("c%d+%.lua", "script", zipfile, path.join(zipname, "script"), "scripts")
end

local function add_pics(zipname, zipfile, picset, pscfg)
  if not pscfg.ext then pscfg.ext = "jpg" end
  add_dir("%d+%." .. pscfg.ext, path.join("pics", picset), zipfile,
    path.join(zipname, "pics"), "pics")
  if pscfg.field then
    add_dir("%d+%." .. pscfg.ext, path.join("pics", picset, "field"),
      zipfile, path.join(zipname, "pics", "field"), "field pics")
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
  local picsets = get_picsets(fp)
  local expansions = get_expansions(fe)
  for _, exp in pairs(expansions) do
    for id, pscfg in pairs(picsets) do
      Logs.info("Exporting for ", id, " with ", exp)
      local out, zipname = get_output(outdir, exp, id)
      local zipfile = create_zip(out)
      add_scripts(zipname, zipfile)
      add_pics(zipname, zipfile, id, pscfg)
      add_expansion(zipfile, exp)
      zipfile:close()
    end
  end
  if not next(expansions) then
    Logs.warning("No expansion was found")
  elseif not next(picsets) then
    Logs.warning("No picset was found")
  else
    Logs.ok("Export complete!")
  end
end
