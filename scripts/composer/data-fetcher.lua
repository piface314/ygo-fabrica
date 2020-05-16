local fs = require 'lib.fs'
local path = fs.path
local sqlite = require 'lsqlite3complete'
local Logs = require 'lib.logs'


local DataFetcher = {}

local insert = table.insert
local concat = table.concat

local valid_exts = { jpg = true, png = true, jpeg = true }
local function is_valid_ext(ext)
  return ext and valid_exts[ext:lower()]
end

local function get_images(imgfolder)
  Logs.assert(imgfolder and imgfolder ~= "", 1, "No image folder parameter")
  local imgs = {}
  for entry in fs.dir(imgfolder) do
    local name, ext = entry:match("^(%d*)%.(.-)$")
    if is_valid_ext(ext) then
      imgs[name] = path.join(imgfolder, entry)
    end
  end
  return imgs
end

local function open_cdb(cdbfp)
  return sqlite.open(cdbfp)
end

local function keylist(t)
  local l = {}
  for k in pairs(t) do
    insert(l, k)
  end
  return l
end

local function read_cdb(cdb, imgs)
  Logs.assert(cdb and cdb:isopen(), 1, "Nil or closed card database")
  local ids = concat(keylist(imgs), ",")
  local sql = ([[SELECT t.id, name, desc, type, atk, def, level, race, attribute
  FROM texts AS t JOIN datas AS d ON t.id = d.id
  WHERE t.id IN (%s);]]):format(ids)
  local data = {}
  local code = cdb:exec(sql, function(_, _, vals)
    insert(data, {
      img = imgs[vals[1]],
      id = vals[1],
      name = vals[2] or "",
      desc = vals[3] or "",
      type = tonumber(vals[4]) or 0,
      atk = tonumber(vals[5]) or 0,
      def = tonumber(vals[6]) or 0,
      level = tonumber(vals[7]) or 0,
      race = tonumber(vals[8]) or 0,
      attribute = tonumber(vals[9]) or 0
    })
    return 0
  end)
  Logs.assert(code == 0, code, "Failed to read .cdb")
  return data
end

function DataFetcher.get(imgfolder, cdbfp)
  local imgs = get_images(imgfolder)
  local cdb = open_cdb(cdbfp)
  local data = read_cdb(cdb, imgs)
  return data
end

return DataFetcher
