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
**E** soften / re-freeze nearest statue (also advances dialogue) ·
**F** look at / speak to a statue · **R** reset room (works anywhere) ·
**1–4** switch rooms · **F1** toggle debug long soften.

The game starts in the story slice: **room 3** (the village street —
opening skit, the amulet, Lina) into **room 4** (the well yard — first
Waystone rescue vs. spending Sena to cross the pit). Rooms **1/2** are the
mechanics test yard and the original puzzle chamber.
