

local Version = {
  number = "",
  name = ""
}

function Version.formatted()
  return ("ygofabrica v%s %s"):format(Version.number, Version.name)
end

return Version
