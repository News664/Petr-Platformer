# M0 — Mechanic Prototype Plan (graybox)

**Goal:** prove the flesh↔stone loop is fun with zero art. Everything is
colored rectangles + the stone shader. If softening a friend to reposition
her doesn't feel interesting in graybox, no amount of art will fix it.

**Engine:** Godot 4.x, GDScript. Project lives under `game/`.
**Method:** per `CLAUDE.md` — each step has an explicit verify check;
no speculative systems (no save/load, no ledger UI, no enemies, no audio).

## Steps

1. **Project scaffold** — Godot project in `game/`, main scene, input map
   (move/jump/soften/self-petrify/interact), a flat test room.
   → verify: project opens in editor, runs, character rectangle moves.
2. **Player controller** — run, jump with coyote time + jump buffering,
   tuned gravity/apex.
   → verify: feel checklist (can consistently make a 3-tile gap; no
   sticking on walls; jump feels responsive at 60 fps).
3. **Self-petrification** — swap `CharacterBody2D` → `RigidBody2D` stone
   form: invulnerable flag, high mass (holds a pressure plate a crate
   can't), slides on slopes, sinks in a water volume flesh-Iolite floats in,
   petrify-mid-fall breaks a cracked floor. Stamina bar drains/regens.
   → verify: one test room exercising all five behaviors.
4. **Statue NPCs as objects** — pushable `RigidBody2D` statues; two pose
   archetypes as shapes: Kneeler (stable block) and Runner (top-heavy,
   tips into a ramp when nudged).
   → verify: push, topple, stand on; Runner tips predictably.
5. **Soften I + Stone-Heat** — NPC state machine: frozen → soften (resumes
   a scripted walk/run behavior for 8 s) → re-freeze in new pose/position.
   Consecutive re-softens halve duration and double cost (8→4→2→refuse);
   heat clears at a Waystone marker.
   → verify: a corridor where chained softening provably stalls before the
   exit, but a single well-planned soften crosses the gap that matters.
6. **Stone shader** — desaturate + noise + rim light, with an animated
   petrification wipe, applied to player and NPC placeholder sprites.
   → verify: visually distinct flesh/stone states; wipe plays both ways.
7. **Graybox puzzle chamber** — one authored room: reach an exit that
   requires toppling the Runner across a gap, softening her so she stumbles
   two steps, and re-freezing her as a bridge. Include a reset chime.
   Include a Waystone so that (with a debug-extended soften) she can
   instead be escorted out — the rescue teleport stub.
   → verify: completable via the expedient route; rescue route works with
   debug duration; reset chime restores the room.
8. **Playtest build** — export a Windows/Linux build.
   → verify: a first-time player clears the chamber in ~10 min and can
   answer: “did using a person as a bridge feel bad in the right way?”

## Implementation notes (deviations discovered while building)

- **Softened NPCs follow Iolite** instead of resuming a pre-scripted action.
  Following makes both puzzle positioning (lure her to where you want the
  statue) and rescue escorts (lead her to the Waystone) fall out of one
  behavior, and it reads better ("she's conscious, she trusts you"). If M0
  playtests support it, fold this into `GAME_DESIGN.md` §4.2 (Soften I).
- **Early re-freeze on demand** (press E again while softened) is enabled in
  the prototype for usability — canonically this arrives later on the
  ability ladder, so decide after playtesting whether Soften I keeps it.
- No engine binary was available in the dev environment; all scripts are
  parse/lint-verified with gdtoolkit (`gdparse`/`gdlint`), but **runtime
  behavior and physics tuning (impulses, pit/statue dimensions, water feel)
  still need a human run in the Godot 4.3+ editor.**

## Out of scope for M0

Art beyond the shader, audio, world map, rescue ledger UI, enemies,
dialogue/portraits, endings, Chisel Light economy numbers (use a plain
counter), fast travel.

## Exit criteria

A stranger can play the slice unassisted; the team can answer “is the core
verb fun?” with evidence. Only then does M1 (vertical slice with real art
pipeline) start.
