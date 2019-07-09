---
title: Acme colour scheme for vim
...

I recently found out about [vacme](https://github.com/olivertaylor/vacme): an acme-inspired colour scheme for vim.
I adapted it to [my setup](https://github.com/raphael-proust/rcs).

Here's an overview.

## Overview

The colour scheme is principally targeted towards the interface: it colours the window separators, the tabs, the status line, etc.
The text, whether code or otherwise, is left (mostly) untouched.
Notice that some parts of the text are underlined or emboldened, but not coloured.

![](/assets/vacme-0-overview.png)


## Comments

In source code, comments are highlighted.
Specifically, they are rendered as bold.

This is opposite to most colour-schemes: comments are often greyed out, desaturated, or otherwise visually erased.
However, considering how important comments are, it makes sense to highlight them.

![](/assets/vacme-1-comments.png)

I would like to go even further and render keywords as a lighter shade that would blend in the background.
Keywords are boilerplate – of sorts – and should not be displayed as prominently as identifiers or values.


## Diffs

I use the diff capabilities of neovim often.
Most of the time, through fugitive's `:Gdiff`.
I even made a git alias for that purpose: `review = !sh -c 'nvim -c \"tabdo Gdiff $0\" -p $(git diff --name-only $0)'`

The usual problem I have with diff views is that the colouring of the text and of the diff interfere.
Specifically, the foreground colours of the text do not contrast 
Vacme, because it does not colour the text, does not interfere with the diff colouring.

![](/assets/vacme-2-diff.png)
