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
**F** look at / speak to a statue · **M** map · **R** reset room (works
anywhere) · **1–7** switch rooms, **[ ]** step through all rooms (8–15:
Sanctuary, Quarry, and the four area-idea sample rooms) · **F1** debug
long soften · **F2** new game (progress autosaves on every room change).

The game starts in the story slice: **room 3** (the village street —
opening skit, the amulet, Lina) → **room 4** (the well yard — first
Waystone rescue vs. spending Sena on the pit) → **room 5** (the sanctuary
steps — climb over anchored Sister Aldith; Odile's long-walk rescue is
optional) → **room 6** (the square — a breather hub branching to the
sealed Quarry gate, the flooded Baths stair, and **room 7**, the optional
bell tower climb). Rooms **1/2** are development test rooms, not part of
the normal flow. Rescue two villagers and the Sanctuary opens: **Mason's
Grip** (pushing) unlocks there, which shifts the Square's gate into the
non-linear **Quarry** (rooms 9–11). Area design:
[`docs/AREA_VILLAGE.md`](docs/AREA_VILLAGE.md),
[`docs/AREA_QUARRY.md`](docs/AREA_QUARRY.md); all seven region themes:
[`docs/AREAS.md`](docs/AREAS.md).

## Art pipeline

Asset folders and per-type size/prompt specs live under
[`assets/`](assets/README.md); the generator script is
[`tools/artgen/`](tools/artgen/README.md) (OpenAI-style API, labnana by
default, key via `ARTGEN_API_KEY`).
