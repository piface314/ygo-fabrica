local path = require 'lib.path'
local Logs = require 'lib.logs'

local Printer = {}

local out_folder, extension, width, height, field
local valid_exts = {jpg = true, png = true, jpeg = true}

local function set_out_folder(dir)
  out_folder = dir or ''
  local success, err = path.mkdir(out_folder)
  Logs.assert(success, err)
  if field then
    success, err = path.mkdir(path.join(out_folder, 'field'))
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

function Printer.configure(out_folder, opt)
  field = opt.field
  set_out_folder(out_folder)
  set_size(opt.size)
  set_extension(opt.ext)
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

function Printer.print(id, img)
  local fp = path.join(out_folder, id .. '.' .. extension)
  resize(img):write_to_file(fp)
end

function Printer.print_field(id, pic)
  if not pic then return end
  local fp = path.join(out_folder, 'field', id .. '.' .. extension)
  pic:write_to_file(fp)
end

return Printer
