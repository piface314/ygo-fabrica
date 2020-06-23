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
local path = require 'path'
fs.path = setmetatable({}, { __index = path })

local windows = package.config:sub(1,1) == "\\"

--- Enforces path separators are forware slashes, `/`.
--- We make the simplifying assumption in these functions that path separators
--- are always forward slashes. This is true on \*nix and *should* be true on
--- windows, but you can never tell what a user will put into a config file
--- somewhere.
--- @param path string
function fs.path.normalize(path)
  -- Windows stat() is kind of awful. If the path has a trailing slash, it
  -- will always fail. Except on drive root directories, which *require* a
  -- trailing slash. Thankfully, appending a "." will always work if the
  -- target is a directory; and if it's not, failing on paths with trailing
  -- slashes is consistent with other OSes.
  return windows and path:gsub("\\", "/"):gsub("/$", "/.") or path
end

local _attributes = fs.attributes
function fs.attributes(path, ...)
  path = fs.path.normalize(path)
  return _attributes(path, ...)
end

--- Checks if a file or directory exists on the given `path`
--- @param path string
--- @return boolean
function fs.exists(path)
  return fs.attributes(path, "mode") ~= nil
end

--- Gets the name of the parent directory of a path.
--- Similar to the first return value of `fs.path.split`, but removes
--- trailing slashes.
--- @param oldpath string
--- @return string
function fs.path.dirname(oldpath)
  local path = fs.path.normalize(oldpath):gsub("[^/]+/*$", "")
  if path == "" then
    return oldpath
  end
  return path
end

--- Recursive directory creation a la `mkdir -p`. Unlike `lfs.mkdir`, this will
--- create missing intermediate directories, and will not fail if the
--- destination directory already exists.
--- It assumes that the directory separator is `/` and that the path is valid
--- for the OS it's running on, e.g. no trailing slashes on windows -- it's up
--- to the caller to ensure this!
--- @param path string
--- @return boolean success
--- @return nil|string errmsg
function fs.rmkdir(path)
  path = fs.path.normalize(path)
  if fs.exists(path) then
    return true
  end
  if fs.path.dirname(path) == path then
    -- We're being asked to create the root directory!
    return false, "mkdir: unable to create root directory"
  end
  local r, err = fs.rmkdir(fs.path.dirname(path))
  if not r then
    return false, err .. " (creating " .. path .. ")"
  end
  return fs.mkdir(path)
end

local program_root = ""
--- Sets the program root folder path to `proot`
--- @param proot string
function fs.path.setproot(proot)
  program_root = proot or ""
end

--- Returns the program root folder path
--- @return string program_root
function fs.path.getproot()
  return program_root
end

--- Joins strings into a path, relative to the **p**rogram **r**oot folder
--- @return string path
function fs.path.prjoin(...)
  return fs.path.join(program_root, ...)
end

fs.path.setproot(os.getenv('YGOFAB_ROOT'))

return fs
