# Petr-Platformer — Game Design Document (v0.2)

**Working title:** *Gorgon's Garden* (placeholder)
**Genre:** 2D puzzle-platformer / Metroidvania
**Platform:** PC (Windows/Linux, Steam-first)
**Team assumption:** solo/small team, programmer-led, art produced primarily with AI assistance

---

## 1. High Concept

You play **Petra**, a young stonemason's apprentice in a kingdom turned to
stone by a gorgon-like calamity. Petra was spared, and she carries her
mentor's chisel-amulet — a relic that can **revert petrification, but only
briefly and only barely**. From the very first minute her goal is stated
plainly: *save everyone*. But her power is nowhere near enough. A softened
friend returns to flesh for mere seconds before the curse reclaims her.

So Petra does the only thing she can: she **uses her petrified friends as
tools** — climbs them, topples them, drops them onto switches — whispering
the same promise each time: *"I'll come back for you."* The game's structure
makes that promise real: as Petra's power grows, she physically returns to
earlier regions and permanently restores the people she once had to use.

**The mechanical hook and the narrative hook are the same object**, and now
the *progression system* is the same object too: ability-gated backtracking
(the Metroidvania loop) is literally the act of keeping her promise.

---

## 2. Why Petrification? (The Distinguishing Pillar)

Solidification converts characters between two ontologies:

| State | Behaves like | Used for |
|-------|--------------|----------|
| Flesh (animate) | AI agent — walks, follows, panics, helps | Escort, cooperation, lure |
| Stone (solid) | Physics object — heavy, rigid, durable | Platform, weight, shield, plug, projectile |

Every mechanic derives from moving things (and Petra herself) across that
line at the right moment and place — one easily-communicated rule generating
a large puzzle vocabulary.

**The emotional engine:** early on, the fiction *forces* the player to be
expedient with people they care about. The game then spends its whole
runtime letting the player undo that — at a price, and by choice. Guilt →
power → redemption, expressed entirely through mechanics.

---

## 3. World Structure

### 3.1 Overview

- **7 regions**: 1 hub + 5 major themed areas ("wings," each ~1.5–2 h first
  visit) + 1 final area. Target ~12 h main path, ~16–18 h for full rescue
  (100%).
- **Topology:** Metroidvania — one interconnected map, each wing built
  around one new ability and one Sanctuary. Wings contain authored
  shrine-style puzzle chambers (Zelda-shrine tightness) connected by
  traversal/exploration tissue.
- **Sanctuaries:** each wing has a dormant Sanctuary. Clearing the wing's
  boss/trial **relights it**, which (a) unlocks that wing's permanent-rescue
  capability and (b) grants Petra's next ability — so power and redemption
  always arrive together.
- **Rescue ledger:** a diegetic notebook lists every petrified person Petra
  has *used*, where she left them, and what she'd need to reach/restore
  them. It is the quest log, the 100% tracker, and the emotional core in one
  UI element.

### 3.2 The seven regions

| # | Region | Theme / mechanics | Ability gained here | Signature puzzle flavor |
|---|--------|-------------------|--------------------|------------------------|
| 0 | **Petrified Village** (hub) | Tutorial; statue-as-object basics | **Soften I** (~8 s) | Learn the guilt loop: use your neighbor as a step, promise to return |
| 1 | **The Quarry** | Cracked stone, ramps, rolling physics, cranes | **Chisel Dash** | Break brittle barriers; don't shatter fragile statues; statue-rolling |
| 2 | **Sunken Baths** | Water, buoyancy, weight | **Self-Petrification** | Flesh floats, stone sinks; walk lakebeds; statue stepping-stones |
| 3 | **Gorgon Gardens** | Gaze-cones, mirrors, stealth, hedge mazes | **Harden** (petrify enemies/volunteers) | Reflect gazes back at acolytes; freeze enemies mid-leap as platforms |
| 4 | **Crystal Undercroft** | Darkness, crystal resonance, precision timing | **Remote Soften** (soften at range, mid-air re-freeze) | Freeze a runner at the apex of her jump; chain-soften relays |
| 5 | **Marble Palace** | All systems combined; the Curator's domain | **Soften III / Sustain** (~60 s, multiple targets) | Multi-statue choreography; escort softened NPCs through gauntlets |
| 6 | **The Heart of Stone** (final) | Source of the calamity | **True Restoration** (story) | Final gauntlet remixes every wing's signature puzzle |

Hub placement: the Village sits centrally with shortcut connections opening
back to it from every wing (Dark Souls-style loops), because Petra escorts
rescued NPCs home and the village visibly repopulating *is* the progress bar.

---

## 4. Ability Progression (the Castlevania ladder)

### 4.1 Design rule

Every ability must do double duty: **open new terrain** (Metroidvania gate)
and **expand the puzzle vocabulary** (new verb or a power-up of an old
verb). Softening upgrades are deliberately spread across the whole game —
the *duration of mercy* is the central progression stat.

### 4.2 The ladder, in order

