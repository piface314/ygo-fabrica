local DataFetch = require('src.data-fetch')
local args = { ... }
local testMode = args[1]

local Main = {}
function Main.imgs(_, imgFolder)
    for dir, id in DataFetch.imgIterator(imgFolder) do
        print(id)
    end
end

function Main.row(_, cdbPath, id)
    local sqlite = require('lsqlite3complete')
    local cdb = sqlite.open(cdbPath)
    for k, v in pairs(DataFetch.rowRead(cdb, id)) do
        print(k, v)
    end
    cdb:close()
end

if Main[testMode] then Main[testMode](...) end
