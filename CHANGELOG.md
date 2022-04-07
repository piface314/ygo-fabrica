# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.2] - Barian Babélico // 2022-04-07
### Fixed
- `ygofab make` now properly warns when no data can be written to a .cdb, instead of showing a syntax error.
- `ygofab make` now properly writes strings.conf data.

## [2.0.1] - Barian Babélico // 2021-11-18
### Fixed
- Typos in localization.
- No longer errors out when trying to zip inexistent files. A warning is shown instead.
- Correctly identifies commands and return codes during build and installation.

## [2.0.0] - Barian Babélico // 2021-03-22
### Added
- Internationalization in program interface, `ygofab make` and `ygofab compose`.
- A new font is needed to support internationalization.
- `locale` general configuration.
- `locale` configuration in `picset` and `expansion`.
- `--locale` flag in `make.lua` (installer).
- Currently, only `en` and `pt` are the supported languages, but you can add custom locales. 
- Support for multiple monster abilities (Spirit, Union, Flip, etc.) in `proxy` mode.
- Support for custom counters in `ygofab sync` and `ygofab make`.
- `--verbose` flag to `ygofab compose`, `ygofab export` and `ygofab sync`.
- Warning when user seems to be outside a project folder.
- Support for custom data when reading card database with `ygofab compose`/`ygopic` or writing them with `ygofab make`. Currently supported columns are `holo`, `setnumber`, `year`, `author`, placed in a table called `custom`.
- `--holo`, `--locale`, `--verbose` and `--help` flags to `ygopic`.
- `-o` flag in `ygofab export` can now also specify an output _pattern_.

### Changed
- Default binaries location changed from `/usr/local/bin` to `$HOME/.local/bin` for Linux, to avoid using `sudo`.
- Default install location changed from `/usr/local/ygofab` to `$HOME/.local/ygofab` for Linux, to avoid using `sudo`.
- Default install location changed from `C:\Program Files\YGOFabrica` to `%LOCALAPPDATA%\YGOFabrica` for Windows, to avoid the need of running the installer as admin.
- Global configurations location changed from `%USERPROFILE%\ygofab` to `%APPDATA%\YGOFabrica` for Windows.
- Global configurations location changed from `~/ygofab` to `~/.config/ygofab` for Linux.
- More detailed output in `ygofab config`.
- `ygofab sync` now exports project in a `.zip` file, instead of copying individual files - except for `strings.conf`.
- Now each expansion has its own `strings.conf`. E.g. expansion `blue-eyes` is associated with two files: `expansions/blue-eyes.cdb` and `expansions/blue-eyes-strings.conf`.
- `--clean` flag in `ygofab make` renamed to `--overwrite` or `-ow`.
- Attribute and monster Type (race) are no longer mandatory in `ygofab compose`/`ygopic`.
- Correct OT codes and categories for EDOPro.
- For Linux, releases no longer come with luajit and vips. It is recommended that each user installs them via their own package manager.

### Fixed
- Ritual Spells no longer have a blue frame.
- Warnings for `ygofab compose` correctly display id of a broken card.
- `&`, `<`, `>` are correctly escaped and rendered in card pics.
- Fixed a bug in which if a macro was applied with less arguments than a previous macro, the argument from the previous one would be used in the next. Now they correctly use only their respective arguments.

### Removed
- `--clean`, `--no-pics`, `--no-script` and `--no-exp` flags from `ygofab sync`.
- `fonts` command in `make.lua`. Fonts are now copied when `luajit make.lua install` is used.

## [1.0.2] - Artefato Astral // 2020-06-23
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

## [1.0.0] - Artefato Astral // 2020-02-12
### Added
- Creation of YGOPro extension pack folder structure.
- Global and local configurations, e.g. game folders.
- Synchronization of pack to game folders.
- Support for different sets of card pics and expansions.
- Generation of card pics from `.cdb` and raw artwork.
- Export pack to `.zip`, ready for sharing.
- Generation of `.cdb` out of textual card description.

[Unreleased]: https://github.com/piface314/ygo-fabrica/compare/v1.0.0...HEAD
[2.0.2]: https://github.com/piface314/ygo-fabrica/compare/v2.0.1...v2.0.2
[2.0.1]: https://github.com/piface314/ygo-fabrica/compare/v2.0.0...v2.0.1
[2.0.0]: https://github.com/piface314/ygo-fabrica/compare/v1.0.2...v2.0.0
[1.0.2]: https://github.com/piface314/ygo-fabrica/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/piface314/ygo-fabrica/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/piface314/ygo-fabrica/releases/tag/v1.0.0
