--[[ @require LuaFileSystem library ]]
local fs = require('lfs')
--[[ @require LuaSQLite3 library]]
local sqlite = require('lsqlite3complete')

--[[ @module Reads input image folder and card database file ]]
local DataFetch = {}

--[[
    Iterator to find all images in a folder
    @param imgs Path for the folder containing the card images
]]
function DataFetch.imgIterator(imgs)
    assert(imgs and imgs ~= "", "Please provide an image folder parameter")
    if imgs:sub(-1) == "/" then imgs = imgs:sub(1, -2) end
    local function yielddir(dir)
        local imgFmt = { png = true, jpg = true, jpeg = true }
        for entry in fs.dir(dir) do
            if entry ~= "." and entry ~= ".."
                and imgFmt[entry:lower():match("%.(.*)$")] then
                entry = dir.."/"..entry
                coroutine.yield(entry, entry:match(".*/(.-)%..*$"))
            end
        end
    end
    return coroutine.wrap(function() yielddir(imgs) end)
end

--[[
    Reads a row from a card database by its ID, and returns its relevant data
    @param cdb Card database file
    @param id Card ID
    @return A table containing relevant data about the card (ID, name, desc, type, atk, def, level, race, attribute), or nil if the row does not exist
]]
function DataFetch.rowRead(cdb, id)
    assert(cdb and cdb.isopen and cdb:isopen(), "Nil or closed card database")
    local row
    cdb:exec(('SELECT * FROM texts WHERE id = %s;'):format(id), function (_, _, vals)
        row = { id = vals[1], name = vals[2], desc = vals[3] }
        return 0
    end)
    cdb:exec(('SELECT * FROM datas WHERE id = %s;'):format(id), function (_, _, vals)
        if row then
            row.type = vals[5]
            row.atk = vals[6]
            row.def = vals[7]
            row.level = vals[8]
            row.race = vals[9]
            row.attribute = vals[10]
        end
        return 0
    end)
    return row
end

function DataFetch.cdbRead(cdbPath)

end

return DataFetch
