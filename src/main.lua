local DataFetch = require "src.data-fetch"
local Decoder = require "src.decoder"
local Assembler = require "src.assembler"
local TextRender = require "src.text-renderer"
local Printer = require "src.printer"

local args = { ... }
local mode = args[1]
local imgFolder = args[2]
local cdbPath = args[3]
local noSub = args[4] == 'true'
local verbose = args[5] == 'true'
local clean = args[6] == 'true'
local setOut = args[7]

assert(mode == 'anime', ("Error: Unavailable mode %q"):format(mode))
if verbose then io.write(("Mode: -- %s --\n"):format(mode)) end
if verbose then io.write(("Opening card database %q...\n"):format(cdbPath)) end
Printer.setOutputFolder(setOut or imgFolder, noSub)
local out = Printer.getOutputFolder()
local cdb = DataFetch.openCDB(cdbPath)
for imgPath, id in DataFetch.imgIterator(imgFolder) do
    repeat
        if verbose then print("---\n") end
        if verbose then io.write(("Reading card %q...\n"):format(id)) end
        local data, msg = DataFetch.rowRead(cdb, id)
        if not data then
            if verbose then io.write(("Error: %s.\nSkipping %q...\n"):format(msg, id)) end
            break
        end
        if verbose then io.write(("Decoding card %q...\n"):format(id)) end
        local layers, msg = Decoder(mode, data)
        if not layers then
            if verbose then io.write(("Error: %s.\nSkipping %q...\n"):format(msg, id)) end
            break
        end
        if verbose then
            for i, l in ipairs(layers) do print("Layer " .. i, l) end
            io.write(("Assembling card %q...\n"):format(data.name))
        end
        local pic = Assembler(mode, data, imgPath, layers)
        if verbose then
            io.write(("Printing card %q to %q...\n"):format(data.name,
                out .. "/" .. id .. ".jpg"))
        end
        Printer.print(id, pic)
    until true
    if verbose then print() end
end
if verbose then print("---") end
cdb:close()
