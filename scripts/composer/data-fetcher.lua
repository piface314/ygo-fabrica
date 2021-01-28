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

local function get_custom_cols(cdb)
  local cols = {}
  for col in cdb:nrows 'PRAGMA table_info(custom)' do
    cols[col.name] = true
  end
  return cols
end

local SELECT_TEMPLATE = 'SELECT * FROM %s WHERE id IN (%s)'
--- Reads data from a card database (.cdb file), looking for ids
--- that match those of the images found previously on a folder.
--- @param cdbfp string path to a .cdb file
--- @param imgs Fun
--- @return Fun cards
local function read_cdb(cdbfp, imgs)
  local cdb = sqlite.open(cdbfp)
  Logs.assert(cdb and cdb:isopen(), i18n 'compose.data_fetcher.closed_db')
  local ids = table.concat(imgs:keys(), ',')
  local sql = SELECT_TEMPLATE:format('texts NATURAL JOIN datas', ids)
  local function read()
    local custom_cols = get_custom_cols(cdb)
    local cards = {}
    for row in cdb:nrows(sql) do
      row.id = tostring(row.id)
      row.art = imgs[row.id]
      row.name = escape(row.name or '')
      row.desc = escape(row.desc or '')
      cards[row.id] = row
    end
    if next(custom_cols) then
      for row in cdb:nrows(SELECT_TEMPLATE:format('custom', ids)) do
        for col in pairs(custom_cols) do
          local id, v = tostring(row.id), row[col]
          cards[id][col] = type(v) == 'string' and escape(v) or v
        end
      end
    end
    cdb:close()
    return cards
  end
  local s, cards = pcall(read)
  Logs.assert(s, i18n 'compose.data_fetcher.read_db_fail', s and '' or cards)
  return fun(cards):vals():sort(fun 'a, b -> a.id < b.id')
end

--- @alias CardData table<string, string|number>

--- Reads data from a card database (.cdb file)
--- @param imgfolder string
--- @param cdbfp string
--- @return Fun cards
function DataFetcher.get(imgfolder, cdbfp)
  local imgs = get_images(imgfolder)
  local cards = read_cdb(cdbfp, imgs)
  return cards
end

return DataFetcher
