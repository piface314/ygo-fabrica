<p align="center"><img src="docs/logo.png" width="500" alt="YGOFabrica logo"></p>

A project manager for YGOPro extension packs.

---

## Overview

This is an open source command line tool written in Lua, using LuaJIT, to help Yu-Gi-Oh!
card makers for the YGOPro game. It helps the process of managing extension packs:
copying files to the game folder, adding cards to the extension database, generating
card pics, etc.

The name of the project is based on the Portuguese word for factory, _fábrica_, and is
pronounced just like that, "FAH-bree-kah". From Brazil, with love :green_heart:.

Also, the generation of card pics was only made possible thanks to icycatelf, an artist
at DeviantArt that published their
[templates](https://www.deviantart.com/icycatelf/art/YGO-Series-10-Master-PSD-676448168)
for the card proxies. 

---

## Features

Currently available features are checked. Features planned for release in the near
future are left unchecked.

- [x] Creation of YGOPro extension pack folder structure;
- [x] Global and local configurations, e.g. game folders;
- [x] Synchronization of pack to game folders;
- [x] Support for different sets of card pics and expansions;
- [x] Generation of card pics from `.cdb` and raw artwork;
- [x] Export pack to `.zip`, ready for sharing;
- [x] Making `.cdb` files out of descriptive `.toml` files.

Note: to generate card pics from a card databases, this software uses an image processing
library that **only** works on 64-bit systems. This is irrelevant for the rest of the
features, though.

---

## Build

Probably it's not necessary to build YGOFabrica from source, because you can get an
adequate [pre-built release](https://github.com/piface314/ygo-fabrica/releases) for
your system and unzip it anywhere. In this case, skip to the
[installation instructions](#installation).

But, if you want to or need to build from source, the following software must be properly
installed:
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
- Make sure that LuaRocks is built with the installed LuaJIT, not the pre-bundled
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
system, there is a folder called `res`.

Inside it, there is `res/composer/fonts`, which is supposed to keep font files
used by the Composer module, that generates card pics from a card database.
However, the official fonts may not be free, and thus cannot be published in this
repository. The only exception is the font used in Link Rating as I made it myself, so
it's already there.

If you're already on YGOPro Percy Discord server, you can find me there (PiFace) and
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

The install location can be changed by giving `make.lua` a path:
```
$ sudo luajit make.lua install path/to/your/folder
$ luajit make.lua config <game-path>
```

### Windows

_In case you're not familiar with changing environment variables like `PATH`, just type_
_`env` in Windows search bar, or check_
_[this link](https://stackoverflow.com/questions/44272416/how-to-add-a-folder-to-path-environment-variable-in-windows-10-with-screensho)._

**If you decided to build from source**, LuaJIT is already installed. So now download
[libvips](https://github.com/libvips/libvips/releases) (choose
`vips-dev-w64-all-x.y,z.zip`, where `x.y.z` is the latest version) and unzip it anywhere.
Then, add `vips-dev-x.y\bin` to your `PATH` environment variable. _E.g., if you_
_downloaded vips v8.9.1 and unzipped it to `C:\Program Files\vips-dev-8.9`, add_
_`C:\Program Files\vips-dev-8.9\bin` to your `PATH`._

**If you downloaded a pre-built release**, both LuaJIT and libvips are already included.
Copy `luajit` and `vips` folders anywhere. Then, add `luajit` and `vips\bin` to your
`PATH` environment variable. _E.g., if you copied `luajit` to_
_`C:\Program Files\luajit`, add that to you `PATH`, and if you copied `vips` to_
_`C:\Program Files\vips`, add `C:\Program Files\vips\bin` to your `PATH`._

Now, run command prompt with admin rights, access the build/pre-built folder, and run
```
> luajit make.lua install
```
This will install YGOFabrica to `C:\Program Files\YGOFabrica`, but that location can
be changed by giving `make.lua` a path instead:
```
> luajit make.lua install "<path>"
```
Then, run the following command, where `<game-path>` is the actual path of your main
YGOPro game folder. This setting can be changed later, as described in [Usage](#usage).
```
> luajit make.lua config "<game-path>"
```

The last step to get YGOFabrica working is to add the install folder (as already stated,
`C:\Program Files\YGOFabrica` by default) to your `PATH`. If in doubt, check the last
part of the installation log in your command prompt; it will tell you what to do.

If there were no errors, now you're ready to go!

---

## Usage

As stated before, this is a command line tool. So, in order to use it, the terminal
or command prompt will be your best friend. Each available command is described here.
Commands from `ygofab` share some common flags, which are described
[later](#common-flags).

In this usage guide, when part of a command is enclosed in angle brackets, `<like-this>`,
that means it must be replace by some value (without the brackets), otherwise
the command won't work. And when part of a command is enclosed in square brackets,
`[like-this]`, that means whatever is inside the brackets is optional.

### `ygofab new`

```
$ ygofab new <project-name>
```
This command creates a folder inside your working directory, with the name you provide in
`<project-name>`, and also creates in it a whole structure for your project. More
specifically, it creates the following:
- `<project-name>/artwork`
- `<project-name>/expansions`
- `<project-name>/expansions/<project-name>.cdb`
- `<project-name>/pics`
- `<project-name>/script`
- `<project-name>/config.toml`

After running this command, `cd` into your project to use other commands.

### `ygofab config`

```
$ ygofab config
```

This command shows all the configurations that are active to the project you are in, i.e.,
it shows local configurations of the current project and your global configurations, which
apply to all of your projects. But what are those?

You can configure different aspects of YGOFabrica through `config.toml` files. If that
file is inside your project, whatever is inside that file defines _local configurations_.
Also, during installation, after running `luajit make.lua config`, a `config.toml` file
was created for you to define _global configurations_. On Linux, that file is located at
`~/ygofab/config.toml`; on Windows, `%UserProfile%\ygofab\config.toml` (e.g., if your
username is Yugi, then the file is at `C:\Users\Yugi\ygofab\config.toml`).

Those `.toml` files are ordinary text files, but, as their extension suggest, you should
follow the syntax of the [TOML](https://github.com/toml-lang/toml) language, which is
very easy to read and write with.

There are three possible configurations you can set: `gamedir`, `picset` and `expansion`.

`gamedir` describes a directory where YGOPro is installed. This probably is going to be
a global configuration, as the game(s) is highly likely to be the same for all projects.
A `gamedir` is defined as follows:
```toml
[gamedir.<name>]
path = "/path/to/your/gamedir"
```
where `<name>` must be replaced by an identifying name for that `gamedir`. That is the
name used to refer to a `gamedir` in other commands. As defined my TOML, those names can
only contain alphanumeric characters, underscores or dashes (`A-Za-z0-9_-`), e.g., the
global `config.toml` is created with a `gamedir` called `main`.

`picset` describes how card pics will be generated by [`ygofab compose`](#ygofab-compose).
For example, you might want to have a `picset` for small card pics that will be used in
the game, but you also want another `picset` with HD card pics for printing. A `picset`
is defined as follows:
```toml
[picset.<name>]
mode = "proxy"
```
where <name>, again, must be replaced by an identifying name. `mode` is the only required
setting, others are explained in details in [`ygopic`](#ygopic).

`expansion` describes the name of a `.cdb` file and can also define a set of files to be
used by [`ygofab make`](#ygofab-make) to generate that `.cdb` file. An `expansion` is
defined as follows:
```toml
[expansion.<name>]
recipe = []
```
where <name> also must be replaced by an identifying name. `recipe` is the only required
setting, and it can be left empty at first. That is explained in details in
[`ygofab make`](#ygofab-make).

Any configuration can be defined as default by writing `default = true` among its values.
This will make other commands assume that's the configuration you want to use if none is
specified.

### `ygofab make`
```
$ ygofab make [-e <expansion>] [-Eall] [--clean]
```
This command transforms a set of `.toml` files describing cards into a card database
(`.cdb`) file. Not only that, but archetypes (or sets, in YGOPro terminology) can also
be defined inside those `.toml` files and transformed into a `strings.conf` file, which
in turn can be placed in YGOPro to make the archetype names appear on a card. Also, a
script file is created for each generated entry in the database, except for Normal
monsters. If the flag `--clean` is used, all previous entries in the database are erased
before inserting new ones.

This is where expansion `recipe` is used. The `.toml` files listed in a `recipe` are
combined and used by this command to do its job. For example:
```toml
[expansion.test]
recipe = ["macro.toml", "sets.toml", "cards.toml"]
```

Also, there is a feature called macros. Macros can be used inside any text field to spare
some typing. For example, if you define and use a macro like this:
```toml
[macro]
HARD-OPT = '''You can only use this effect of $1 once per turn'''

[card.test]
name = "OP Card"
effect = '''
Destroy all other cards on the field. ${HARD-OPT|"Test Card"}.'''
```
The effect of that card will be transformed into
```
Destroy all cards on the field. You can only use this effect of "Test Card" once per turn.
```
As you can see, a macro can receive text as arguments and use them in specific parts of
it own text, denoted by `$1` (meaning the first argument), `$2` (second argument), etc.
It might have no arguments as well, in which case, a macro is simply used as `${MACRO}`.
To separate arguments, any special character can be used, except for `$`, `{` and `}`.
`|` can be used most of the time as card text does not usually include it.

Check [these examples](examples) of how to define cards, sets and macros.

It's worth noting that cards and sets can be defined partially, and even in separate
files. So if you want, for example, to define your cards for more languages, you can
define card values, types, etc. in one file, and card text in other files, so you don't
have to write all values again and again.

### `ygofab compose`
```
$ ygofab compose [-p <picset>] [-Pall] [-e <expansion>] [-Eall]
```

This commands reads `.cdb` file(s) of a configured expansion(s) and image files in the
`artwork` folder, and generates card pics according to configured picset(s).

The different settings that can be specified in a picset are explained in details
in [`ygopic`](#ygopic).

![How `ygofab compose` works](docs/compose.png)

### `ygofab sync`
```
$ ygofab sync [-g <gamedir>] [-Gall] [-p <picset>] [-e <expansion>] [--clean] [--no-script] [--no-pics] [--no-exp] [--no-string]
```

This command copies all relevant files of your project to the specified gamedir(s).

If the flag `--clean` is used, previously existing card pic files in each gamedir are
deleted if their name is the same a card that is being copied. E.g., card pic
`12345678.jpg` is being copied to the gamedir, but `12345678.png` was there already;
without `--clean`, after copying, both files would exist, but with `--clean`,
`12345678.png` is deleted before `12345678.jpg` is copied.

If the flags `--no-script`, `--no-pics`, `--no-exp` or `--no-string` are used, then
scripts, card pics, expansions or `strings.conf` will not be copied, respectively.

### `ygofab export`
```
$ ygofab export [-e <expansion>] [-Eall] [-p <picset>] [-o <output-path>]
```
This command compresses all relevant files of your project to a `.zip` file, ready for
sharing it with players. By default, those `.zip` files are created in the project root
directory, but other folder can be specified with the `-o` flag. Each `.zip` is created
with this name pattern: `<expansion-name>-<picset-name>.zip`.

### `ygopic`
```
$ ygopic <mode> <art-folder> <cdb> <output> [options]
```
This command does essentially the same thing as [`ygofab compose`](#ygofab-compose), but
it can be used with arbitrary `.cdb` files and images. This is useful if you just want
to genereate card pics of previously existing cards in the game, not related to
any project, for example.

There are four required arguments to make `ygopic` work:

| Argument       | Meaning                                                   |
| -------------- | --------------------------------------------------------- |
| `<mode>`       | Specifies card pic style, either `anime` or `proxy`.      |
| `<art-folder>` | Path to a folder containing artwork for the cards.        |
| `<cdb>`        | Path to a card database file `.cdb` describing each card. |
| `<output>`     | Path to a folder that will contain output images.         |

`mode` corresponds to the required setting of a `picset`, while other optional settings
correspond each to an option of the `ygopic` command, listed below.

- `--size WxH`: W and H determines width and height of the output images. If only W or H
is specified, aspect ratio is preserved. Example: `--size 256x` will output images in
256px in width, keeping aspect ratio. Defaults to original size.
- `--ext <ext>`: Specifies which extension is used for output, either `png`, `jpg` or
`jpeg`. Defaults to `jpg`.
- `--artsize <mode>`: Specifies how artwork is fitted into the artbox, either `cover`,
`contain` or `fill`. Defaults to `cover`.
- `--year <year>`: Specifies an year to be used in `proxy` mode in the copyright line.
Defaults to `1996`.
- `--author <author>`: Specifies an author to be used in `proxy` mode in the copyright line.
Defaults to `KAZUKI TAKAHASHI`.
- `--field`: Enables the generation of field background images.
- `--color-* <color>`: Changes the color used for card names in `proxy` mode, according
to the card type (\*). <color> must be a color string in hex format. E.g.,
`--color-effect "#ffffff"` specifies white for Effect Monsters card name,
`--color-trap "#ffff00"`specifies yellow for Trap Cards name, etc. In total, these are
the possible options of this kind: `--color-normal`, `--color-effect`, `--color-spell`,
`--color-trap`, `--color-ritual`, `--color-fusion`, `--color-synchro`, `--color-xyz`,
`--color-link`.

To configure those options for a picset, just specify them in `config.toml` without the
leading dashes:
```toml
[picset.example]
mode = 'anime'
size = '256x'
ext = 'png'
year = 2020
author = 'PIFACE'
field = true
color-effect = '#ffffff'
color-trap = '#ffff00'
```

### Common Flags

- `-e <expansion>` and `-Eall`: specify an expansion, or all expansions, respectively.
- `-g <gamedir>` and `-Gall`: specify a gamedir, or all gamedirs, respectively.
- `-p <picset>` and `-Pall`: specify a picset, or all picsets, respectively.

If an `all` version of a flag is specified, it will take precedence. If a command does
not allow an `all` version, it means that command only works with exactly 1 of that
configuration.
