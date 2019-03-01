--LuaFileSystem library
local fs = require('lfs')

--Data fetching module, to get input image folder and card database file
local DataFetch = {}

function DataFetch.iterator(imgs)
    assert(imgs and imgs ~= "", "Please provide an image folder parameter")
    if string.sub(imgs, -1) == "/" then
        imgs = string.sub(imgs, 1, -2)
    end

    local function yielddir(dir)
        for entry in fs.dir(dir) do
            if entry ~= "." and entry ~= ".." then
                entry = dir.."/"..entry
                coroutine.yield(entry)
            end
        end
    end

    return coroutine.wrap(function() yielddir(imgs) end)
end

return DataFetch
