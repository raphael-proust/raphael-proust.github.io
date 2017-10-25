---
title: It's all in the cards
...


This post discusses the use of cards as an alternative mechanic to dice in RPGs.
Cards can provide randomness – hence, they can be used to keep players in check like dice do.

Additionally, cards mechanics are rich and varied – richer and more varied than dice mechanics.
This variety can be used to design interesting mechanics; notably mechanics that match the theme of the game.

Unfortunately, this richness and variety comes at a cost: complexity.
This is also discussed below.


# Hand, deck, discard, draw, recycle, play, etc.

Unlike dice mechanics which can be neatly summarised and even expressed in a compact notation, card mechanics are more complex and use a more extended vocabulary.

## Areas

To start with, cards mechanics use the following areas:

- the *hand* is a set of cards a player holds,
- the *deck* is a set of cards from which the player gets new cards,
- the *discard* (or *discard pile*) is a set of cards in which the player places one-use-cards after they are played, and
- the *mat* is a set of cards in which the player places cards that have a lasting effect.

Note that the mat can be divided into arbitrarily many sub-areas – e.g., in PTCG a one card slot for the active pokémon, a five card slot for the benched pokémon, a shared slot for a stadium.
Additionally, some cards can only be played in some areas and some cards can be attached to other cards.


## Flows

Cards flow from one area to another via different mechanics.
The most common are

- *Playing*: move cards from your hand into either the discard or (an area of) the mat.
- *Destroying*: move cards from the mat to the discard.
- *Drawing*: move cards from the deck to your hand.
- *Discarding*: move cards from the hand to the discard (and ignore their effect).

But any other flow is possible.
For example:

- *Resurecting*: move cards from the discard onto the mat.
- *Recycling*: move cards from the discard into the deck.
- *Returning*: move cards from the discard into your hand.

In some games, it is even possible to steal opponents cards, play cards from their decks to apply the effect for yourself, or other such mechanisms.


## General mechanics and specific mechanics

In card rule systems, there are mechanics that apply to the game in general and mechanics that are specific to certain cards.

The core mechanics involve drawing, discarding, etc.
They are affected by parameters such as:

- Initial hand size: the number of cards you start with.
- Hand limit: the maximum number of cards you can have in your hand.
- Play limit: the maximum number of cards you can play in one turn.
- Draw size: the number of cards you draw on each turn.

Additionally, each card can have specific mechanics: instructions that, when followed, modify the state of the game.
For example, some cards allow you to search your deck for a specific card, some cards allow you to draw more cards, some cards change the maximum hand-size when on the mat, some cards allow you to play the top card of the deck straight into play, etc.


### Aside: classic card games vs TCGs, CCGs and the like

In classic card games (e.g., poker) there are only (or mostly) general mechanics.
In TCGs, CCGs and similar games, there are both general mechanics and rules for each cards.
This is where the richness and complexity of card rules come from.




# Mechanics with a flavour

Cards have much richer mechanics than dice.
Whilst richer mechanics can increase complexity (as discussed below) which can be detrimental to play (also discussed below), it also provides opportunities for game system design.

An opportunity given by cards mechanics is to give flavour to the mechanics: to map the characters' abilities and personalities into the mechanics of the game.
This can be done to a greater extent than with dice.
Indeed, rolling dice for damage when you play a Barbarian or a Thief feels the same (the main difference is the sidedness of the dice) even though the characters would attack very differently.

On the other hand, playing differently coloured decks in MTG feels very different.
The card arts, names and descriptions contribute to this difference, but the mechanics contribute as well.
In an MTG deck, black magic cards often resurrect creatures from the graveyard – or, in mechanics term, make cards flow from the discard onto the mat.
This mechanic has flavour: as a player you raise the dead by pulling cards out of your discard.

These mechanics with a flavour can be applied to RPGs.
Here are a few possible examples.
These are only to give an idea, they are not polished and they have not been play-tested.

## Example: a few barbarian cards

<div style="border: solid #aaa 1px;">

**Berserk**

:	Put this card in play and discard the rest of your hand.
	When this card is in play at the beginning of your turn, reveal three cards from the top of your deck.
	Resolve the revealed attack cards immediately against the closest opponent.
	Discard the other cards.
	If there are no attack cards, destroy the berserk card, draw one card and finish your turn.

**Brutal attack**

:	Search your deck for an attack card.
	Deal 5 damage plus the damage from the selected attack to an opponent.

**Swing**

