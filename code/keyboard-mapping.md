---
title: Keyboard mapping
...

I use [Vim](http://www.vim.org/).
I started using Vim when I decided to study computer science at university.
I borrowed a book from the University library (something about Unix) and there was this whole thing about `vi` and modes and the terminal.
It was a gruelling experience.
I only ever recommend Vim to people that spend hours a day coding or otherwise editing markup or plain-text.

I also use Vimperator (Vim-like interface to Firefox) and many other programs that share some keybindings with Vim.
The most commonly shared keys are the “arrows”: h, j, k, l.

What with all this use of h, j, k, l, I started shifting the resting position of my hands on my keyboard.
Specifically, I moved my right-hand one letter to the left; my home keys became asdf-hjkl.
This was annoying though because important keys such as backslash and enter become less accessible.

So I decided to remap my keyboard:

- j becomes h,
- k becomes j,
- l becomes k,
- semicolon becomes l, and to close the loop
- h becomes semicolon

With this, the home-keys (physical keys jkl-semicolon) are the same as the Vim movement keys (hjkl).
One last tweak was to swap the shift behaviour of semicolon.
So in fact: h becomes colon and shift+h becomes semicolon.
This is only worth it because I generally use a programming language with few semicolons: [Ocaml](http://ocaml.org/).

To implement this, I have a modified `xkb` file with the following lines:

```
    key <AC05> {
        type= "ALPHABETIC",
        symbols[Group1]= [               g,               G ]
    };
    key <AC06> {         [           colon,       semicolon ] };
    key <AC07> {
        type= "ALPHABETIC",
        symbols[Group1]= [               h,               H ]
    };
    key <AC08> {
        type= "ALPHABETIC",
        symbols[Group1]= [               j,               J ]
    };
    key <AC09> {
        type= "ALPHABETIC",
        symbols[Group1]= [               k,               K ]
    };
    key <AC10> {
        type= "ALPHABETIC",
        symbols[Group1]= [               l,               L ]
    };
    key <AC11> {         [      apostrophe,        quotedbl ] };
```

and my `.xinitrc` executes `xkbcomp $HOME/.xkb.hjkl $DISPLAY`.

In addition, to make it work outside of X11, I have a `/etc/vconsole.conf` which contains the line `KEYMAP="hjklus"`.
This points to the file `/usr/share/kbd/keymaps/i386/qwerty/hjklus.map.gz` which is a modified version of `/usr/share/kbd/keymaps/i386/qwerty/us.map.gz`.

You can find all the files in my [configuration repository](https://github.com/raphael-proust/rcs).



