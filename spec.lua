return {
  version = "1.0.2",
  version_name = "artefato-astral",
  install_path = {
    linux = "/usr/local/ygofab",
    windows = (os.getenv("LOCALAPPDATA") or "") .. "\\YGOFabrica"
  },
  bin_path = "/usr/local/bin",
  config_path = {
    -- TODO: change (os.getenv("HOME") .. "/ygofab" to (os.getenv("HOME") .. "/.config/ygofab"
    linux = (os.getenv("HOME") or "") .. "/ygofab",
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
