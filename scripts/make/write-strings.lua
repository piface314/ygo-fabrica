local Logs = require 'lib.logs'
local i18n = require 'lib.i18n'
local fun = require 'lib.fun'

local STRING_KEYS = fun {setname = true, counter = true}
--- Reads a `string.conf` file and gets its content as a table
--- @param fp string
--- @return Fun
local function get_string_lines_from_file(fp)
  local src = io.open(fp)
  if not src then return end
  local lines = STRING_KEYS:map(fun '_ -> {}')
  for line in src:lines() do
    local key, code, val = line:match('^%s*!(%w+)%s+(0x%x+)%s*(.-)%s*$')
    code = tonumber(code)
    if lines(key) then
      lines(key)[code] = val
    end
  end
  src:close()
  return lines
end

local fmt_line = fun '... -> ("!%s 0x%04x %s\\n"):format(...)'
--- Formats the string lines as table into a proper single string
--- @param rlines table
--- @return string
local function fmt_lines(rlines)
  local wlines = fun {}
  for key, t in pairs(rlines) do
    for code, val in pairs(t) do
      wlines:push(fmt_line(key, code, val))
    end
  end
  return wlines:reduce('', fun 'a, s -> a .. s')
end

--- Reads a file and merges its string lines with `rlines`.
--- `rlines` overwrites values from the source file.
--- Returns a single formatted string
--- @param fp string
--- @param rlines Fun
--- @return string
local function merge_lines_with_file(fp, rlines)
  local f, wlines = io.open(fp), ''
  if f then
    wlines = fun(f:lines())
      :map(fun 'l -> {l, l:match("^%s*!(%w+)%s+(0x%x+).*$")}')
      :map(function(t)
        local line, key, code = t[1], t[2], tonumber(t[3])
        local val = rlines(key) and rlines(key)[code]
        if val then
          rlines(key)[code] = nil
          return fmt_line(key, code, val)
        else
          return line .. '\n'
        end
      end):reduce('', fun 'a, s -> a .. s')
    f:close()
  end
  return wlines .. fmt_lines(rlines)
end

--- Converts string data obtained from .toml files into an appropriate
--- table format
--- @param strings Fun
--- @return Fun
local function get_string_lines(strings)
  return strings:map(function(entries)
      return fun(entries):hashmap(fun 'e -> tonumber(e.code), e.name')
    end):filter(fun 'g -> next(g) ~= nil')
end

--- Merges the strings found in a source `strings.conf` file into a destination
--- `strings.conf` file
--- @param src_fp string
--- @param dst_fp string
--- @return boolean
local function merge_strings(src_fp, dst_fp)
  local rlines = get_string_lines_from_file(src_fp)
  if not rlines then return false end
  local wlines = merge_lines_with_file(dst_fp, rlines)
  local dst = io.open(dst_fp, 'w')
  if not dst then return false end
  dst:write(wlines)
  dst:close()
  return true
end

--- Writes strings obtained from .toml to a file, merging strings
--- if that file already exists. If `ow` (overwrite) is `true`,
--- then the while is overwritten instead of being merged.
--- @param fp string
--- @param strings Fun
--- @param ow any
local function write_strings(fp, strings, ow)
  local rlines = get_string_lines(strings)
  if not next(rlines) then return end
  local wlines = ow and fmt_lines(rlines) or merge_lines_with_file(fp, rlines)
  local dst = io.open(fp, 'w')
  if not dst then
    return Logs.warning(i18n 'make.writer.strings_fail')
  end
  Logs.info(i18n 'make.writer.strings')
  dst:write(wlines)
  dst:close()
end

return {
  merge = merge_strings,
  write = write_strings
}