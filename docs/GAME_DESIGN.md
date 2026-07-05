# Petr-Platformer — Game Design Document (v0.1)

**Working title:** *Gorgon's Garden* (placeholder)
**Genre:** 2D puzzle-platformer
**Platform:** PC (Windows/Linux, Steam-first)
**Team assumption:** solo/small team, programmer-led, art produced primarily with AI assistance

---

## 1. High Concept

You play **Petra**, a young stonemason's apprentice in a kingdom slowly turning to
stone. A gorgon-like calamity has petrified most of the population — including
Petra's mentor and friends. Petra carries a cursed chisel-amulet that lets her
**partially reverse, redirect, and even invoke petrification**. The petrified
people of the kingdom are not obstacles or set dressing: **they are your tools,
your platforms, your shields — and your responsibility.**

The emotional hook: every statue you climb on, push into a pit, or use to block
a laser is *a person you intend to save*. The mechanical hook and the narrative
hook are the same object.

---

## 2. Why Petrification? (The Distinguishing Pillar)

Most platformers treat NPCs as dialogue vendors and enemies as obstacles.
Here, **solidification converts characters between two ontologies**:

| State | Behaves like | Used for |
|-------|--------------|----------|
| Flesh (animate) | AI agent — walks, follows, panics, helps | Escort, cooperation, lure |
| Stone (solid) | Physics object — heavy, rigid, durable | Platform, weight, shield, plug, projectile |

Every core mechanic derives from moving things (and yourself) across that line
at the right moment and place. This gives a large puzzle vocabulary from one
single, easily-communicated rule — the mark of a strong puzzle game.

---

## 3. Core Mechanics

### 3.1 Petra's abilities (gained progressively)

1. **Soften (De-petrify, partial)** — Petra can temporarily soften a petrified
   NPC back to flesh for ~10 seconds (upgradeable). The NPC resumes whatever
   they were doing when petrified — mid-run, mid-jump, mid-lever-pull. When the
   timer ends they re-freeze **in their new pose and position**. This is the
   central puzzle verb: *"where and in what pose do I want this statue to be?"*
2. **Harden (Petrify)** — Later, Petra can petrify a willing NPC or a
   (humanoid) enemy on demand. Petrifying an enemy mid-leap turns it into a
   falling boulder; petrifying it on a bridge overloads the bridge.
3. **Self-Petrification** — Petra can turn herself to stone (limited stamina):
   - **Invulnerable** to hits, fire, and petrifying gazes while stone.
   - **Heavy**: she sinks in water (walk along the bottom), holds down pressure
     plates, isn't pushed by wind or conveyors, and can smash through cracked
     floors by petrifying mid-fall.
   - **Helpless**: she cannot move while stone; petrify at the wrong moment on
     a slope and she slides/rolls as a physics object — which is *also* a
     mechanic (statue-rolling down ramps to cross spike fields).
4. **Chisel Dash** (mid-game) — a short dash that shatters *cracked* stone
   barriers but would shatter a fragile statue too — introducing "don't hit the
   wrong target" precision puzzles.

### 3.2 Petrified NPCs as puzzle objects

The statue-people (all female villagers, guards, priestesses — see §5) come in
**pose archetypes** that define their physical affordances:

- **The Reacher** — arms outstretched: her hands are a grab-ledge / monkey bar.
- **The Kneeler** — low and stable: a stepping block, fits under low gaps when
  pushed.
- **The Runner** — frozen mid-stride, off-balance: tips over when nudged,
  becoming a ramp or a bridge across a gap.
- **The Shieldmaiden** — guard with raised shield: blocks projectiles and
  petrifying gaze-beams; soften her and she *walks forward while blocking*,
  becoming a mobile cover escort segment.
- **The Dancer** — frozen mid-spin on one toe: rotates when pushed, redirecting
  things that bounce off her (light beams, thrown objects).

Statues can be **pushed, toppled, rotated, softened-and-repositioned, dropped,
floated (on rafts), and weighed**. Water interactions matter: statues sink and
become underwater stepping stones; flesh NPCs float and can swim.

### 3.3 Enemy design

- **Humanoid (female):** Gorgon acolytes with **petrifying gaze cones** —
  line-of-sight stealth/mirror puzzles (reflect the gaze back to petrify *them*,
  then use their statue). Stone-wardens who *repair/re-petrify* NPCs you've
  softened, creating time pressure.
- **Genderless monsters:** Basilisk hounds (gaze on a patrol timer), living
  mortar-slimes that *glue* statues in place, crystal wasps whose sting
  petrifies Petra's limbs one at a time (partial petrification debuff: stone
  arm = can't grab ledges but punches break walls; stone legs = can't jump
  but immune to knockback). Partial petrification as a *debuff that is also a
  buff* is a signature system few games attempt.

