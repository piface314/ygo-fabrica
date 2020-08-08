

local Version = {
  number = "1.1.0",
  name = "artefato-astral"
}

function Version.formatted()
  return ("ygofabrica v%s %s"):format(Version.number, Version.name)
end

return Version
