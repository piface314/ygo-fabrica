local ZipWriter = require 'ZipWriter'

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

function Zip:add(src_fp, dst_fp)
  local r, errmsg = reader(src_fp)
  if not r then
    return false, errmsg
  end
  self:write(dst_fp, READER_DESC, r)
  return true
end

return Zip
