local path = require 'lib.path'
local sqlite = require 'lsqlite3complete'
local Logs = require 'lib.logs'
local i18n = require 'i18n'
local fun = require 'lib.fun'

---Reads data from a card database (.cdb file)
local DataFetcher = {}

---@alias CardData table<string, string|number>

local ESC_REPL = {['<'] = '&lt;', ['>'] = '&gt;', ['&'] = '&amp;'}
local ESC_CHAR = '[' .. table.concat(fun.iter(ESC_REPL):totable()) .. ']'

---Returns a copy of a string with escaped characters that could conflitct
---with Pango markup. (Pango is the text rendering lib used by vips)
---@param text string
---@return string
local function escape(text) return (text:gsub(ESC_CHAR, ESC_REPL)) end

local VALID_EXT = {jpg = true, png = true, jpeg = true}
---Checks if a file extension is a valid image extension.
---@param ext string
---@return boolean
local function is_valid_ext(ext)
  return ext and VALID_EXT[ext:lower()]
end

---Reads a folder looking for image files and returns a table whose keys are
---the image name without the extension (i.e., card id), and whose values are
---the whole image file path.
---@param fp string
---@return string[]
local function get_images(fp)
  Logs.assert(fp and fp ~= '', i18n 'compose.data_fetcher.no_img_folder')
  return fun.iter(path.each(fp .. path.DIR_SEP))
    :map(function(f)
      local id, ext = path.basename(f):match('^(%d*)%.(.-)$')
      if not (id and is_valid_ext(ext)) then return false end
      return id, f
    end):tomap()
end

---Retrieves custom table column names from .cdb
---@param cdb Database
---@return table<string,boolean>
local function get_custom_cols(cdb)
  return fun.iter(cdb:nrows 'PRAGMA table_info(custom)')
    :map(function(col) return col.name, true end)
    :tomap()
end

local SELECT_TEMPLATE = 'SELECT * FROM %s WHERE id IN (%s)'
---Reads data from a card database (.cdb file), looking for ids
---that match those of the images found previously on a folder.
---@param cdbfp string path to a .cdb file
---@param imgs table<string,string>
---@return CardData[] cards
local function read_cdb(cdbfp, imgs)
  local cdb = sqlite.open(cdbfp)
  Logs.assert(cdb and cdb:isopen(), i18n 'compose.data_fetcher.closed_db')
  local ids = table.concat(fun.iter(imgs):totable(), ',')
  local sql = SELECT_TEMPLATE:format('texts NATURAL JOIN datas', ids)
  local s, cards = pcall(function()
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
  end)
  Logs.assert(s, i18n 'compose.data_fetcher.read_db_fail', s and '' or cards)
  cards = fun.iter(cards):map(function(_, c) return c end):totable()
  return table.sort(cards, function(a, b) return a.id < b.id end)
end

---Reads data from a card database (.cdb file)
---@param imgfolder string
---@param cdbfp string
---@return CardData[] cards
function DataFetcher.get(imgfolder, cdbfp)
  local imgs = get_images(imgfolder)
  local cards = read_cdb(cdbfp, imgs)
  return cards
end

return DataFetcher
