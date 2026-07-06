# Petr-Platformer

A 2D puzzle-platformer / Metroidvania about petrification: Amethyst, a
stonemason's apprentice, must use her petrified friends as puzzle objects —
and promises to come back and save every one of them.

- Design: [`docs/GAME_DESIGN.md`](docs/GAME_DESIGN.md)
- Current milestone: [`docs/M0_PLAN.md`](docs/M0_PLAN.md) — graybox mechanic prototype

## Running the M0 prototype

1. Install [Godot 4.7+](https://godotengine.org/download) (standard build).
2. Open `game/project.godot` in the editor and press **F5** (or
   `godot --path game` from the command line).

Controls: **A/D** move · **W/Space** jump · **Q** petrify self ·
**E** soften / re-freeze nearest statue · **F** talk / inspect / ring chime ·
**R** restart room · **1/2** switch rooms · **F1** toggle debug long soften.

Room 1 is the mechanics test yard (slope, water, pressure plate, cracked
floor, Odessa the Kneeler). Room 2 is the puzzle chamber: the pit is too
wide to jump and too deep to climb — drop in, let softened Maren follow
your light over the edge, re-freeze her, and climb out on her shoulders…
or turn on the debug soften and walk her home to the Waystone instead.
