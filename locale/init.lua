local i18n = require 'lib.i18n'
local s, fs = pcall(require, 'lib.fs')

local LOCALE_ROOTFP = s and fs.path.prjoin('locale') or './locale'
local locales = {en = true, pt = true}

for locale in pairs(locales) do
  i18n.loadFile(LOCALE_ROOTFP .. '/' .. locale .. '.lua')
end
i18n.setFallbackLocale('en')

return {
  set = function(locale)
    if locales[locale] then
      i18n.setLocale(locale)
    end
  end,
  list = locales
}