### 3.4 The permanence dial (risk/reward)

Softening an NPC costs **Chisel Light**, a resource found in levels. You can
finish a level using statues purely as objects (cheap, expedient) or spend
extra light and effort to walk each NPC to the level's **Sanctuary**, where
they're permanently restored. Restored NPCs repopulate the hub town, open
shops/upgrades, and change the ending. **The game never forces kindness — it
prices it.** That choice architecture is the memorable, talked-about feature.

---

## 4. Level & Puzzle Design Structure

- **Structure:** Metroidvania-lite — an interconnected kingdom (5 biomes) with
  ability-gated backtracking, but each "shrine" area is a contained puzzle
  chamber (Zelda-shrine style) so puzzles stay authored and tight.
- **Biomes:** Petrified Village (tutorial), Sunken Baths (water/weight),
  Gorgon Gardens (gaze/stealth/mirrors), The Quarry (physics: ramps, cranes,
  rolling), Marble Palace (all systems combined + partial-petrification
  gauntlets).
- **Puzzle escalation example (Softening):**
  1. Soften a Runner so she stumbles forward two steps → re-freezes as a bridge.
  2. Soften her *while a wind fan blows* → she's pushed further than she'd walk.
  3. Soften her mid-air after toppling her off a ledge → she lands, runs, and
     you must re-freeze her (ability #2) at the apex of her jump to make a
     high platform.
- **Boss concept:** *The Curator* — a gorgon who petrifies waves of her own
  minions to build walls; you soften specific "bricks" to collapse her
  architecture on her.

---

## 5. Characters & Tone

- **Petra (player):** early-20s stonemason apprentice; practical, kind, wry.
  Visual signature: chalk-dust hair, glowing chisel-amulet, one permanently
  marble-veined arm (from her first accident) — a built-in UI: the veins glow
  as self-petrify stamina.
- **NPCs:** all female — villagers, guards, priestesses, Petra's mentor
  **Master Ida** (the final rescue). Each rescued NPC has a name and a short
  memory-vignette (frozen moments: what were they doing when the wave hit?),
  which makes the "statue = person" theme land.
- **Tone:** melancholy-but-warm fairy tale (think *Ori* meets *The Swapper*'s
  quiet unease). Petrification is portrayed as tragic stillness, not body
  horror and not titillation — poses are dignified/human (reaching for a door,
  shielding a child-doll, mid-dance). This keeps ratings friendly (aim: E10+/T)
  and keeps the emotional register coherent.

---

## 6. Tech Stack Recommendation

### Engine: **Godot 4.x** (recommended)

| Need | Why Godot fits |
|------|----------------|
| 2D platformer + physics objects | First-class 2D engine; `RigidBody2D`/`CharacterBody2D` switching maps directly onto flesh↔stone state changes |
| Statue/flesh visual swap | 2D shaders (petrify = desaturate + stone-noise + rim light on the *same sprite*) are trivial in Godot's shader language — see §7, this halves the art budget |
| Solo/AI-assisted dev | GDScript is fast to iterate; excellent for programmer-led teams; Claude/LLMs write competent GDScript |
| PC/Steam export | One-click Windows/Linux export, Steamworks via GodotSteam |
| Cost | Free, MIT license, no revenue share |

**Alternatives considered:**
- **Unity (C#):** viable, bigger asset store, but heavier, licensing churn, and
  overkill for 2D. Choose it only if you already know C# well.
- **GameMaker:** great pure-2D platformer feel, but weaker physics-object story
  and paid export licenses.
- **Unreal:** not recommended — 3D-first, huge overhead for this scope.

### Supporting tools

- **Level editing:** Godot's built-in TileMap **+ LDtk** (free, excellent for
  metroidvania layouts, has a Godot importer).
- **Sprite/animation:** **Aseprite** (pixel art) or **Krita** (painted), plus
  AI generation pipeline (§7). If using skeletal animation: **Spine** (paid) or
  Godot's built-in `Skeleton2D` (free, adequate).
- **Audio:** Godot's built-in audio; SFX via **jsfxr/ChipTone** + freesound;
  music via AI (Suno/Udio) or licensed packs. Stone SFX (grinding, cracking,
  chiming) are cheap to source and *hugely* carry the petrification fantasy.
- **Version control:** Git + Git LFS for art (already in place).

---

## 7. AI Art Feasibility — the honest assessment

This decision matters more than the engine. Ranked by achievability today:

### 7.1 Go **2D**, not 3D. Strongly.

AI-generating a coherent, rigged, animated **3D** female character (plus stone
variants, plus enemies) is still the weakest AI pipeline: current
image-to-3D/text-to-3D tools (TripoSR/Meshy/Tripo-class) produce meshes needing
manual retopo, rigging, and animation cleanup — exactly the artist skills you
lack. **3D would put the hardest art problem at the center of your game.**
2D puts AI's *strongest* capability (stylized still images) at the center.

### 7.2 The petrification mechanic is an art-budget *gift*

Petrified variants should be **shaders, not new art**: one stone shader
(desaturate → marble-noise overlay → cracked normal lines → cold rim light)
applied to the *existing* sprite gives every NPC, enemy, and Petra a
petrified form for free, guarantees visual consistency, and lets you animate
the petrification sweep (a mask wipe) — which looks fantastic and costs zero
art. This single decision roughly halves the character art budget.

### 7.3 Difficulty map for AI-generated 2D assets

| Asset type | AI difficulty | Pipeline notes |
|---|---|---|
| Backgrounds, parallax layers | **Easy** | Best-case AI use. Generate large paintings, slice into layers. |
| Tilesets | **Medium** | AI drafts → manual cleanup for seamless tiling (few hours/biome in Aseprite). Tools like PixelLab help. |
| Static statue poses | **Easy-Medium** | Statues don't animate — AI's weakness (temporal consistency) doesn't apply. Your most numerous unique asset is also the easiest. Another gift of the theme. |
| Character *design* (concept sheets) | **Easy** | AI excels at concepting Petra, enemies, NPCs. |
| Character *animation* (run/jump/climb cycles) | **HARD — the one real risk** | Frame-to-frame consistency is AI's weakest 2D area. Mitigations below. |
| UI, icons, item art | **Easy** | |
| Music/ambience | **Easy** | Suno/Udio-class output is genre-adequate for a melancholy piano/strings score. |
| SFX | **Easy** | Libraries + light editing. |
| Voice (if any) | **Medium** | Recommend no VO; text + vignettes fit the tone and budget. |

### 7.4 Mitigating the animation problem (pick one style early)

1. **Low-res pixel art (recommended): 32–48 px characters.** At this
   resolution a run cycle is 6–8 small frames; imperfections read as charm, and
   AI pixel tools (PixelLab, Retro Diffusion) plus a weekend of Aseprite
   tweaking per character gets shippable results. *Celeste* proves small
   sprites + strong shaders + good backgrounds = beautiful.
2. **Cut-out/skeletal (fallback):** AI generates one high-quality character
   sheet → you cut into parts → rig in Godot `Skeleton2D`. No per-frame art at
   all; slightly "paper-doll" motion, fixable with squash/stretch. Best option
   if you want painted *Hollow Knight*-ish fidelity without frame animation.
3. **Avoid:** high-res hand-drawn frame animation (Cuphead-style). Not
   achievable with AI + non-artist cleanup.

**Scope control:** Petra needs ~10 animation sets; each NPC archetype needs
only *idle/walk/run/panic* (4 sets, shared skeleton, palette-swapped outfits);
statues need **zero**. Enemies: 3 humanoid + 4 monster types is enough for a
10-hour game.

### 7.5 Consistency workflow

- Lock a **style bible** first: one AI-assisted key image of Petra in the
  village, chosen palette (cold marble whites/teals vs. warm flesh/lantern
  ambers — the palette itself encodes the flesh/stone theme), then condition
  all further generation on it (reference images / LoRA fine-tune on your
  accepted assets).
- Budget ~20–30% of asset time for manual cleanup in Aseprite/Krita. AI gets
  you 80% of the way; the last 20% is what makes it not look AI-generated.

---

## 8. Suggested Milestones

1. **M0 — Mechanic prototype (graybox, 2–4 wks):** Petra move/jump,
   self-petrify physics, one soften-and-reposition puzzle, stone shader on
   placeholder squares. *Validate the fun before any art.*
2. **M1 — Vertical slice (6–8 wks):** Petrified Village tutorial with final
   pipeline art for Petra + 2 NPC archetypes + 1 enemy, sanctuary/rescue loop.
3. **M2 — Systems complete:** all abilities, all enemy types, 2 biomes.
4. **M3 — Content complete → polish → Steam Next Fest demo.**

---

## 9. Open Questions

- Metroidvania interconnection vs. pure level-select (affects scope ±30%).
- Should enemy petrification of Petra ever be *permanent* (roguelite death) or
  always checkpoint-recoverable? (Recommend recoverable; permanence stays a
  thematic threat via NPCs, not a player punishment.)
- Name/branding pass on the title.
