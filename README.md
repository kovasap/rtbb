# Rogue-like Base Builder Concept

Game is played on a square grid in two phases.

_ _ _ _ _ _ _ _ _ _ _ _ _ _ _
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _

## Setup Phase

Here, the player uses resources they've accumulated to
build a base defending their sage (you).  This includes:
 - Building walls
 - Deploying units as archers/warriors
 - Digging moats
 - Making traps
 - Building farms or other buildings that do not help defend,
   but accumulate resources for next round.

Buildings/units would be purchased from a store like Autochess/Underlords, with
many options and synergies.  If you purchase multiple units of the same kind
from the store, they combine just like in Underlords.  The store system in
[SNKRX](https://github.com/a327ex/SNKRX) is great inspiration here.

## Combat Phase

After setup, the base is attacked by a wave of enemies.
At this point, the player has no control, and just gets to
watch their design work (or not) in real time (like
[TABS](https://store.steampowered.com/app/508440/Totally_Accurate_Battle_Simulator/)).  

### Turn Based Combat Option

The automatic combat is done is waves, where the entire enemy team
moves/attacks at once, then the entire friendly team moves/attacks at once.

## Goal of the Game

Survive X number of waves.  Perhaps the more waves you survive
the more interesting the game gets (or there are multiple endings).

## Progression

When starting the game, you can choose from multiple "biomes" or "campaigns"
that play out in a predictable way.  I want the player to feel like they are
learning with every defeat, just like in every time loop in Outer Wilds.  I
want to avoid unfair/random mechanics that many roguelikes utilize to perhaps
artificially extend the game and make it more grindy.
