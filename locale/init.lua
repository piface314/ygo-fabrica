local i18n = require 'i18n'
local path = require 'lib.path'

local locales = {en = true, pt = true}

for locale in pairs(locales) do
  i18n.loadFile(path.prjoin('locale', locale .. '.lua'))
end
if path.exists(path.gcjoin('locale')) then
  for fp in path.each(path.gcjoin('locale', '*.lua')) do
    i18n.loadFile(fp)
  end
end
i18n.setFallbackLocale('en')

return {
  get = i18n.getLocale,
  set = function(locale)
    i18n.setLocale(locale or i18n.getLocale() or i18n.getFallbackLocale())
  end
}