1. **Soften I — "A Few Seconds"** (Village, from the start)
   Revert one petrified NPC to flesh for ~8 s; she resumes exactly what she
   was doing (mid-run, mid-pull, mid-jump), then re-freezes **in her new
   pose and position**. The core puzzle verb: *where, and in what pose, do I
   want this statue?* 8 s is enough to reposition someone — never enough to
   free them. That limit is the story.
   *Gate:* lever-pulls, repositioned platforms.

2. **Chisel Dash** (Quarry Sanctuary)
   Short air-capable dash that shatters *cracked* stone — walls, floors,
   and, tragically, fragile statues if you're careless (they reform at the
   wing's Sanctuary, so no permanent loss, but a fail-forward penalty).
   *Gate:* cracked barriers everywhere; standard dash-gaps.

3. **Self-Petrification** (Baths Sanctuary)
   Petra turns to stone at will (stamina-limited, shown by the marble veins
   on her arm): invulnerable, heavy (sinks, holds plates, immune to wind and
   knockback), can smash cracked floors by petrifying mid-fall — and
   helpless, sliding on slopes as a physics object (which is also a verb:
   statue-toboggan across spike fields).
   *Gate:* underwater walks, pressure plates, wind corridors, crush traps.

4. **Soften II — "Half a Minute"** (mini-Sanctuary, Baths depths, optional-ish)
   Duration → ~25 s. NPCs can now walk *with* you briefly: micro-escorts,
   two-person switch puzzles, a softened guard blocking projectiles as
   mobile cover. First taste of "she's almost back" — and then she isn't.
   Designed as the game's mid-point gut-punch.

5. **Harden** (Gardens Sanctuary)
   Petrify a humanoid enemy or a *consenting* NPC on demand. Enemies become
   physics objects (mid-leap = falling boulder; on a bridge = overload).
   Reflected gorgon gazes count as Harden for puzzle purposes.
   *Gate:* enemy-as-platform gaps; weight puzzles with no statues nearby.

6. **Remote Soften** (Undercroft Sanctuary)
   Soften/re-freeze at range with a thrown chisel-spark, including
   **mid-air re-freeze**: topple a Runner off a ledge, soften her as she
   falls, re-freeze at the apex of her recovery jump — a high platform where
   none existed. Opens the game's hardest optional puzzles.
   *Gate:* out-of-reach statues, timing chambers.

7. **Soften III / Sustain** (Palace Sanctuary)
   ~60 s, up to three simultaneous targets. Full escort choreography;
   softened friends actively help (boost-jumps, lever teams). By now the
   player is powerful enough that using people as objects is a *choice*,
   not a necessity — the game quietly asks whether your habits changed.

8. **True Restoration** (Heart of Stone, endgame/story)
   Break the curse at the source. Everyone still on the rescue ledger can
   now be freed — but reaching many of them requires the full ability kit,
   sending the player on a victory-lap cleanup of every region they once
   moved through as a desperate beginner. Endings tier on rescue count
   (everyone / most / few), with named-NPC vignettes for each rescue.

### 4.3 Backtracking rewards (why re-enter old wings)

- **People, not chests.** The primary collectible is *NPCs you previously
  used*, reachable/restorable only with later abilities — the promise made
  mechanical. (Conventional pickups — Chisel Light capacity, stamina veins,
  outfit palettes — exist as secondary seasoning.)
- Each restored NPC returns to the Village: shops, upgrades, side-vignettes,
  and visible crowd growth.
- Wings get **one new enemy variant** on revisit (stone-wardens re-petrify
  softened NPCs, adding time pressure to old puzzle spaces).

---

## 5. Supporting Mechanics (unchanged from v0.1, summarized)

- **Statue pose archetypes** define affordances: Reacher (grab-ledge),
  Kneeler (step/block), Runner (tips into ramp), Shieldmaiden (mobile
  cover), Dancer (rotatable deflector).
- **Enemies:** female humanoids (gorgon acolytes with gaze cones,
  stone-wardens) and genderless monsters (basilisk hounds, mortar-slimes
  that glue statues, crystal wasps inflicting **partial petrification** —
  stone arm: no ledge-grabs but wall-breaking punches; stone legs: no jump
  but knockback-immune. A debuff that is also a buff).
- **Chisel Light economy:** softening costs a renewable resource; expedient
  play is cheap, merciful play costs effort. The game prices kindness, never
  forces it.
- **Boss concept — The Curator** (Palace): petrifies her own minions to
  build walls; you soften specific "bricks" to collapse her architecture.

---

## 6. Characters & Tone

- **Petra:** early-20s stonemason apprentice; practical, kind, wry. Marble-
  veined arm doubles as the self-petrify stamina UI. Her arc: from "I'm
  sorry, I need your shoulders" to keeping every promise.
- **NPCs:** all female — villagers, guards, priestesses; mentor **Master
  Ida** is the final rescue, petrified mid-gesture of shielding Petra.
  Every named NPC has a frozen-moment vignette (what was she doing when the
  wave hit?) revealed on rescue.
- **Tone:** melancholy-but-warm fairy tale (*Ori* × *The Swapper*).
  Petrification is tragic stillness — dignified poses, no body horror, no
  titillation. Target rating E10+/T.

---

## 7. Tech Stack Recommendation

### Engine: **Godot 4.x** (recommended)

