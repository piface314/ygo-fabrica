return {
  version = "2.0.0",
  version_name = "barian-babelico",
  install_path = {
    linux = "/usr/local/ygofab",
    windows = (os.getenv("LOCALAPPDATA") or "") .. "\\YGOFabrica"
  },
  bin_path = "/usr/local/bin",
  config_path = {
    linux = (os.getenv("HOME") or "") .. "/.config/ygofab",
    windows = (os.getenv("APPDATA") or "") .. "\\YGOFabrica"
  },
  dependencies = {
    "lua-path",
    "lsqlite3complete",
    "lua-toml",
    "lua-zlib",
    "luafilesystem",
    "struct",
    "zipwriter",
    "lua-vips"
  }
}
