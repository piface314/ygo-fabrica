<img src="docs/logo.png" width="500" alt="YGOFabrica logo">

A project manager for YGOPro extension packs.

## Overview

This is an open source tool written in Lua, using LuaJIT, to help Yu-Gi-Oh! card makers
for the YGOPro game. It helps the process of managing extension packs: copying files to
the game folder, adding cards to the extension database, generating card pics, etc.

The name of the project is based on the Portuguese word for factory, _fábrica_, and is
pronounced just like that, "FAH-bree-kah". From Brazil, with love :green_heart:.

## Features

Currently available features are checked. Features planned for release in the near
future are left unchecked.

- [x] Creation of YGOPro extension pack folder structure;
- [x] Global and local configurations, e.g. game folders;
- [x] Synchronization of pack to game folders;
- [x] Support for different sets of card pics and expansions;
- [x] Generation of card pics from `.cdb` and raw artwork;
- [x] Export pack to `.zip`, ready for sharing.
- [x] Making `.cdb` files out of descriptive `.toml` files;

## Installation

### Fonts

The `res/composer/fonts` folder is supposed to keep font files that are used by the
Composer module, that generates card pics from your extension pack data. However, the
official fonts may not be free, and thus cannot be published in this repository. The
only exception is the font used in Link Rating as I made it myself, so it's already
there.

If you're already on YGOPro Percy Discord server, you can find me there (PiFace) and
ask me for a `.zip` file with the fonts.

After getting them, and before installing the program, copy them to that folder
(`res/composer/fonts`).

### Linux

Install the following software in their latest versions:
- LuaJIT ([download](http://luajit.org/download.html), unzip and install with
`$ make && sudo make install`)
- libvips ([download](https://github.com/libvips/libvips/releases), unzip, install with
`$ ./configure`, then `$ make && sudo make install`)

_Note: you can find more details about installation browsing the links._

Then, download the [latest release](https://github.com/piface314/ygo-fabrica/releases) of
YGOFabrica, unzip it anywhere and run `make.lua` like this, considering `luajit` is in
your `PATH` and that you are inside the unzipped folder:
```
$ sudo luajit make.lua install
$ luajit make.lua config <game-path>
```
where you should replace `<game-path>` with the actual path of your main YGOPro game
folder. This setting can be changed later, as described in [Usage](#usage).

If there are no errors, you're ready to go!

This will install YGOFabrica to `/usr/local/ygofab` and place two links in
`/usr/local/bin` (`ygofab` and `ygopic`) as this is probably already in your `PATH`
(add it if it's not there).

You can change the install location by giving `install.lua` a path, like this:
```
$ sudo luajit make.lua install path/to/your/folder
$ luajit make.lua config <game-path>
```

In case you have any problems using the program, you can delete the `lua-modules` folder
from the unzipped files and build the dependencies from scratch. You must have
[LuaRocks](https://github.com/luarocks/luarocks/wiki/Download) installed and configured
for Lua5.1/LuaJIT for this to work. Having LuaRocks, just run:
```
$ luajit make.lua build
```

### Windows



## Usage
Work in progress
