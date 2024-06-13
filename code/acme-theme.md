---
title: Acme colour scheme for vim
...

EDIT 2024-06-13: I have rewritten vacme in lua.

I recently found out about [vacme](https://github.com/olivertaylor/vacme): an acme-inspired colour scheme for vim.
I adapted it to [my setup](https://github.com/raphael-proust/rcs).
I've since [rewritten it in lua](https://github.com/raphael-proust/vacme/blob/master/colors/vacme.lua).

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
I even made a git alias for that purpose:
`review = !sh -c 'nvim -c \"tabdo Gdiff $1\" -p $(git diff --name-only $1)' _`

The usual problem I have with diff views is that the colouring of the text and of the diff interfere.
Specifically, the foreground colours of the colour-highlighted text do not contrast with the background colours of diff-highlighted text.
This is not a problem in Vacme, because it does not colour the text.

![](/assets/vacme-2-diff.png)


## Colours

The terminal colours set for this theme to work are as follows:

<table>
<thead>
<tr class="header">
<th style="text-align: left;">Normal colours</th>
<th style="text-align: left;">Bright colours</th>
</tr>
</thead>
<tbody>
<tr>
<td style="background-color: #424242">                                        </td>
<td style="background-color: #b7b19c">                                        </td>
</tr>
<tr>
<td style="background-color: #b85c57">                                        </td>
<td style="background-color: #f2acaa">                                        </td>
</tr>
<tr>
<td style="background-color: #57864e">                                        </td>
<td style="background-color: #98ce8f">                                        </td>
</tr>
<tr>
<td style="background-color: #8f7634">                                        </td>
<td style="background-color: #eeeea7">                                        </td>
</tr>
<tr>
<td style="background-color: #2a8dc5">                                        </td>
<td style="background-color: #a6dcf8">                                        </td>
</tr>
<tr>
<td style="background-color: #8888c7">                                        </td>
<td style="background-color: #d0d0f7">                                        </td>
</tr>
<tr>
<td style="background-color: #6aa7a8">                                        </td>
<td style="background-color: #b0eced">                                        </td>
</tr>
<tr>
<td style="background-color: #999957">                                        </td>
<td style="background-color: #ffffec">                                        </td>
</tr>
</tbody>
</table>

<table>
<thead>
<tr class="header">
<th style="text-align: left;">Additional colours</th>
</tr>
</thead>
<tbody>
<tr>
<td style="background-color: #eaebdb">                                        </td>
</tr>
<tr>
<td style="background-color: #effeec">                                        </td>
</tr>
<tr>
<td style="background-color: #eefeff">                                        </td>
</tr>
<tr>
<td style="background-color: #e2f1f8">                                        </td>
</tr>
<tr>
<td style="background-color: #424242">                                        </td>
</tr>
</tbody>
</table>
