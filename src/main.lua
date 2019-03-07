local DataFetch = require('src.data-fetch')
local args = { ... }
local testMode = args[1]

local Main = {}
function Main.imgs(_, imgFolder)
    for dir, id in DataFetch.imgIterator(imgFolder) do
        print(id)
    end
end

if Main[testMode] then Main[testMode](...) end