:	Deal 5 damage to an opponent.
	Search your deck for an attack card and resolve it immediately against an adjacent opponnent.

</div>

When a character goes berserk, they abandon all control over the actions of their character.
The card mechanics mimic the state of abandonment to violence that the character is living.
As a result, the player is forced into the character's state: they have to give up control just like their character.

Additionally, when the character has no opportunities to attack (when they draw no attack cards), they calm down.
Whilst this event might seem random, its likelihood is affected by the following:

- How **focused on offense** the character is.
  Specifically, the character might pick up different non-attack skills (e.g., dodging).
  Each of those skills adds cards in the player's deck.
  They dilute the attack cards which decreases the chance of finding attack cards which, in turn, increases the likelihood of interrupting the berserk state.
- How **tired** the character is.
  For example, the player might have played several Brutal attack or Swing cards.
  These actions reduce the amount of attack cards in the player's deck which, again, increases the likelihood of interrupting the berserk.
  The character gets tired of brutally swinging their axe around which reduces the duration of their bouts of rage.

Finally, note that when going berserk, the player discards their hand.
At the end of their character's bout of rage, they draw a single card.
This mimics the weariness following a period of intense rage.
It takes a bit of time for the character to get back on track, to recover and regain agency.
Similarly, it takes a few turns for the player to draw more cards and have options.

Note that, the character, either through levelling up or through other progression methods, may acquire better berserk cards.
For example, one that allows them to draw more than three cards.
Or one that allows them to draw more cards at the end of their berserk.


## Example: different kinds of magic

The magic of a sorcerer is wild, it feeds on impulses and emotions.
A sorcerer casts spur-of-the-moment spells.
On the other hand, a wizard is a measured, rational, wise individual.
The wizard chooses spells carefully, even if that means casting spells less frequently.
Where the sorcerer is unpredictable, the wizard is measured.
Both dangerous, but each in their own way.

A player with a sorcerer character is given a low starting hand size (say, three), a low maximum hand size (say, also three), a moderate draw rate (say, two cards per turn), and a high play rate (say, three cards per turn).
As a result, the player can only ever chose between a few spells – probably two or three in their hand of three – but they can play several of them.
This mimics the spur-of-the moment spellcasting style of the sorcerer.
Note that, because of the low maximum hand size and the moderate draw rate, the sorcerer will have to discard some spells – e.g., if they could not be cast during the turn because some condition was not met – even if they could be useful in later turns.

A player with a wizard character is given a high starting hand size (say, five or six), a high maximum hand size (say, eight or ten), a low draw rate (say, one card per turn) and a low play rate (say, one car per turn).
As a result, the player has many spells to chose from – probably four or more in their initial hand – but can only play one of them.
This mimics the measured, thought-out spell-casting of the wizard.


These flavour differences can be further pronounced by the additions of a few cards.
For example, the sorcerer can be given any of the cards described below.
They all have a mechanic that makes the outcome potentially powerful but unpredictable.

<div style="border: solid #aaa 1px;">

**Gamble**

:	Reveal the top five cards of your deck.
	If three or more are spells, play them immediately and discard the other cards.
	Otherwise, discard all the revealed cards.

**Of two minds**

:	Reveal the top two cards of your deck.
	Immediately play all the spells cards revealed that way.
	Place the other cards at the bottom of your deck.

</div>


On the other hand, the wizard can be given the card below.
This time, the mechanics make the outcome entirely predictable and feel more measured.

<div style="border: solid #aaa 1px;">

**Mnemonic**

:	Discard three spell cards from your hand.
	Search your deck for a spell and place it in your hand.

</div>

As illustrated here both the core mechanics of the card system and the specific mechanics of the cards themselves can be used to add flavour.


## Example: sneaky characters

A sneaky character, be it an assassin, a thief, or a scout, stays hidden as much as possible, is able to adapt to changing conditions and can act or move quickly.

Hidden is a very different condition to maintain than berserk: it requires control, not loss thereof.
To match that difference, the player can be required to provide additional Hide cards every turn they want to stay hidden.
Thus, like their character, the player is active; like their character, the player is managing risk (How likely I am to draw enough “Hide” cards to reach that thicker part of the forest?).

<div style="border: solid #aaa 1px;">

**Hide**

:	Play this card in front of you to hide.
	You are hidden as long as this card is in play.
	At the begining of your turn, discard three Hide cards from your hand or destroy this card and become visible.  
	In dim light, you only need to discard two Hide cards.  
	In darkness, you only need to discard one Hide card.

