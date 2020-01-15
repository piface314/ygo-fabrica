local vips = require 'vips'
local path = require 'path'
local Logs = require 'scripts.logs'
local fs = require 'lib.fs'


local Printer = {}

local out_folder, extension, width, height
local valid_exts = { jpg = true, png = true, jpeg = true }

function Printer.set_out_folder(dir)
  out_folder = dir or ""
  local success, err = fs.rmkdir(out_folder)
  Logs.assert(success, 1, err)
end

function Printer.set_size(size)
  local w, h = (type(size) == 'string' and size or ""):match("(%d*)[Xx](%d*)")
  width, height = tonumber(w), tonumber(h)
end

function Printer.set_extension(ext)
  extension = ext and valid_exts[ext] and ext or 'jpg'
end

local function resize(img)
  if width and height then
    return img:resize(width / img:width(), { vscale = height / img:height() })
  elseif width then
    return img:resize(width / img:width())
  elseif height then
    return img:resize(height / img:height())
  else
    return img
  end
end

function Printer.print(name, img)
  local fp = path.join(out_folder, name .. '.' .. extension)
  img = resize(img)
  img:write_to_file(fp)
end

return Printer
