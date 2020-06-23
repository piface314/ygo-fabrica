# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.2] - Artefato Astral // 2020-06-12
### Fixed
- `ygopic` no longer broken.
- Solved problems with working on different drives in Windows.

## [1.0.1] - Artefato Astral // 2020-05-08
### Added
- Simpler installers for both Linux and Windows.

### Changed
- Default install location changed from `C:\Program Files\YGOFabrica` to `%LOCALAPPDATA%\YGOFabrica` for Windows.
- Global configurations location changed from `%USERPROFILE%\ygofab` to `%APPDATA%\YGOFabrica` for Windows.

### Deprecated
- `--clean` flag in `ygofab sync` will be removed soon.

### Fixed
- Composer no longer tries to write empty text.
- Gamedir path delimiter is now `'''` to avoid conflicts.
- Infinite loop for long multiline text no longer happens.
- `--clean` flag in `ygofab make` no longer drops tables.
- `--version`/`-v` flag wasn't present

## [1.0.0] - Artefato Astral // 2019-02-12
### Added
- Creation of YGOPro extension pack folder structure.
- Global and local configurations, e.g. game folders.
- Synchronization of pack to game folders.
- Support for different sets of card pics and expansions.
- Generation of card pics from `.cdb` and raw artwork.
- Export pack to `.zip`, ready for sharing.
- Generation of `.cdb` out of textual card description.

[Unreleased]: https://github.com/piface314/ygo-fabrica/compare/v1.0.0...HEAD
[1.0.2]: https://github.com/piface314/ygo-fabrica/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/piface314/ygo-fabrica/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/piface314/ygo-fabrica/releases/tag/v1.0.0
