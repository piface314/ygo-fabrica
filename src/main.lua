local DataFetch = require "src.data-fetch"
local Decoder = require "src.decoder"
local args = { ... }
local mode = args[1]
local imgFolder = args[2]
local cdbPath = args[3]

io.write(("Mode: -- %s --\n"):format(mode))
io.write(("Opening card database %q...\n"):format(cdbPath))
local cdb = DataFetch.openCDB(cdbPath)
for imgPath, id in DataFetch.imgIterator(imgFolder) do
    print("---")
    io.write(("Reading card %q...\n"):format(id))
    local data = DataFetch.rowRead(cdb, id)
    io.write(("Decoding card %q...\n"):format(id))
    Decoder(mode, imgPath, data)
end

print("---")
cdb:close()
