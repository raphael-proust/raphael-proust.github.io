---
title: Filling up rectangles for fun and primes
...

## Backstory

When I was little, I used to draw.
Except, I was really bad at drawing so I would just take grid paper, …

IMAGE

… draw a rectangle on it, …

IMAGE

… start at one angle and draw a diagonal, …

IMAGE

… “bounce” on each side of the rectangle, …

IMAGE

… until reaching another angle.

IMAGE

I'd then do it again with a differently sized rectangle.
And again and again.

I would sometime make a variation on the method by starting not at one of the angles, but somewhere along one of the edges.

IMAGE

I noticed that some rectangles filled up almost completely whilst others remained mostly blank.

IMAGE

And then one day my dad told me about primes and coprimes and how my drawings seem to relate to that.
He thought I should explore the relationship and that maybe a computer was the way to do it.
He bought Visual Basic: a cardboard box the size of a big book with a CD-ROM inside.
The tutorial, included in the package, ran along the lines of:

1. This is how you make a window appear on screen
2. This is how you put a button on the window
3. This is how you make some text appear on the window when the button is clicked
4. Cool!

So I kept filling up those rectangles by hand.


## Code

I've since learned to code.
Here's a basic implementation of the rectangle filling procedure.

IMPLEMENTATION

And a renderer to generate the images included in this post.

IMPLEMENTATION


## Observations

Symmetry, Scale

GCD times 2 (how to get times one), coprime

Corner-link (short, opposite, long)


## Relationship to Euclid's GCD algorithm

EUCLID's?????

Visual representation
