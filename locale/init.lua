local i18n = require 'i18n'
local path = require 'lib.path'

local LOCALE_ROOTFP = path.prjoin('locale')
local locales = {en = true, pt = true}

for locale in pairs(locales) do
  i18n.loadFile(path.join(LOCALE_ROOTFP, locale .. '.lua'))
end
i18n.setFallbackLocale('en')

return {
  get = i18n.getLocale,
  set = function(locale)
    if locales[locale] then
      i18n.setLocale(locale)
    end
  end
}
