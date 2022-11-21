local Version = {number = '2.1.0', name = 'cronomalia-cromatica'}

function Version.formatted()
  return ('ygofabrica v%s %s'):format(Version.number, Version.name)
end

return Version
