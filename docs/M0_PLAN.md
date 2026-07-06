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
   can't), slides on slopes, sinks in a water volume flesh-Amethyst floats in,
   petrify-mid-fall breaks a cracked floor. Stamina bar drains/regens.
   → verify: one test room exercising all five behaviors.
4. **Statue NPCs as objects** — pushable `RigidBody2D` statues; two pose
   archetypes as shapes: Kneeler (stable block) and Runner (top-heavy,
   tips into a ramp when nudged).
   → verify: push, topple, stand on; Runner tips predictably.
5. **Soften I + Grace** — NPC state machine: frozen → soften (follows the
   player, 8 s window) → re-freeze in new pose/position. Each NPC has a
   finite Grace reserve (12 s total at tier I) consumed while soft; at 0
   she cannot be softened again this tier.
   → verify: total escort distance per NPC is provably bounded; a single
   well-planned soften still crosses the gap that matters.
6. **Stone shader** — desaturate + noise + rim light, with an animated
   petrification wipe, applied to player and NPC placeholder sprites.
   → verify: visually distinct flesh/stone states; wipe plays both ways.
7. **Graybox puzzle chamber** — one authored room: a pit too wide to jump
   and too deep to climb out of. Drop in; the softened Runner follows your
   light over the edge; re-freeze her at the bottom and use her as the
   missing step out the far side — leaving her standing in the pit.
   Include a reset chime, and a Waystone so that (with debug-extended
   soften) she can instead be escorted home — the rescue teleport stub.
   → verify: completable via the expedient route; rescue route works with
   debug duration; reset chime restores the room; pushing her in as a
   rigid statue (Sokoban route) still leaves the room solvable.
8. **Playtest build** — export a Windows/Linux build.
   → verify: a first-time player clears the chamber in ~10 min and can
   answer: “did using a person as a bridge feel bad in the right way?”

## Implementation notes (deviations discovered while building)

- **Softened NPCs follow Amethyst** instead of resuming a pre-scripted action.
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
  still need a human run in the Godot editor** (playtested on 4.7).

## Changes from the first playtest round

- **Stone-Heat replaced by Grace** (finite total soften time per NPC per
  tier) — heat only slowed chain-escorts; Grace bounds them absolutely.
  Folded into `GAME_DESIGN.md` §4.3.
- **Statues stay pushable** (the Sokoban feel is intended); softlocks are
  covered by the reset chime (now also in room 1) and R, and pushing the
  Runner into the chamber pit unsoftened still leaves it solvable via a
  soften inside the pit.
- **Stone-dreaming lore** explains blind following (into water, off
  ledges): a softened person is a sleepwalker following the amulet's
  light. Body-blocking her is intended and now triggers a bark line.
- **Chisel Light refills on every room (re)load** — test-mode fix for
  arriving in room 2 with an empty budget.
- **Runner resized to human proportions** (26×55 vs. the old 20×190
  stick); the chamber puzzle changed from statue-as-bridge to
  statue-as-step-in-the-pit, which reads better and hurts more.
- **Talk/inspect on F**: statues have frozen-moment lines and Amé
  monologue; softened NPCs murmur. First pass of the narrative voice.

## Out of scope for M0

Art beyond the shader, audio, world map, rescue ledger UI, enemies,
dialogue/portraits, endings, Chisel Light economy numbers (use a plain
counter), fast travel.

## Exit criteria

A stranger can play the slice unassisted; the team can answer “is the core
verb fun?” with evidence. Only then does M1 (vertical slice with real art
pipeline) start.
