local WIN = package.config:sub(1, 1) == '\\'

return {
  version = '2.0.1',
  version_name = 'barian-babelico',
  install_path = WIN and os.getenv('LOCALAPPDATA') .. '\\YGOFabrica'
                      or os.getenv('HOME')         .. '/.local/ygofab',
  bin_path     = WIN and os.getenv('LOCALAPPDATA') .. '\\YGOFabrica'
                      or os.getenv('HOME')         .. '/.local/bin',
  config_path  = WIN and os.getenv('APPDATA')      .. '\\YGOFabrica'
                      or os.getenv('HOME')         .. '/.config/ygofab',
  rocks_tree = 'modules',
  build = {
    target = 'ygofabrica-v%{version}',
    luajit_version = '2.1.0-beta3',
    vips_version = '8.10.5',
    dependencies = {
      'luafilesystem',
      'lua-path',
      'utf8',
      'i18n 0.9.2-1'
    }
  },
  dependencies = {
    'lsqlite3complete',
    'lua-toml 2.0-1',
    'lua-zlib',
    'struct',
    'zipwriter',
    'lua-vips',
  }
}
