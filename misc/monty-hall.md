---
title: Monty Hall
...

The Monty Hall problem is a brain teaser based on a TV game show.
It takes its name from the host of the TV game show: Monty Hall.

# Stating the problem

Whilst there are some insignificant variations, the core of the game works as follows:

1. You are presented with three doors.
   One door hides a prize, the other two doors hide nothing.
2. The game host asks you to pick a door.
   You pick one door (say A).
3. The host opens another door (say B) that hides nothing.
   The host asks you “do you want to keep your door (A) or do you want to change your pick to that other unopened door (C)?”
4. You decide whether to switch.
   You win the prize if the door you have at the end (A or C depending on your last choice) hides the prize.

The big question is:  
In order to maximise your chances of winning, should you switch door?

The brain teaser comes from the fact that switching to the other unopened door increases your chances of finding the prize.
This is not intuitive because there are no obvious differences between the two doors.
What you know is that one door hides the prize, and that both doors are unopened.
So it would stand to reason that the two doors are as likely to hide the prize.

There are many different explanation for the surprising increased probability.
Below is one that I find easy to grasp.

# Re-stating the problem

In this version of the problem, there are actually two games of Monty Hall:

- The 1-door Monty Hall, in which you pick one door to open and you win the prize if you guessed correctly.
- The 2-door Monty Hall, in which you pick two doors to open and you win the prize if you guessed correctly.

Which do you want to play?

## 1-door Monty Hall

The game follows this script:

1. You are presented with three doors.

2. The game host asks you to pick a door.
   You say which door you want to pick.
   For example, you say “I pick door A.”

3. The game is already over: you win if you picked the door that hides the prize.

   But before giving you the prize or not, there is some pageantry to make it more captivating to the TV audience:  
   the game host opens another door (for example door B),  
   the game host asks a scripted question: “do you want to switch to that other door?” (door C in this example),  
   you give the game host a scripted answer: “no”,  
   the game host opens the door you picked (door A),  
   the game host gives you the prize if you picked correctly in step 2.

Note that in step 3, the game has already ended, the whole thing is scripted: you do not make a choice, the question-answer is part of the game's pageantry, you must answer “no”.

The victory condition is that the door you picked in step 2 hides the prize.
You picked one door, which has 1/3 chances of hiding the prize, you have 1/3 chances to win the prize.
There is nothing else to the game but pageantry.

## 2-door Monty Hall

If you think the pageantry in the 1-door Monty Hall game was too much, get ready for some more.

The game follows this script:

1. You are presented with three doors.
2. You can really pick two doors (for example you pick door A and B) but you must pretend to pick the other door (door C).
   This is part of the game: you really pick two, and you announce your picks by pretending to pick the third.

   It unfolds as follows:
   the game host asks you to “pick one door” and winks to remind you of the pretend-pick thing,
   you answer with the door you pretend-pick (“I pick door C”) and you wink back to let the game host know you are really picking the other two doors (A and B).

3. The game is already over: you win if either of the doors you really picked hides the prize.
   In other words, you win if either of the doors you didn't pretend to pick hides the prize.

   But before giving you the prize or not, there is some pageantry to make it more captivating to the TV audience:
   the game host opens one of the two doors you really picked (for example door B),  
   the game host asks a scripted question: “do you want to switch to that other door?” (door A in this example),  
   you give the game host a scripted answer: “yes”,  
   the game host opens the other door you picked (door B),  
   the game host gives you the prize if you guess correctly in step 2.

Note that in step 3, the game has already ended, the whole thing is scripted: you do not make a choice, the question-answer is part of the game's pageantry, you must answer “yes”.

The victory condition is that one of the doors you really picked in step 2 hides the prize.
You really picked two doors, which have a combined 2/3 chances of hiding the prize, you have 2/3 chances to win the prize.
There is nothing else to the game but pageantry.


## A note on the pageantry

In both games, the proximate goal of the pageantry is to make the game more captivating to the TV audience.
The end goal is to sell ad spots, which is achieved by delivering a captivated audience to some marketing wizards.

One thing that holds TV audiences captivated is suspense.
In order to build that suspense, the game host delays the answer to the big question on everyone's mind: “has the participant won?”
And to delay this answer, the game host has a simple trick:

At the very beginning of step 3, when the pageantry starts, the game host decides which of the two doors to open.
And specifically, they chose to open the door that does not hide the prize.

Indeed, in the 1-door Monty Hall game, if the host opened a door that hid the prize, then the audience would know that the participant had lost.
And conversely, in the 2-door Monty Hall game, if the host opened a door that hid the prize, then the audience would know that the participant had won.
In both cases, the audience would switch channel and the advertisers would be disappointed.

Note however that this trick to captivate audience is unimportant for the core of either of the two games.
Specifically, in the 1-door Monty Hall game, whether the host opens a door that hides the prize or not does not affect the victory condition: you win if the single door you picked had been hiding the prize all along.
Similarly, in the 2-door Monty Hall game, whether the host opens a door that hides the prize or not does not affect the victory condition: you win if either of the two doors that you really picked had been hiding the prize all along.
The trick in the pageantry is just for show.


# Un-re-stating the problem

There are two distinctions between the original and restated problems.
The first distinction is what choice do you make: in the original problem you chose whether to switch doors or not, whereas in the restated problem you chose which of the two games (1-door or 2-door) to play.
Ultimately, this distinction is meaningless: it really is a distinction without a difference.
That is because there is an exact correspondence between the two distinct choices: changing door is the same as picking the 2-door game.
You can see the correspondence in the description of the pageantry of each of the two games: in each you give a differently scripted answer to the scripted question, and each of those answers matches a choice in the original problem.

The second distinction is when you make the choice: in the original problem you chose halfway through the game, in the second you chose before (either of) the games start.
Once again this distinction is meaningless.
The original game is just written in a way that minimises repetition: it only describes the set-up of the game once.