| Need | Why Godot fits |
|------|----------------|
| 2D platformer + physics objects | First-class 2D; `RigidBody2D`/`CharacterBody2D` switching maps directly onto flesh↔stone |
| Statue/flesh visual swap | 2D shaders (petrify = desaturate + stone-noise + rim light on the *same sprite*) are trivial — halves the art budget (§8) |
| Metroidvania map | TileMap + LDtk importer; mature open-source map/minimap addons |
| Solo/AI-assisted dev | GDScript iterates fast; LLMs write competent GDScript |
| PC/Steam | One-click export; Steamworks via GodotSteam; free, MIT, no rev share |

Alternatives: **Unity/C#** viable if you already know C# (heavier, licensing
churn); **GameMaker** fine for pure 2D but weaker physics-object story and
paid exports; **Unreal** not recommended at this scope.

Supporting tools: **LDtk** (levels), **Aseprite/Krita** (+ AI pipeline, §8),
Godot `Skeleton2D` or Spine (skeletal anim), jsfxr/freesound + AI music
(Suno/Udio-class), Git + Git LFS.

---

## 8. AI Art Feasibility — the honest assessment

### 8.1 Go **2D**, not 3D. Strongly.

AI 3D pipelines (text/image-to-3D) still output meshes needing manual
retopo, rigging, and animation cleanup — exactly the artist skills you
lack. 3D puts the hardest art problem at the center of the game; 2D puts
AI's *strongest* capability (stylized stills) there instead.

### 8.2 The theme is an art-budget gift — twice

1. **Petrified variants are shaders, not art**: one stone shader applied to
   existing sprites gives every character a petrified form for free, with
   guaranteed consistency, plus a gorgeous animated petrification wipe.
2. **Statues don't animate.** Your most numerous unique assets (posed
   statue NPCs) sidestep AI's weakest area — frame-to-frame animation
   consistency — entirely.

### 8.3 Difficulty map for AI-generated 2D assets

| Asset type | AI difficulty | Notes |
|---|---|---|
| Backgrounds / parallax | **Easy** | Generate paintings, slice into layers |
| Tilesets | **Medium** | AI drafts → manual seamless-tiling cleanup (~hours/biome) |
| Static statue poses | **Easy-Medium** | No animation needed — the workhorse asset is the easy one |
| Character concept sheets | **Easy** | |
| Character animation cycles | **HARD — the one real risk** | Mitigations in §8.4 |
| UI / icons / items | **Easy** | |
| Music / ambience | **Easy** | Melancholy piano/strings is well within AI range |
| SFX | **Easy** | Stone SFX (grind/crack/chime) carry the fantasy cheaply |
| Voice | **Medium** | Recommend no VO; text vignettes fit tone and budget |

### 8.4 Mitigating the animation problem

1. **Low-res pixel art (recommended): 32–48 px characters.** Run cycles are
   6–8 small frames; AI pixel tools (PixelLab, Retro Diffusion) + Aseprite
   cleanup reach shippable quality. *Celeste* proves small sprites + strong
   shaders + painted backgrounds = beautiful.
2. **Cut-out/skeletal (fallback):** AI generates one character sheet → cut
   into parts → rig in Godot `Skeleton2D`. Zero per-frame art; paper-doll
   stiffness fixable with squash/stretch.
3. **Avoid** high-res hand-drawn frame animation (Cuphead-style).

**Scope control:** Petra ~10 animation sets; NPC archetypes share one
skeleton with 4 sets (idle/walk/run/panic) and palette-swapped outfits;
statues need zero; 3 humanoid + 4 monster enemy types suffice.

### 8.5 Consistency workflow

Lock a **style bible** first (one key image of Petra in the Village; cold
marble whites/teals vs. warm flesh/lantern ambers — the palette encodes the
theme), condition all generation on it (reference images / LoRA on accepted
assets). Budget 20–30% of asset time for manual cleanup — that last 20% is
what makes it not look AI-generated.

---

## 9. Milestones

1. **M0 — Mechanic prototype (graybox, 2–4 wks):** move/jump, Soften I
   reposition puzzle, self-petrify physics, stone shader on placeholders.
   *Validate the fun before any art.*
2. **M1 — Vertical slice (6–8 wks):** Village + Quarry entrance with final
   pipeline art: Petra, 2 NPC archetypes, 1 enemy, rescue-ledger UI,
   first Sanctuary relight.
3. **M2 — Systems complete:** full ability ladder, all enemy types, 3 wings.
4. **M3 — Content complete → polish → Steam Next Fest demo.**

---

## 10. Open Questions

- Exact Soften durations/costs need prototyping — 8 s is a guess; the right
  number is "just too short to feel like freedom."
- Should any rescue be missable/failable, or is everyone always eventually
  savable? (Recommend: always savable — the promise must be keepable; tiered
  endings come from *how many you bothered to go back for*, not permadeath.)
- Fast travel: none / Sanctuary-to-Sanctuary / late unlock? (Leaning
  Sanctuary-to-Sanctuary after each relight — escorting rescued NPCs home
  shouldn't be tedious.)
- Name/branding pass on the title.
