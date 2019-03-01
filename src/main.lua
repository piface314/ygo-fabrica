local DataFetch = require('src.data-fetch')
local args = { ... }
local testMode = args[1]

local Main = {}
function Main.df(_, imgFolder)
    for img, attr in DataFetch.iterator(imgFolder) do
        print(img)
    end
end

if Main[testMode] then Main[testMode](...) end
