---
title: The roles of the dice
...

Dice are a ubiquitous device of Role Playing Game (RPG) systems.
This post studies the different roles that dice take for both players and dungeon masters (DMs).


# Ubiquity and pervasiveness

Four sided dice are used in the Game of Ur;
six sided dice have been used in non-RPG for a long time;
variously sided dice became widespread in the 1960s in the wargaming community; and from there
they became ubiquitous in the RPG community.

The use of dice is so pervasive that several rule systems are named after dice ([D6](https://en.wikipedia.org/wiki/D6_System), [D20](https://en.wikipedia.org/wiki/D20_System)), shops sell dice sets, many apps, programs and website are dedicated to rolling dice and [a standard notation](https://en.wikipedia.org/wiki/Dice_notation) has been developed.

Dice and RPG rules are so intertwined that “diceless” has become [synonymous with “randomless”](https://en.wikipedia.org/wiki/Diceless_role-playing_game):

> A diceless role-playing game is a role-playing game which is not based on chance: it does not use randomisers to determine the outcome of events in its role-playing game system.
> The style of game is known as "diceless" because most games use dice as their randomiser;
> some games such as Castle Falkenstein use other randomisers such as playing cards as substitutes for dice, and are not considered "diceless".

# Framework

This document uses the Mechanics-Dynamics-Æsthetics framework (by Hunicke, LeBlanc, and Zubek).
This framework uses three levels of description of games.


## Mechanics

The first level, the *mechanics* level, is the one of individual rules.
It describes how the simplest parts of the game interact with each other (“this bonus is added to the result of that dice throw”, “this statistic is compared to that threshold”), how quantities evolve over the course of a game (“increase that statistic by this amount”, “reduce your hit points by this number”), what physical actions players take (“roll two dice and keep the highest”, “move this piece that many squares”).

The mechanics are also the immediate way (but not the most important way) through which players experience the game.
They form the interface of the game, in the same way that the buttons and dialogue boxes form the interface of a program.


## Dynamics

The second level, the dynamics level, is the one of interaction between rules that create emergent properties.
It describes the way rules combine to create higher-order effects (the probability distribution of summed dice throw, the feedback loops that ensures balance) and the way they form a coherent system.


## Æsthetics

The third level, the æsthetics level, is the one of emotional aspect of the game, the one the player describes when asked “is it fun?”
It describes the way players experience the game as a whole, what they enjoy about it.

In RPGs, common types of æsthetics include fantasy (pretending other things are real), narrative (building and experiencing story), challenge (overcoming difficulties and finding solutions to problems), fellowship (interacting with other players and building social bonds) and cooperation (helping each others and achieving goals together).


## The example of experience

Experience points (XP), the means by which to earn them (solving puzzles, killing monsters, negotiating agreements, etc.), the ways to spend them (levelling up, buying skill points, etc.) are common mechanics of RPG.

In most games, the experience points have a diminishing return: for an entry-level character, each experience point is significantly more valuable than for a high-level character.
E.g., in SRD/D&D the characters gain their second level with 300XP, they gain their third level with 600XP more (or 900XP total), then 1800XP more (2700XP total), and so on.

This diminishing return of experience points forms a negative feedback loop: the more experience you have the less you get from new experience.
This is a dynamic through which lower level players receive more benefits from the same reward as higher level players.

This dynamic contributes to two separate æsthetics: fellowship and challenge.
Indeed, players are encouraged to stick together.
Even if a player has missed a few sessions and is lagging a level or two behind other players, they are able to catch up quickly.
This makes it more likely that a player can rejoin a group: it encourages the group to play together.

Additionally, players are encouraged to take on new challenges.
Specifically, beating the same monsters and solving similar problems yield a constant, flat reward.
This flat reward is worth less and less to characters as they progress.
Thus, for the characters to progress, the players must take on new, more difficult challenges.


## The example of the dice roll


The dice roll is a mechanic of most RPGs.
In each RPG, the mechanic is combined in different ways to create different dynamics that, in turn, create different æsthetics.
E.g., in games with a critical success/failure system such as SRD/D&D, dice rolls can change the course of an adventure in dramatic proportions and thus contribute to a heightened sense of suspense.



# Roles of the dice

The dice fills multiple roles in an RPG system.
Keeping with the MDA framework we consider these roles from the three perspective detailed above.


## Dice roll mechanics


Players and game masters use dice for multiple reasons.

- To determine a **quantity** such as the amount of damage done, the distance travelled, the number of coins in a chest, etc.
- To select amongst **multiple choice** such as the type of traps in a randomly generated dungeon, the personality traits of a character, the kind of damage dealt by an elemental spell, etc.
- To decide **success/failure** of an action such as dodging, casting, climbing, attacking, etc. This is sometimes referred to as a skill check.


### Quantity

Dice are used to determine quantities on different occasions; often for damage or healing.
In most cases, the quantity is determined by adding the result of one or several dice rolls and possibly a constant number.
For example, to determine damage in SRD/D&D, the number and sidedness of the dice is influenced by the weapon wielded, and the static constant by the wielder's statistics; some character features may also grant additional damage dice of possibly different sidedness.

### Multiple choice

Many rule books contain tables of random events, loot, characteristics, etc.
For example, SRD/D&D offers tables to suggest personality traits associated to various backgrounds.
In this case, the resolution is simple: choose the row designated by the roll of a dice.

Tables can have non-uniform indexing: a specific row may be associated to a single number whilst another row may be associated to several.
This is used to model the different probability of different elements of the table.

There are variations on this simple mechanic.
One such variation is when a certain result calls for more rolls—e.g., a high roll on a loot table may call for the result of two further rolls to be joined together.

### Success/failure

Different systems implement the success/failure test in different ways.
A simple implementation is to roll a single dice, add appropriate bonuses and compare the total with a threshold.
This is the way skill checks and attack rolls work in SRD/D&D: the dice is a d20, the bonuses are computed based on the character's statistics, the threshold is set by the game master (for a skill check) or by the opponent's statistics (e.g., the AC for an attack roll).

Another implementation of the success/failure test is to roll a single dice which sidedness is determined by the character's statistics and compare it to a threshold.

In both of those implementations, the test boils down to the simple formula $x\mathrm{d}y+z ≥ t$ where $x$, $y$, $z$, and $t$ depend on either the character's statistics, other characters' statistics or the game master choice.

Another way the success/failure test is implemented is by rolling multiple dice and counting the number of them that have a specific value.
This is how skill checks are implemented in Shadowrun: you roll a number of six sided dice determined by your character's statistics, count the dices that are 5 or 6 and compare this count to a threshold set by the game master.

In this implementation as well, the test boils down to a simple formula which depends on in-game statistics or the game master choice.

These different implementations offer different tradeoffs but are essentially similar.
Specifically, they all implement a test for the success of an action that has already been chosen.
This is discussed later.


### Critical success and failure

In multiple systems, some results of the dice are considered automatic success or failures – e.g., rolling 20 or 1 on an attack roll in SRD/D&D.
These bypass the normal checking mechanism, the standard comparison with a threshold.
Instead, these specific rolls have immediate effects.


## Dice roll dynamics

The specific mechanics described above give rise to dynamics discussed now.


### Probability distributions

When determining a quantity, the different ways to combine dice and bonuses result in different probability distributions.
This result in different maxima, minima, averages, etc.

For example, a spell healing $3\mathrm{d}4$ HP is better than a spell healing $2\mathrm{d}6$ than a spell healing $1\mathrm{d}12$.

### Probability of success

When rolling for a success/failure test, different tests have different probability of success and failure.

In addition, the inclusion of critical success/failure means that nothing is certain.
Even when the normal mode of testing would result in 100% chance of success, failure is still possible – and vice versa.


## Dice roll æsthetics

The dice roll dynamics described above give rise to the æsthetics discussed now.


### Keeping players in check

One of the roles of the dice is to keep the players in check.
To prevent the players from simply deciding: “my character unlocks the door to the treasure room,” “my character sneaks past the guards unnoticed,” or “my character jumps from the burning building onto the roof of the house across the street, unharmed.”
The player can decide to attempt those feats, but they cannot decide the outcome.
Instead, the player must roll dice and follow rules.

Similarly, a player cannot decide the amount of damage dealt to an enemy or the amount of HP restored to a fellow party member.
Instead, the player must roll dice and follow rules.

This limits the players power by giving a framework for deciding the outcome of the character's attempts.
As a result, the game is challenging: players must overcome difficulties, find appropriate solutions, solve non-trivial problems.


### Realism

Another role of the dice is to model the characters' universe.
For example, the more an action is difficult to achieve in the characters' universe, the less likely the players are to succeed at the corresponding dice roll.
Similarly, the more effective weapon is in the characters' universe, the more likely players are to get high damage in an attack roll.

This somewhat realistic modelling of the characters' universe maintains a sense of make-belief and helps players engage in Fantasy.


---------------------------------------------------------

A following post discusses the common style of play “choose an action then roll to resolve it.”
Another following post discusses an alternative style of play inspired by trading or collectible card games (TCG/CCG).

