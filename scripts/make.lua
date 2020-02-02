local toml = require 'toml'


return function(pwd, flags, ...)
  t = toml.parse([[
[card.fool]
name = "Arcana Force 0 - The Fool"

[card.magician]
name = "Arcana Force I - The Magician"

[card.fool]
set = "arcana-force"
]])
  for k, v in pairs(t) do
    print(k)
    for k, v in pairs(v) do
      print("", k)
      for k, v in pairs(v) do
        print("","",k, v)
      end
    end
  end
end
