<p align="center"><img src="docs/logo.png" width="500" alt="YGOFabrica logo"></p>

A project manager for EDOPro extension packs.

---

## Overview

This is an open source command line tool written in Lua, using LuaJIT, to help Yu-Gi-Oh!
card makers for the EDOPro game. It helps the process of managing extension packs:
copying files to the game folder, adding cards to the extension database, generating
card pics, etc.

The name of the project is based on the Portuguese word for factory, _fábrica_, and is
pronounced just like that, "FAH-bree-kah". From Brazil, with love :green_heart:.

Special thanks to the following artists, since card pic generation was only made possible
thanks to their work:
- [icycatelf](https://www.deviantart.com/icycatelf), with their [templates](https://www.deviantart.com/icycatelf/art/YGO-Series-10-Master-PSD-676448168) for the card proxies.
- [aaiki](https://www.deviantart.com/aaiki), with their [attribute icons](https://www.deviantart.com/aaiki/art/Hi-Res-Yugioh-Attributes-836887394).


## Features

Currently available features are checked. Features planned for release in the near
future are left unchecked.

- [x] Creation of EDOPro extension pack folder structure;
- [x] Global and local configurations, e.g. game folders;
- [x] Synchronization of pack to game folders;
- [x] Support for different sets of card pics and expansions;
- [x] Generation of card pics from `.cdb` and raw artwork;
- [x] Export pack to `.zip`, ready for sharing;
- [x] Making `.cdb` files out of descriptive `.toml` files.
- [x] Multi-language support.

> Note: to generate card pics from a card databases, this software uses an image processing
> library that **only** works on 64-bit systems. This is irrelevant for the rest of the
> features, though.

## Wiki

For further instructions about how to install and use YGOFabrica, go to the
[wiki](https://github.com/piface314/ygo-fabrica/wiki)! You can find there a step-by-step
build guide too, if you need.
