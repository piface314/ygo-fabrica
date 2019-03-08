local DataFetch = require "src.data-fetch"
local Decoder = require "src.decoder"
local Assembler = require "src.assembler"
local TextRender = require "src.text-renderer"
local Printer = require "src.printer"

local args = { ... }
local mode = args[1]
local imgFolder = args[2]
local cdbPath = args[3]

assert(mode == 'anime', ("Error: Unavailable mode %q"):format(mode))
io.write(("Mode: -- %s --\n"):format(mode))
io.write(("Opening card database %q...\n"):format(cdbPath))
Printer.setOutputFolder(imgFolder)
local cdb = DataFetch.openCDB(cdbPath)
for imgPath, id in DataFetch.imgIterator(imgFolder) do
    print("---\n")
    io.write(("Reading card %q...\n"):format(id))
    local data = DataFetch.rowRead(cdb, id)
    if data then
        io.write(("Decoding card %q...\n"):format(id))
        local layers = Decoder(mode, data)
        for i, l in ipairs(layers) do print("Layer " .. i, l) end
        io.write(("Assembling card %q...\n"):format(data.name))
        local pic = Assembler(mode, data, imgPath, layers)
        io.write(("Printing card %q to %q...\n"):format(data.name,
            Printer.getOutputFolder() .. "/" .. id .. ".png"))
        Printer.print(id, pic)
    else
        print("No data! Skipping...")
    end
    print()
end

print("---")
cdb:close()
