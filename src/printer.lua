--- LuaFileSystem library
local fs = require "lfs"
--- LuaVips image manipulation library
local vips = require "vips"

--- Keeps settings about the output folders and prints results of cardpics
local Printer = {}

--- Output folder path
local out

--- Sets a new value for the output folder path, and creates its directory if necessary.
--  @param path New output path
--  @param noSub Option to not use a subfolder
function Printer.setOutputFolder(path, noSub)
    if path:match("[\\/]$") then path = path:sub(1, -2) end
    out = noSub and path or path .. "/out"
    local attr = fs.attributes(out)
    if not attr or attr.mode ~= 'directory' then
        fs.mkdir(out)
    end
end

--- Prints a card pic to the hard disk
--  @param id Card ID, used as the file name
--  @param cardpic Card pic processed by Vips library
function Printer.print(id, cardpic)
    cardpic:write_to_file(out .. "/" .. id .. ".png")
end

return Printer
