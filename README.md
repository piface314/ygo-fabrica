<img src="docs/logo.png" width="500" alt="YGOFabrica logo">

A project manager for YGOPro extension packs.

---

## Overview

This is an open source command line tool written in Lua, using LuaJIT, to help Yu-Gi-Oh!
card makers for the YGOPro game. It helps the process of managing extension packs:
copying files to the game folder, adding cards to the extension database, generating
card pics, etc.

The name of the project is based on the Portuguese word for factory, _fábrica_, and is
pronounced just like that, "FAH-bree-kah". From Brazil, with love :green_heart:.

---

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

Note: to generate card pics from you card databases, this software uses an image
processing library that **only** works on 64-bit systems. This is irrelevant for the
rest of the features, though.

---

## Build

Probably it's not necessary to build YGOFabrica from source, because you can get an
adequate [pre-built release](https://github.com/piface314/ygo-fabrica/releases) for
your system and unzip it anywhere. In this case, skip to the
[installation instructions](#installation).

But, if you want to or need to build from source, you'll need these properly installed:
- [LuaJIT](http://luajit.org/download.html)
- [LuaRocks](https://github.com/luarocks/luarocks/wiki/Download)
- [zlib](https://www.zlib.net/)

Follow the installation instructions of each software carefully, according to your
system.

If you're on Linux, you'll probably have no trouble. If you're on Windows,
though, here are some tips:
- Be careful to build a 64-bit version of LuaJIT in order to use the card pic generation
feature. You'll need [Visual Studio](https://visualstudio.microsoft.com/pt-br/free-developer-offers/)
(specifically Visual Studio Developer Command Prompt) for this.
- Make sure that you build LuaRocks with the LuaJIT you installed, not the pre-bundled
Lua interpreter that comes with it.
- Read [this StackOverflow question](https://stackoverflow.com/questions/60140305/how-to-install-lua-zlib-with-luarocks-on-windows)
to build zlib.
- You'll need `luajit` and `luarocks` directly available in your commmand line prompt, so
add the directory of their binaries to your `PATH` environment variable.

Then, download this repository, unzip it anywhere, `cd` into the unzipped folder, and
run the command below. That should download and build all the dependencies of YGOFabrica.

```
$ luajit make.lua build
```
_Note: if you're on Windows and followed the guide on StackOVerflow to install `zlib`,_
_you should edit the `dependencies.lua` file and replace `"lua-zlib"` with_
_`"lua-zlib ZLIB_DIR=C:\\lib\\zlib"` before running the above command._

---

## Installation

### Fonts

If you built YGOFabrica from source **or** downloaded and unzipped a
[pre-built release](https://github.com/piface314/ygo-fabrica/releases) for your
system, you will see a folder called `res`.

Inside it, there is `res/composer/fonts`, which is supposed to keep font files
used by the Composer module, that generates card pics from your extension pack data.
However, the official fonts may not be free, and thus cannot be published in this
repository. The only exception is the font used in Link Rating as I made it myself, so
it's already there.

If you're already on YGOPro Percy Discord server, you can find me there (@PiFace) and
ask me for a `.zip` file with the fonts.

After getting them, and before installing the program, copy them to that folder
(`res/composer/fonts`). Then, follow the instructions for your system.

### Linux

Install the following software in their latest versions, if you don't have them
already:
- LuaJIT ([download](http://luajit.org/download.html), unzip and install with
`$ make && sudo make install`)
- libvips ([download](https://github.com/libvips/libvips/releases), unzip, install with
`$ ./configure && make && sudo make install`)

_Note: you can find more details about installation browsing the links._

After building from source or just unzipping a pre-built release, `cd` into the build
folder and run:
```
$ sudo luajit make.lua install
$ luajit make.lua config <game-path>
```
where `<game-path>` is the actual path of your main YGOPro game folder. This setting
can be changed later, as described in [Usage](#usage).

If there are no errors, you're ready to go!

This will install YGOFabrica to `/usr/local/ygofab` and place two links (`ygofab` and
`ygopic`) in `/usr/local/bin`, as the latter probably is already in your `PATH` (add it
if it's not there).

You can change the install location by giving `make.lua` a path, like this:
```
$ sudo luajit make.lua install path/to/your/folder
$ luajit make.lua config <game-path>
```

### Windows

_In case you're not familiar with changing environment variables like `PATH`, check_
_[this link](https://stackoverflow.com/questions/44272416/how-to-add-a-folder-to-path-environment-variable-in-windows-10-with-screensho)._

**If you decided to build from source**, you already have LuaJIT installed. So now you
have to download [libvips](https://github.com/libvips/libvips/releases) (latest version,
choose `vips-dev-w64-all-x.y,z.zip`, where `x.y.z` is the version) and unzip it anywhere.
Then, add `vips-dev-x.y\bin` to your `PATH` environment variable. _E.g., if you_
_downloaded vips v8.9.1 and unzipped it to `C:\Program Files\vips-dev-8.9`, add_
_`C:\Program Files\vips-dev-8.9\bin` to your `PATH`._

**If you downloaded a pre-built release**, both LuaJIT and libvips are already included.
So you must copy the `luajit` and `vips` folder anywhere you like. Then, add `luajit` and
`vips\bin` to your `PATH` environment variable. _E.g., if you copied `luajit` to_
_`C:\Program Files\luajit`, add that to you `PATH`, and if you copied `vips` to_
_`C:\Program FIles\vips`, add `C:\Program Files\vips\bin` to your `PATH`._

Now, run command prompt with admin rights, access the build/pre-built folder, and run
```
> luajit make.lua install
> luajit make.lua config <game-path>
```
where `<game-path>` is the actual path of your main YGOPro game folder. This setting
can be changed later, as described in [Usage](#usage).

This will install YGOFabrica to `C:\Program Files\YGOFabrica`. You can change the
install location by giving `make.lua` a path, like this:
```
> luajit make.lua install path\to\your\folder
> luajit make.lua config <game-path>
```

In any case, one last step to get YGOFabrica working is to add the install folder
to your `PATH` (as already stated, `C:\Program Files\YGOFabrica` by default). If
you're in doubt, check the last part of the installation log in you command prompt;
it will tell you what you have to do.

Now you're ready to go!

---

## Usage

As stated before, this is a command line tool. So, in order to use it, your terminal
or command prompt will be your best friend. There is a total of seven commands you
can use, each described here. Commands from `ygofab` share some common flags, which
are described [here](#common-flags).

### `ygofab new`

### `ygofab config`

### `ygofab make`

### `ygofab compose`

### `ygofab sync`

### `ygofab export`

### `ygopic`

### Common Flags