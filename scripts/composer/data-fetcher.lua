local path = require 'lib.path'
local sqlite = require 'lsqlite3complete'
local Logs = require 'lib.logs'
local i18n = require 'lib.i18n'
local fun = require 'lib.fun'

--- Reads data from a card database (.cdb file)
local DataFetcher = {}

local ESC_REPL = fun {['<'] = '&lt;', ['>'] = '&gt;', ['&'] = '&amp;'}
local ESC_CHAR = '[' .. table.concat(ESC_REPL:keys()) .. ']'
--- Returns a copy of a string with escaped characters that could conflitct
--- with Pango markup. (Pango is the text rendering lib used by vips)
--- @param text string
--- @return string
local function escape(text) return (text:gsub(ESC_CHAR, ESC_REPL)) end

local VALID_EXT = {jpg = true, png = true, jpeg = true}
--- Checks if a file extension is a valid image extension.
--- @param ext string
--- @return boolean
local function is_valid_ext(ext)
  return ext and VALID_EXT[ext:lower()]
end

--- Reads a folder looking for image files and returns a table whose keys are
--- the image name without the extension (i.e., card id), and whose values are
--- the whole image file path.
--- @param fp string
--- @return Fun imgs
local function get_images(fp)
  Logs.assert(fp and fp ~= '', i18n 'compose.data_fetcher.no_img_folder')
  return fun(path.each(fp .. path.DIR_SEP))
    :hashmap(function(f)
      local id, ext = path.basename(f):match('^(%d*)%.(.-)$')
      return is_valid_ext(ext) and id or nil, f
    end)
end

local SELECT_TEMPLATE = [[SELECT *
  FROM texts AS t JOIN datas AS d ON t.id = d.id
  WHERE t.id IN (%s)]]
--- Reads data from a card database (.cdb file), looking for ids
--- that match those of the images found previously on a folder.
--- @param cdb Database
--- @param imgs Fun
--- @return Fun cards
local function read_cdb(cdb, imgs)
  Logs.assert(cdb and cdb:isopen(), i18n 'compose.data_fetcher.closed_db')
  local ids = table.concat(imgs:keys(), ',')
  local sql = SELECT_TEMPLATE:format(ids)
  local function read()
    local rows = fun {}
    for row in cdb:nrows(sql) do
      row.id = tostring(row.id)
      row.art = imgs[row.id]
      row.name = escape(row.name or '')
      row.desc = escape(row.desc or '')
      rows:push(row)
    end
    return rows
  end
  local s, cards = pcall(read)
  Logs.assert(s, i18n 'compose.data_fetcher.read_db_fail', s and '' or cards)
  return cards
end

--- @alias CardData table<string, string|number>

--- Reads data from a card database (.cdb file)
--- @param imgfolder string
--- @param cdbfp string
--- @return Fun cards
function DataFetcher.get(imgfolder, cdbfp)
  local imgs = get_images(imgfolder)
  local cdb = sqlite.open(cdbfp)
  local cards = read_cdb(cdb, imgs)
  return cards
end

return DataFetcher