</div>


The adaptability of sneaky characters can be baked into the card mechanics through already mentioned processes: high draw rate, high hand sizes, ability to search for specific cards.



# Keeping players in check with cards

There are multiple ways in which cards can be used as a source of randomness.
And in turn this randomness can be used for multiple aspects of the mechanics.
This section focuses on the specific use of randomness to keep players in check.

With cards, you can only play from your hand.
Even though a card may allow you to play additional cards from the deck or the discard, the original card that lets you do that must have been in your hand to enter play.
This is one of the ways in which the cards limit the players.
Interestingly, it is the opposite of the way dice limit the players.
Specifically, with dice, players can try anything, but their success is uncertain; with cards, players are uncertain about what their hand will be and thus what actions they will be able to take, but the success is given.
Thus, the dice specific choose-then-resolve style of play is turned on its head: draw-and-choose.

Cards can require you to reveal the top $n$ cards of the deck.
The success of a card can be tied to the content of these revealed cards.
This is used in the example Gamble card (see above) and, in a different way, in the Berserk card.
Interestingly, the success rate of such a check is tied to the specific deck of the character.
As such, the deck itself, its composition, is constitutive of a character just as much as the character sheets of dice based games.

More interestingly, the composition of the deck changes with play: cards get drawn and discarded.
This can be used to mimic characters getting tired, being affected by conditions, etc.


# The issue of complexity

Compared to dice, cards offer deeper mechanics which can be used to encode some of the flavour from different games or settings.
The flip side of that depth and richness is complexity: card rules tend to be harder to learn and involve more special cases.


## Adoption

Complexity is problematic for beginner players and more generally for adoption.

However, beginner players have low-level characters.
Low-level characters have access to fewer and possibly simpler cards than high-level characters.
This means that players can learn new mechanics progressively.
For example, mechanics such as “searching the deck for a card” can be limited to cards for characters in their third level or higher.

Additionally, RPG players are used to long rule books with special cases and emergent properties.
Card games are complex, but not more complex than Pathfinder.


## Too slow

Another problem with complexity is that it slows down play.
All the different mechanics are based on different physical actions, each taking some time to perform.
Whilst rolling dice and adding numbers is relatively quick, searching through a deck and shuffling are not.
This is a more serious issue because it can break the fantasy – i.e., it can negatively affect one of the core æsthetic of the game.

What is the point of making each player's turn more engaging by introducing flavours in the mechanics, if they end up spending long spans of time waiting for others to finish their turn?

This can be partly mitigated by software.
Specifically, if, instead of physical cards, the players use an electronic play table (such as Tabletop Simulator), some operations can be much faster:

- searching a card can be done faster, and
- shuffling is practically instantaneous.



## The GM does a lot

Another problem is the complexity for the GM.
In most RPGs, the GM effectively plays the role of all NPCs, be they ally or opponent.
If a GM is to manage all the opponents during a fight, they have to effectively manage multiple hands, multiple decks, multiple play areas, etc.

This can again be mitigated by software.
Specifically, opponents in a fight (or in another non-combat conflict) can be programmed to play automatically.
This requires special attention because NPCs have a personality, imbued by the GM descriptions, acting, voicing, etc.
Using computer programs to play the NPCs may, if done poorly, impact the fantasy æsthetics.


# Issues other than complexity

Dice are cheap, sturdy, reusable, generic bits of plastic; you buy a dice set and you are good to go for almost any game.
On the other hand, cards are (relatively) expensive, easily damaged, specific tokens; buying MTG cards gets you nowhere to play PTCG.




# Prospects and ideas

Complexity is a major issue.
There cannot be a card-based RPG with CCG/TCG mechanics without a good solution for complexity.
Mitigating that complexity with electronics/software is difficult.
It needs to be done in a way that preserves (or enhances) the core æsthetics of RPGs: fantasy and fellowship.

Another issue that needs attention is the lack of adaptive threshold mechanism.
For example, in dice-based RPGs, some enemies tend to be harder to hit than others.
With card mechanics, how can this be replicated?
There are solutions to this issue.

Finally, an interesting issue to tackle is the rate limit on some abilities.
In SRD/D&D, some abilities can be used only once between two periods of rest.
This is easily done with cards: use multiple discards.
More interestingly, this gives an opportunity for an interesting mechanic: when their deck is empty, the players shuffle their discard to form a new deck; but before they do so, they must move five random card from their discard into their once-a-day discard.
This mimics the character getting tired, their energy depleted.

