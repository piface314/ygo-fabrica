local path = require 'path'
local Logs = require 'scripts.logs'
local Config = require 'scripts.config'


local insert = table.insert

local PWD

local function get_gamedirs(flag_g)
  local all = flag_g and not flag_g[1]
  local gamedir = flag_g and flag_g[1]
  if all then
    return Config.get_all(PWD, 'gamedir')
  elseif gamedir then
    local gd = Config.get_one(PWD, 'gamedir', gamedir)
    Logs.assert(gd, 1, "Gamedir \"", gamedir, "\" is not configured.")
    return { [gamedir] = gd }
  else
    return Config.get_defaults(PWD, 'gamedir')
  end
end

local function get_picset(flag_p)
  local picset = flag_p and flag_p[1]
  if picset then
    local ps = Config.get_one(PWD, 'picset', picset)
    Logs.assert(ps, 1, "Pic set \"", picset, "\" is not configured.")
    return picset, ps
  else
    local id, ps = Config.get_default(PWD, 'picset')
    Logs.assert(id, 1,
      "Please specify a picset using `-p <picset>` or define a default picset.")
    return id, ps
  end
end

local function clean(dir, names)
  for entry in lfs.dir(dir) do
    local name = entry:match("^(.*)%.") or entry
    if names[name] then
      os.remove(path.join(dir, entry))
    end
  end
end

local function cp(src, dst)
  local fsrc = io.open(src, "rb")
  if not fsrc then
    return 0
  end
  local fdst = io.open(dst, "wb")
  if not fdst then
    return 0
  end
  fdst:write(fsrc:read("*a"))
  fsrc:close()
  fdst:close()
  return 1
end

local function copy_dir(pattern, src, dst, fclean, tags)
  local function cpd()
    local to_copy, to_clean = {}, {}
    local copied, total = 0, 0
    for entry in lfs.dir(src) do
      if entry:match(pattern) then
        insert(to_copy, entry)
        total = total + 1
        if fclean then
          to_clean[entry:match("^(.*)%.") or entry] = true
        end
      end
    end
    if fclean then
      clean(dst, to_clean)
    end
    for _, file in ipairs(to_copy) do
      copied = copied + cp(path.join(src, file), path.join(dst, file))
    end
    return copied, total
  end
  local s, copied, total = pcall(cpd)
  if s then
    Logs.info(("%d out of %d %s copied for %q"):format(copied, total, tags[1], tags[2]))
    if copied == 0 then
      Logs.warning("No ", tags[1]," copied for this gamedir. Something seems wrong...")
    end
  else
    Logs.warning(("Failed while copying %s for %q:\n"):format(tags[1], tags[2]), copied)
  end
end

local function copy_scripts(gamedir, gpath, fclean)
  copy_dir("c%d+%.lua", path.join(PWD, "script"),
    path.join(gpath, "script"), fclean, { "scripts", gamedir })
end

local function copy_pics(gamedir, gpath, picset, pscfg, fclean)
  copy_dir("%d+%." .. pscfg.ext, path.join(PWD, "pics", picset),
    path.join(gpath, "pics"), fclean, { "pics", gamedir })
  if pscfg.field then
    copy_dir("%d+%." .. pscfg.ext, path.join(PWD, "pics", picset, "field"),
      path.join(gpath, "pics", "field"), fclean, { "field pics", gamedir })
  end
end

local function copy_expansion(gamedir, gpath)
  local _, pack_name = path.split(PWD)
  local expansion = pack_name .. ".cdb"
  local src = path.join(PWD, expansion)
  local dst = path.join(gpath, "expansions", expansion)
  if cp(src, dst) == 1 then
    Logs.info("Copied expansion for \"", gamedir, '"')
  else
    Logs.warning("Failed to copy expansion")
  end
end

return function(pwd, flags)
  PWD = pwd
  local fg, fp, fclean = flags['-Gall'] or flags['-g'], flags['-p'], flags['--clean']
  local no_script = flags['--no-script']
  local no_pics = flags['--no-pics']
  local no_exp = flags['--no-exp']
  local gamedirs = get_gamedirs(fg)
  local picset, pscfg
  if not no_pics then
    picset, pscfg = get_picset(fp)
  end
  for gd, gdcfg in pairs(gamedirs) do
    if not no_script then copy_scripts(gd, gdcfg.path, fclean) end
    if not no_pics then copy_pics(gd, gdcfg.path, picset, pscfg, fclean) end
    if not no_exp then copy_expansion(gd, gdcfg.path) end
  end
  Logs.ok("Sync complete!")
end
