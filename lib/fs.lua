--[[
Copyright © 2014 Ben "ToxicFrog" Kelly, Google Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

local fs = require 'lfs'


local windows = package.config:sub(1,1) == "\\"

-- We make the simplifying assumption in these functions that path separators
-- are always forward slashes. This is true on *nix and *should* be true on
-- windows, but you can never tell what a user will put into a config file
-- somewhere. This function enforces this.
function fs.normalize(path)
  if windows then
    return (path:gsub("\\", "/"))
  else
    return path
  end
end

local _attributes = fs.attributes
function fs.attributes(path, ...)
  path = fs.normalize(path)
  if windows then
    -- Windows stat() is kind of awful. If the path has a trailing slash, it
    -- will always fail. Except on drive root directories, which *require* a
    -- trailing slash. Thankfully, appending a "." will always work if the
    -- target is a directory; and if it's not, failing on paths with trailing
    -- slashes is consistent with other OSes.
    path = path:gsub("/$", "/.")
  end

  return _attributes(path, ...)
end

function fs.exists(path)
  return fs.attributes(path, "mode") ~= nil
end

function fs.dirname(oldpath)
  local path = fs.normalize(oldpath):gsub("[^/]+/*$", "")
  if path == "" then
    return oldpath
  end
  return path
end

-- Recursive directory creation a la mkdir -p. Unlike lfs.mkdir, this will
-- create missing intermediate directories, and will not fail if the
-- destination directory already exists.
-- It assumes that the directory separator is '/' and that the path is valid
-- for the OS it's running on, e.g. no trailing slashes on windows -- it's up
-- to the caller to ensure this!
function fs.rmkdir(path)
  path = fs.normalize(path)
  if fs.exists(path) then
    return true
  end
  if fs.dirname(path) == path then
    -- We're being asked to create the root directory!
    return nil,"mkdir: unable to create root directory"
  end
  local r,err = fs.rmkdir(fs.dirname(path))
  if not r then
    return nil,err.." (creating "..path..")"
  end
  return fs.mkdir(path)
end

return fs
