local path = require 'lib.path'
local sqlite = require 'lsqlite3complete'
local Logs = require 'lib.logs'
local i18n = require 'lib.i18n'
local fun = require 'lib.fun'

local DataFetcher = {}

local valid_exts = {jpg = true, png = true, jpeg = true}
local function is_valid_ext(ext)
  return ext and valid_exts[ext:lower()]
end

local function get_images(fp)
  Logs.assert(fp and fp ~= '', i18n 'compose.data_fetcher.no_img_folder')
  return fun(path.each(fp .. path.DIR_SEP))
    :hashmap(function(f)
      local name, ext = path.basename(f):match('^(%d*)%.(.-)$')
      return is_valid_ext(ext) and name or nil, f
    end)
end

local function open_cdb(cdbfp)
  return sqlite.open(cdbfp)
end

local function read_cdb(cdb, imgs)
  Logs.assert(cdb and cdb:isopen(), i18n 'compose.data_fetcher.closed_db')
  local ids = table.concat(fun(imgs):keys(), ',')
  local sql = ([[SELECT t.id, name, desc, type, atk, def, level, race, attribute
  FROM texts AS t JOIN datas AS d ON t.id = d.id
  WHERE t.id IN (%s);]]):format(ids)
  local data = {}
  local code = cdb:exec(sql, function(_, _, vals)
    table.insert(data, {
      img = imgs[vals[1]],
      id = vals[1],
      name = vals[2] or '',
      desc = vals[3] or '',
      type = tonumber(vals[4]) or 0,
      atk = tonumber(vals[5]) or 0,
      def = tonumber(vals[6]) or 0,
      level = tonumber(vals[7]) or 0,
      race = tonumber(vals[8]) or 0,
      attribute = tonumber(vals[9]) or 0
    })
    return 0
  end)
  Logs.assert(code == 0, i18n 'compose.data_fetcher.read_db_fail')
  return data
end

function DataFetcher.get(imgfolder, cdbfp)
  local imgs = get_images(imgfolder)
  local cdb = open_cdb(cdbfp)
  local data = read_cdb(cdb, imgs)
  return data
end

return DataFetcher
