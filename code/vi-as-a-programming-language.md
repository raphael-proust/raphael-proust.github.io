---
title: Vi as a programming language
...

Disclaimer: this is not a vi-vs-emacs post.
The comments of this post may apply to emacs as well – let me know if they do or don't.
It just so happens that I use vi, and thus can comment on it, but have only been exposed to emacs for a few hours, and thus cannot make any serious comment on it.

Disclaimer: this post does not claim that vi (and other editors which are programming languages) are better than editors which are not programming languages.

Disclaimer: “vi” here stands for the whole family of editors: vi, vim, neovim, elvis, nvi, vis, etc.
Although some specific examples are from one clone or another, the core ideas of the post are about the whole family of clones.



# Vi has *and is* a programming language

Most vi clones embed one or more scripting languages.
This lets the user customise what their own instance of their favourite clone of vi is capable of: managing Git repositories, manipulating dates and timestamps, handling pairs of quotes, parentheses and other directional typographic markers, tampering with constructs from one programming language or another.

But, more importantly, vi is a programming language.


## State and actions: hand-wavy semantics

The state handled by vi programs is primarily composed of the text and the cursor position.
(Other elements such as modes and registers are discussed later.)
A finer semantics can also take into account pending operators, but it is beyond the scope of this post.

Vi programs modify that state in different ways.

First, programs can modify the character position.
This is achieved with movement operators: `h`, `j`, `k`, `l`, `w`, `e`, `{`, `}`, etc.
There are also movement functions.
These take an argument which control what the movement: `f`, `t`, etc..

Second, programs can modify the text in different ways.
Some modifications are immediate: `x`, `~`, `D`, `J`.
Other modifications take an argument: `r`.

More importantly, the two concepts (movement and text modifications) are often mixed.
Many modification operators are defined in relation with movement operators.
These modify all the text between the current position and the position after the movement.
E.g., `d`, `c`.

Third, almost all operators (be it for movement or text modification), can be executed multiple time, like a for loop.
This is done by prefixing operators with numbers.


## Hand-wavy grammar

The operations described above combine in ways described by the following grammar.

```
SimpleModifier ::= ZeroaryModifier
                 | UnaryModifier Character
                 | CompositeModifier Mover
Modifier       ::= SimpleModifier
                 | Number SimpleModifier
SimpleMover    ::= ZeroaryMover
                 | UnaryMover Character
Mover          ::= SimpleMover
                 | Number SimpleMover
```

Note that this hand-wavy grammar is heavily simplified.
Notably, explicit ranges (also known as text objects) can describe a part of the text that does not start or end at the current character. For example `aw` is a movement-like construct in that it can be used with a composite modifier to apply to **a** **w**ord. However, `aw` is not a movement construct by itself: it cannot be used outside of a composite modifier.

Another simplification is that some movers operate line-wise.
When they are used with a composite modifier, the modification applies to whole lines: from the one on which the cursor currently is to the one the cursor lands after the move.


## Insert mode

Another simplification is the omission of modes.
A full semantic of vi is complex and has to consider many of the corner cases and exceptions.
A simplified version of the insert mode can be described as a n-ary modifier.

In this simplified view, `i` (and other operators that switch to insert mode) takes any number of characters and modifies the text by adding the given characters.

This simplified view differs from vi because it is possible to do more than just add characters in insert mode.
For example, backspace can be used in insert mode to erase characters.


## Meta-programming for everyone

Interestingly, vi is used to edit source code.
In other words, vi is a programming language used to generate source code which is in turn compiled into programs.
To some extent, vi can be seen as a metalanguage that supports a range of object languages: you write vi commands which produce OCaml/C/Python code that executes.



# Criticisms

There is a case to be made that vi is not a programming language.
That vi's UI merely borrows some ideas from programming languages.

The main criticism along this line goes something like this: if vi is a programming language, where are the conditionals?

First, there are explicit conditionals in Ex commands (`:g` and `:v`).

Second, when movement operators fail to move the cursor (e.g., `f` where the argument character cannot be found), the modification operator it is combined with has no effect.

But more importantly, third, vi is a domain specific programming language intended primarily for interactive use.
That is, vi is meant to be used with the text displayed for the user (programmer) to see – hence the name `vi` derived from *visual*.
Criticising the lack of conditionals in vi's normal mode is like criticising the lack of type checking in Makefiles: it is out of scope.


# Comparison with other editors

Other editors also have operators to modify the text and cursor position.
For example, in [Atom](https://atom.io/), all the normal keys are used to insert the corresponding character into the text.
Some control keys (e.g., backspace, delete) are used to modify the text in other ways.
Some other control characters are used to change the cursor position.
And finally, modifier keys (control, alt) chords are used to modify the text in programmable ways by calling into a scripting language (Javascript).

Many editors fit the same description and only require minor variations: which scripting language they use, which control keys do what, etc.

IDEs also fall under this category of editors.
They only happen to have many functionalities bound to various modifier key chords.
These functionalities are often specialised to a specific type of file – typically, source code of a given programming language.

How is this different from vi?
How does this difference supports the claim that vi is a programming language?

Vi operators combine together to form syntactical constructs.
In other words, vi has a grammar (see above).

Vi text modifiers and cursor movers are orthogonal: they combine in predictable ways, but they can evolve independently.

In vi, some sequences of instructions are equivalent to others (e.g., `2dd` and `dj`).
These equivalences are often non-trivial and sometimes depend on context.
These non-trivial equivalences give rise to [vimgolf](http://www.vimgolf.com/), which is a specific version of code golf.

These are descriptions of programming languages.


