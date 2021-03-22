local Version = {number = '2.0.0', name = 'barian-babelico'}

function Version.formatted()
  return ('ygofabrica v%s %s'):format(Version.number, Version.name)
end

return Version
