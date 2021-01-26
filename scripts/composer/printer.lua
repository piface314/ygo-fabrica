local path = require 'lib.path'
local Logs = require 'lib.logs'

local Printer = {}

local out, extension, width, height, field
local valid_exts = {jpg = true, png = true, jpeg = true}

local function set_out_folder(dir)
  out = dir or ''
  local success, err = path.mkdir(out)
  Logs.assert(success, err)
  if field then
    success, err = path.mkdir(path.join(out, 'field'))
    Logs.assert(success, err)
  end
end

local function set_size(size)
  local w, h = (type(size) == 'string' and size or ''):match('(%d*)[Xx](%d*)')
  width, height = tonumber(w), tonumber(h)
end

local function set_extension(ext)
  extension = ext and valid_exts[ext] and ext or 'jpg'
end

--- Configures how card pics should be printed
--- @param out_folder string
--- @param options table
function Printer.configure(out_folder, options)
  field = options.field
  set_out_folder(out_folder)
  set_size(options.size)
  set_extension(options.ext)
end

local function resize(img)
  if width and height then
    return img:resize(width / img:width(), {vscale = height / img:height()})
  elseif width then
    return img:resize(width / img:width())
  elseif height then
    return img:resize(height / img:height())
  else
    return img
  end
end

--- Prints a card pic
--- @param id string
--- @param pic Image
function Printer.print(id, pic)
  local fp = path.join(out, id .. '.' .. extension)
  resize(pic):write_to_file(fp)
end

--- Prints a card field backgound (for Field Spell Cards)
--- @param id string
--- @param pic Image
function Printer.print_field(id, pic)
  if not pic then return end
  local fp = path.join(out, 'field', id .. '.' .. extension)
  pic:write_to_file(fp)
end

return Printer
