<img src="docs/logo.png" width="500" alt="YGOFabrica logo">

A project manager for YGOPro extension packs.

## Overview

This is an open source tool written in Lua, using LuaJIT, to help Yu-Gi-Oh! card makers
for the YGOPro game. It helps the process of managing extension packs: copying files to
the game folder, adding cards to the extension database, generating card pics, etc.

The name of the project is based on the Portuguese word for factory, _fábrica_, and is
pronounced just like that, "FAH-bri-ka". From Brazil, with love :green_heart:.

## Features

Currently available features are checked. Features planned for release in the near
future are left unchecked.

- [x] Creation of YGOPro extension pack folder structure;
- [x] Global and local configurations, e.g. game folders;
- [ ] Synchronization of pack to game folders;
- [ ] Friendly interface for creating, editing and deleting cards;
- [ ] Support for different sets of card pics;
- [ ] Generation of card pics from `.cdb` and raw artwork;
- [ ] Export pack to `.zip`, ready for sharing.

## Installation

### Linux

Download this repo, extract it anywhere, open your terminal, and `cd` into it. Then, run
`install.sh` (use `chmod +x install.sh` before if needed). Then, just follow the steps
shown by the script.

At the end, if installation succeeds, you must manually define an environment variable
called `YGOFAB_HOME`, and set its value to the path you installed YGOFabrica. Then, add
`$YGOFAB_HOME/bin` to your `PATH`.

E.g. if you provided the path `/home/username` to the installation script, then the
subfolder `/home/username/ygofab` was created, and you must set this path to
`YGOFAB_HOME`.

The installation script also reminds you about this manual step.

### Windows

Work in progress

## Use
Work in progress
