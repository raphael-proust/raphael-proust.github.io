---
title: Tetris
...

[Play](../misc/tetris.html) (hint: zoom in)

Some time ago I heard about [Fifteenel](https://drj11.itch.io/fifteenel-font) by [Cubic Type](https://about.cubictype.com/).
I didn't know what to do with it but I thought it was cool.

Fast forward to now and I made a tetris implementation in OCaml which compiles to Javascript so you can play in your browser.
This tetris implementation is played within the core of the text of a webpage, inside a span.

The implementation is hosted at https://codeberg.org/raphael-proust/spantris although little effort has been made so far to make the code friendly to contribution.
It's a mess which I might or might not end up cleaning.

Game logic: [https://codeberg.org/raphael-proust/spantris/src/branch/main/games/tetris/core.ml](`core.ml`)  
Game UI: [https://codeberg.org/raphael-proust/spantris/src/branch/main/games/tetris/tetris.ml](`tetris.ml`), uses `Brr`  
Fifteenel glyph renderer: [https://codeberg.org/raphael-proust/spantris/src/branch/main/fifteenel/fifteenel.ml](`fifteenel.ml`)  
Fifteenel "graphical" backend: [https://codeberg.org/raphael-proust/spantris/src/branch/main/punchcard/punchcard.ml](`punchcard.ml`)  

I have some more ideas of things to do with Fifteenel in general and with my silly graphics backend in particular.
I might get to them, or I might not.
But in the mean time here's a thing.

[tetris](../misc/tetris.html)
