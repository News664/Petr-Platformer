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

## Changes from the second playtest round

- **Reset is global**: R anywhere; chimes are scenery. F no longer
  double-books reset and talk.
- **Water rework**: the pool is sunken 40 px below ground and flesh can
  only weakly hop while treading water — the far lip is unreachable until
  something solid (statue, crate, stone-Amé is too deep) is pushed in to
  stand on. Entry-side shelf prevents softlock.
- **Pushing actually works now**: the old per-frame impulse (12) could
  never beat static friction (μ·m·g ≈ 7000+); pushes are now a central
  force ~9000/s with friction 0.5, plus a torque capped below the statues'
  restoring torque so they slide on flat ground and only topple at edges.
- **Story slice added (rooms 3–4, game starts in 3)**: Petrified Village
  street (opening skit, anchored Petra foreshadows the Anchored, amulet
  pickup unlocks Soften, Lina-as-step with promise skit) and the Well Yard
  (Marla's first rescue at the Waystone vs. Sena spent crossing the pit —
  the thesis room: save one, use one).
- **Dialogue/skit system**: pauses gameplay, placeholder full-body figures
  (layered rects sharing the stone shader, so petrified portrait variants
  are free), advance with E/Space/F, one-shot story flags survive room
  resets. HUD shows a persistent Amé figure that petrifies with her.

## Changes from the third round (post-merge to main)

- **Room 5, Sanctuary Steps**: climbing puzzle over anchored Sister
  Aldith (the Anchored as reliable terrain), Chisel Light motes, and
  Odile — a purely optional rescue whose escort nearly exhausts her
  Grace. Ends at the dark Sanctuary door: the M1 hook.
- **Ledger Map (M)**: Castlevania-style pause map; visited rooms fill
  in, neighboring major areas (Sanctuary, Quarry, Baths) show as sealed
  stubs. Layout lives in `map.gd`.
- **Asset structure**: `assets/` tree with per-type READMEs (sizes,
  naming, counts, prompt templates) and the shared style tag; raw
  generations land in gitignored `assets/candidates/`.
- **artgen**: `tools/artgen/generate.py` (stdlib-only) drives any
  OpenAI-style images API (labnana default) from `characters.json` +
  `shots.json` templates; `--dry-run` verified.
- Rooms 1/2 confirmed as dev-only test rooms; the normal game starts in
  room 3.

## Changes from the fourth round

- **Push physics rewritten as velocity clamp**: pushing sets the statue
  to a constant slow crawl (45 px/s) while contact lasts — zero
  acceleration, no more bullet launches (impulses stacked across
  contacts/frames and blew up). Still no torque from pushes.
- **Cracked cellar floor now signals its intent**: one-shot message on
  first walk-over ("Nothing she can do about it. Yet.") — it is the
  deliberate locked-hidden-room promise, opened by a later ability.
- **Room 6, The Square**: breather hub with the anchored tableau
  (dancer, sisters, mercer), rescued villagers appearing at the
  fountain, and four branches — Steps (west ledge), Bell Tower (west
  door), sealed Quarry gate (east), flooded Baths stair. First room
  with multiple exits; map shows the branching.
- **Room 7, Bell Tower**: optional vertical climb, mote cache, and the
  gorgon-foreshadow view skit at the gallery.
- Known limitation recorded: fixed spawn per room regardless of entry
  door; a `from_door` spawn system is the next engine task.

## Out of scope for M0

Art beyond the shader, audio, world map, rescue ledger UI, enemies,
dialogue/portraits, endings, Chisel Light economy numbers (use a plain
counter), fast travel.

## Exit criteria

A stranger can play the slice unassisted; the team can answer “is the core
verb fun?” with evidence. Only then does M1 (vertical slice with real art
pipeline) start.
