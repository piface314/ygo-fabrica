local version = _VERSION:match("%d+%.%d+")
package.path = 'lua-modules/share/lua/' .. version .. '/?.lua;lua-modules/share/lua/' .. version .. '/?/init.lua;' .. package.path
package.cpath = 'lua-modules/lib/lua/' .. version .. '/?.so;' .. package.cpath