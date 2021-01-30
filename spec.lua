local WIN = package.path:sub(1, 1) == '\\'

return {
  version = '2.0.0',
  version_name = 'barian-babelico',
  install_path = {
    linux = (os.getenv('HOME') or '') .. '/.local/ygofab',
    windows = (os.getenv('LOCALAPPDATA') or '') .. '\\YGOFabrica'
  },
  bin_path = (os.getenv('HOME') or '') .. '/.local/bin',
  config_path = {
    linux = (os.getenv('HOME') or '') .. '/.config/ygofab',
    windows = (os.getenv('APPDATA') or '') .. '\\YGOFabrica'
  },
  build_dependencies = {
    'lua-path',
    'utf8',
    'i18n'
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
