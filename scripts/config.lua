local format = require 'scripts.config.format'
local Config = require 'scripts.config.values'

setmetatable(Config, {
  __call = function()
    format(Config.load())
  end
})

return Config