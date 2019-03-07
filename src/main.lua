local DataFetch = require "src.data-fetch"
local Decoder = require "src.decoder"
local args = { ... }
local testMode = args[1]

local Main = {}
function Main.imgs(_, imgFolder)
    for dir, id in DataFetch.imgIterator(imgFolder) do
        print(dir, id)
    end
end

function Main.dc(_)
    Decoder(5, 2)
end

if Main[testMode] then Main[testMode](...) end
