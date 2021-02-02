local ZipWriter = require 'ZipWriter'
local path = require 'lib.path'

---@class Zip
---@field write function
---@field close function
local Zip = {}

local READER_DESC = {
  istext = true,
  isfile = true,
  isdir = false,
  exattrib = {
    ZipWriter.NIX_FILE_ATTR.IFREG, ZipWriter.NIX_FILE_ATTR.IRUSR,
    ZipWriter.NIX_FILE_ATTR.IWUSR, ZipWriter.NIX_FILE_ATTR.IRGRP,
    ZipWriter.DOS_FILE_ATTR.ARCH
  }
}

--- Creates a new .zip file in the specified filepath.
--- Returns nil and an error message if it's unable to open the file.
--- @param fp string file path
--- @return Zip?, string?
function Zip.new(fp)
  local zipfile = ZipWriter.new()
  local f, errmsg = io.open(fp, 'w+b')
  if not f then
    return nil, errmsg
  end
  zipfile:open_stream(f, true)
  zipfile.add = Zip.add
  return zipfile
end

local function reader(fp)
  local f, errmsg = io.open(fp, 'rb')
  if not f then
    return nil, errmsg
  end
  return function()
    local chunk = f:read(1024)
    if chunk then return chunk end
    f:close()
  end
end

--- Adds a source file to a destination path inside the zip.
--- @param src_fp string source file path
--- @param dst_fp string destination file path
--- @return boolean, string? errmsg
function Zip:add(src_fp, dst_fp)
  if path.isfile(src_fp) then
    local r, errmsg = reader(src_fp)
    if not r then
      return false, errmsg
    end
    self:write(dst_fp, READER_DESC, r)
    return true
  elseif path.isdir(src_fp) then
    for nfp in path.each(src_fp .. path.DIR_SEP) do
      local ok, e = self:add(nfp, path.join(dst_fp, path.basename(nfp)))
      if not ok then return ok, e end
    end
    return true
  else
    return false
  end
end

return Zip
