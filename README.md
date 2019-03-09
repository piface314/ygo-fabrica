# YGOFabrica
A project for automated generation of card images for the Yu-Gi-Oh! TCG, to help custom card makers.

## Overview
This is an open source project written in Lua, using LuaJIT, to help Yu-Gi-Oh! card makers for the YGOPro game.
How does it help? Automating the process of generating images for the cards, by taking as input a folder containing
card artworks named by their ID, and a card database - a .cdb file used by YGOPro. In a matter of seconds, a whole custom deck
is ready to be used in the game or to be printed for casual play.

The name of the project is based on the Portuguese word for factory, *fábrica*, and is pronounced just like that, "FAH-bri-ka".

## Installation
Work in progress

## Use
This works like a CLI tool, so you must open your terminal and start typing:
    
    $ ygofabrica option path/to/images/folder/ path/to/card/database.cdb
    
 And that's it! Your cardpics will appear inside the images folder provided, inside a subfolder `out`, as `.jpg`.
 - The first argument, `option` must be either `anime`, `reg` or `proxy`. This alters how the card pics will be generated - options
 currently available are marked below.
   - [x] `anime`: the card pics will be in the same style as they are in the dubbed version of the anime.
   - [ ] `reg`: regular card pics, like the ones that YGOPro comes with, in a small size.
   - [ ] `proxy`: 300 dpi card ready for printing. Currently, it only generates cards in text colors similar to
   Common Rare cards
 - The second and third arguments are self explanatory.
 - You can also use four optional flags:
   - `-o` to specify an output folder;
   - `-s` to suppress the creation of a subfolder `out`;
   - `-v` verbose, so the program tells you each step it is doing;
   - `-c` to clean files in the output folder with the same name as the generated card pics, but different extensions - this is
   useful if you're updating your YGOPro `pics` folder and it has mixed file types like `.png`, `.jpg`, etc.
