local path = require 'path'
local Logs = require 'scripts.logs'
local Config = require 'scripts.config'


local insert = table.insert

local PWD

local function get_gamedirs(local_cfg, global_cfg, flag_g)
  local gamedirs = {}
  local all = flag_g and not flag_g[1]
  local g = flag_g and flag_g[1]
  local cfg = {}
  Config.merge(cfg, global_cfg)
  Config.merge(cfg, local_cfg)
  for id, gd in pairs(cfg.gamedir) do
    if all or ((g and id == g) or (not g and gd.default)) then
      insert(gamedirs, { id, gd.path })
    end
  end
  return gamedirs
end

local function get_picset(local_cfg, global_cfg, flag_p)
  local picset = flag_p and flag_p[1]
  if picset then
    local lps, gps = local_cfg[picset], global_cfg[picset]
    Logs.assert(lps or gps, 1, 'Pic set "', picset, '"', "is not configured.")
    return picset, lps or gps
  else
    local function search(t)
      for id, ps in pairs(t) do
        if ps.default then return id, ps end
      end
      return nil
    end
    local picset, pscfg = search(local_cfg.picset)
    if picset then
      return picset, pscfg
    else
      picset, pscfg = search(global_cfg.picset)
      Logs.assert(picset, 1,
        "Please specify a picset using `-p <picset>` or define a default picset.")
      return picset, pscfg
    end
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
    local copied = 0
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
    Logs.warning(("Failed while copying scripts for %q:\n"):format(tags[2]), copied)
  end
end

local function copy_scripts(gamedir, fclean)
  copy_dir("c%d+%.lua", path.join(PWD, "script"),
    path.join(gamedir[2], "script"), fclean, { "scripts", gamedir[1] })
end

local function copy_pics(gamedir, picset, pscfg, fclean)
  copy_dir("%d+%." .. pscfg.ext, path.join(PWD, "pics", picset),
    path.join(gamedir[2], "pics"), fclean, { "pics", gamedir[1] })
  if pscfg.field then
    copy_dir("%d+%." .. pscfg.ext, path.join(PWD, "pics", picset, "field"),
      path.join(gamedir[2], "pics", "field"), fclean, { "field pics", gamedir[1] })
  end
end

local function copy_expansion(gamedir)
  local _, pack_name = path.split(PWD)
  local expansion = pack_name .. ".cdb"
  local src = path.join(PWD, expansion)
  local dst = path.join(gamedir[2], "expansions", expansion)
  if cp(src, dst) == 1 then
    Logs.info("Copied expansion for \"", gamedir[1], '"')
  else
    Logs.warning("Failed to copy expansion")
  end
end

return function(pwd, flags)
  PWD = pwd
  local local_cfg, global_cfg = Config.get(pwd, true)
  local fg, fp, fclean = flags['-Gall'] or flags['-g'], flags['-p'], flags['--clean']
  local no_script = flags['--no-script']
  local no_pics = flags['--no-pics']
  local no_exp = flags['--no-exp']
  local gamedirs = get_gamedirs(local_cfg, global_cfg, fg)
  local picset, pscfg = get_picset(local_cfg, global_cfg, fp)
  for _, gamedir in ipairs(gamedirs) do
    if not no_script then copy_scripts(gamedir, fclean) end
    if not no_pics then copy_pics(gamedir, picset, pscfg, fclean) end
    if not no_exp then copy_expansion(gamedir) end
  end
  Logs.ok("Sync complete!")
end
