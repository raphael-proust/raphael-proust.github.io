---
title: Natural languages in programming languages
...

Programming languages are constructed languages: they are *designed* for humans to communicate ideas, protocols, algorithms, etc. to computers.
However, most programming languages include, in specific places, elements of natural languages.
Comments are parts of a program that are ignored by a computer and used by programmers to explain their code to other programmers; they are reserved places for arbitrary content, often natural language, to be included.
Keywords are elements of a programming language that use words from natural languages: “function”, “while”, “private”, “class”, “module”, etc.

More interestingly, identifiers are often arbitrary strings of alphanumerical characters.
It is considered good practice to use meaningful words or group of words as identifiers.
This makes the code self-documenting in that it attaches meaning to elements of a program.


## Cases and position

Some natural languages write different grammatical cases differently.
German, Russian, Latin and many other languages have this feature.
English on the other hand relies mostly on position to distinguish between the role of different words.
There are only a few cases left – e.g., the difference between “I”, “me”, and “my”.

Additionally, English verbs and nouns are often identical: “fish”, “search”, “return”, “ride”, “plant”, “drive”, “act”, “tie”, etc. and can only be differentiated by context.
On top of which, English verbs nouns and nouns verbs.


## Confusing identifiers

Cases and the ability to differentiate verbs from nouns is useful when using natural language words as identifiers in programs.
Consider Python's `sort` and `sorted`:

- `sort` is an action, it is an active form that acts upon its argument and modifies it. It has side-effect: it *sorts* its argument.
- `sorted` is a state, it is the result of a process. It returns a fresh collection with the same elements but *sorted*.

However, some other built-in functions have nouns as identifier: “bool”, “tuple”.
For these, it is unclear whether they mutate their argument or not – does this function tuple (tuple-ise?) its argument or does it give back a tuple version of its argument?


## Programming paradigms

In Object Oriented Programming, objects have methods (usually identified by verbs) and fields (usually identified by nouns).
One of the way Java programmers make sure these are differentiated is to use explicit getters and setters for the fields.
This way, the object only exposes methods/verbs.
Additionally, they prefix getter and setter identifiers with `get` and `set` to make it unambiguous.

In Functional programming, functions are values which blurs the line between what constitute a verb and what a noun.
I don't know of any guidelines to avoid confusion; I don't know to what extent such guidelines would be effective.


