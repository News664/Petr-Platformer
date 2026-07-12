# Playtest checklist — everything untested since the last play report

The last playtest covered up to the round-7 fixes (reset entry, wrong-side
clearability, help request). Everything below shipped after that report
and has never been played. Ordered roughly by play flow; dev keys `1–7`,
`[`/`]`, `F1` (long soften), `F2` (new game) speed things up.

## Round 8 — engine fixes, help, boss

- [ ] **Reset entry**: enter a room by its right/east door, press R —
  respawn at that same door (not the left one).
- [ ] **Room 4 from the east**: with a rescue done, enter from the Steps
  side and climb the east step → overpass → cross west over the pit.
  Also confirm the overpass canNOT be reached from the west ground
  (statue-boost included) — the pit puzzle must survive.
- [ ] **Room 9 from the Haul Road**: with Brona rescued, climb the
  terrace's new east-face step and reach the west (Square) door.
- [ ] **Help (H)**: opens/closes, pauses, readable, no key conflicts.
- [ ] **Foredame (room 19)**: telegraph readable (~1 s)? fist hit
  respawns you; luring slams onto all 3 pillars wins; win skit plays;
  after reload the dig stays collapsed and the Sanctuary door works.
  Tuning judgment: is the aim-track fair? rest window long enough?

## Round 9 — Quarry back half, dash, presence

- [ ] **Wisp Gallery (20)**: wisps chase, sip 1 Chisel Light on touch
  (fair rate?); collecting the two floor motes under pressure.
- [ ] **Colossus Shelf (21)**: push a block against the shelf, climb it,
  reach the east door. Rescue Sableth → Witness skit plays, HUD shows
  "Truths 1", value survives F5-restart (autosave).
- [ ] **Quarry Sanctuary (22)**: altar grants Chisel Dash; skit; braziers
  lit on revisit; flag survives restart.
- [ ] **Chisel Dash (Shift)**: distance/cooldown feel; shatters the
  powder-store wall in room 20; **shatters the Village street floor
  (room 3) while standing on it** — this is the one physics-risk item:
  if the floor won't break, report it (fallback: downward strike probe).
- [ ] **Cellar (room 3)**: drop in after dash-break → Ida's-workshop
  skit (geodes with Amethyst's face) + mote; climb back out via steps.
- [ ] **Wisp vs dash**: dashing through a wisp bursts it.
- [ ] **Petrified presence**: violet breathing rim when standing close to
  any statue; rim *dies* while pushing or standing on her, returns
  after; the two one-time barks fire (push / stand-on). Is the glow
  visible enough at graybox contrast?
- [ ] **First-inspect portraits**: first F on Lina/Petra/Marla/Sena/
  Odile/Aldith/Sableth/Nerissa/Ottilie pauses with her petrified figure
  and one line; second F returns to normal message lines.

## Round 10 — Baths, ledger, Soften II (this round)

- [ ] **Baths gate (room 6 stair)**: before dash — "drowns in black
  water" message; after dash — "cracked grate" visible, dashing while
  overlapping it drains the stair and a "baths ↓" door appears
  (persists after reload).
- [ ] **Vestibule (23)**: entry skit; two-way stair door; pool escape
  shelves work (no drowning trap); Nerissa first-inspect.
- [ ] **Long Soak (24)**: push Casta off the west lip → she sinks onto
  the sluice-plate → east door opens; east waterline shelf lets you
  climb out of the pool on the far side. Rescue Ottilie → Witness #2
  skit, Truths 2. Confirm the one-soul Waystone forbids rescuing both.
  Soften someone within the siren's range → "her dreaming feet turn
  toward the song" and she walks to the siren instead of you.
- [ ] **Siren kills**: dash into her; separately, push the loose block
  (room 25) off its plank onto the mid-basin siren — "the stone ends
  the song."
- [ ] **Cisterns (25)**: full puzzle — kill the siren first, then soften
  Brigid; she tracks you along the basin floor while you hop the planks;
  she reaches the **drowned Waystone** → rescued. Pre-Soften-II this is
  deliberately tight (~8 s window + a re-soften from Grace): tight-but-
  fair, or frustrating?
- [ ] **Deep Sanctuary (26)**: altar grants Soften II — statue tags now
  show grace 40, windows 25 s; Maud's long rescue is now easy; boiler
  gate message; flag survives restart. Retroactive check: any village/
  quarry puzzle *broken* by the longer window? (Sena's pit, Odile's
  walk — should be more generous, not broken.)
- [ ] **Ledger (L)**: rows appear only for visited rooms; statuses
  correct (safe / anchored / stone-waiting, "I promised." after a first
  inspect); witnesses starred; counters match HUD; L closes it; no
  overlap with M/H.

## Cross-cutting / regression

- [ ] Full run from F2 new game to the boiler gate in one sitting —
  note total time and any progression stalls.
- [ ] Quit mid-Baths, relaunch: resumes in the right room with rescues,
  truths, motes, abilities intact.
- [ ] Map (M): Baths row renders; no cell overlaps at the right edge.
- [ ] Rescued NPCs stay gone; spent Waystones stay dark; no room is
  stuck from either door after any rescue combination.
