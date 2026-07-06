# Petr-Platformer — Game Design Document (v0.4)

**Working title:** *Gorgon's Garden* (placeholder)
**Genre:** 2D puzzle-platformer / Metroidvania
**Platform:** PC (Windows/Linux, Steam-first)
**Team assumption:** solo/small team, programmer-led, art produced primarily with AI assistance

---

## 1. High Concept

You play **Amethyst**, a young stonemason's apprentice in a kingdom turned to
stone by a gorgon-like calamity. Amethyst was spared, and she carries her
mentor's chisel-amulet — a relic that can **revert petrification, but only
briefly and only barely**. From the very first minute her goal is stated
plainly: *save everyone*. But her power is nowhere near enough. A softened
friend returns to flesh for mere seconds before the curse reclaims her.

So Amethyst does the only thing she can: she **uses her petrified friends as
tools** — climbs them, topples them, drops them onto switches — whispering
the same promise each time: *"I'll come back for you."* The game's structure
makes that promise real: as Amethyst's power grows, she physically returns to
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

Every mechanic derives from moving things (and Amethyst herself) across that
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
  boss/trial **relights it**, which grants Amethyst's next ability and opens a
  safe route home — but it never frees anyone by itself. **Rescue is always
  an act the player performs, one person at a time** (see §4.3). Area
  clearance gives you the *means*; the mercy stays yours to do.
- **Rescue ledger:** a diegetic notebook lists every petrified person Amethyst
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
| 6 | **The Heart of Stone** (final) | Source of the calamity | — (finale; outcome varies, §4.5) | Final gauntlet remixes every wing's signature puzzle |

Hub placement: the Village sits centrally with shortcut connections opening
back to it from every wing (Dark Souls-style loops), because Amethyst escorts
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
   Amethyst turns to stone at will (stamina-limited, shown by the marble veins
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

8. **The Finale** (Heart of Stone, endgame/story)
   Confront the curse at its source. What happens there — and to the
   Anchored, the unrescued, and Amethyst herself — depends on the Rescue and
   Truth counters (§4.5). The point of no return is clearly marked, and the
   game invites a final victory-lap of unfinished rescues before it.

### 4.3 Rescue mechanics — how someone actually gets saved

Rescue is never automatic and never a menu action. To save someone, Amethyst
must **soften her and get her to safety within the soften window**:

- Every wing has **Waystones** (small shrine exits, plus the Sanctuary
  itself). A softened NPC who reaches a Waystone before re-freezing is
  **teleported safely to the Village** — permanently saved.
- Early Soften windows (8 s) make this impossible; that's the point. As
  windows grow (25 s → 60 s), rescues become *escort puzzles*: the player
  must first clear and prepare the route (open gates, remove wardens,
  pre-position other statues as steps for the running NPC), then soften and
  shepherd her home. **Preparing a rescue is the puzzle; the run itself is
  the payoff.**
- NPC ledger classification:
  - **Walkers** (~majority): rescuable by escort once the player has enough
    Soften duration and has solved the route. These are the Metroidvania
    backtracking content — the promise made mechanical.
  - **Anchored** (~a quarter, marked by curse-light veins): their
    petrification is bound directly to the curse's source. **No soften
    window frees them — ever — until the curse itself is wiped in the
    finale.** Deliberately, these are the statues the level design makes
    you *use* the most (bridges, weights, shields), so the people you owe
    the greatest debt are precisely the ones you cannot save early. The
    ledger shows them with an unbreakable chain icon leading to the Heart
    of Stone.
  - **Witnesses** (~6 named Walkers): each holds a fragment of the truth
    about the calamity. Their testimony is only heard if they're rescued
    (flesh, in the Village) — the currency of the true ending (§4.5).

**Chained Soften and the Grace rule.** Movement is continuous across
softens: re-softening a re-petrified NPC resumes her exactly from her
current pose and position — there is no rewind. That would allow escorting
anyone across the whole map with repeated low-level Softens (an earlier
"stone-heat" cooldown design only slowed this; it never bounded it), so
the limit is absolute: each petrified person has a finite reserve of
**Grace** — the total time the amulet can hold the curse off *her*,
across all softens combined (~12 s at Soften I). When her Grace is spent,
she cannot be softened again **until Amethyst unlocks the next Soften
tier**, which deepens every person's reserve (Soften II ~40 s, Soften III
~120 s). Grace makes the promise mechanical twice over: total displacement
per person is strictly bounded per tier, and a rescue is a *budgeted run* —
she must reach a Waystone before her remaining Grace runs out, so seconds
wasted using her earlier are seconds missing when you come back to save
her. The ledger shows each person's remaining Grace.

**Stone-dreaming (softened behavior).** A softened person is not truly
awake: she is a sleepwalker who **follows the amulet's light** — Amethyst
herself — blindly and trustingly, off ledges, into water (she sinks;
stone dreams don't swim), and up against Amethyst's own body if she stands
in the way (blocking with your body is a legitimate positioning tool).
This is why she can be lured to where the puzzle needs her, why escorting
her is literal shepherding, and why using her never feels like commanding
a robot — she trusts you, which is exactly what makes it hurt.

**Position persistence.** In the open world, statue positions **persist**
across room transitions and save/load — the ledger records where you left
each person, and finding her exactly there (even awkwardly mid-stride where
your puzzle needed her) is the guilt made spatial. Authored puzzle chambers
are the exception: each has a **reset chime** that returns that chamber's
statues to their original stations (softlock insurance). Fiction: shrine
chambers were built by the Sanctuary priestesses as warded training halls —
within the ward, the curse snaps its victims back to their "frozen moment"
when it re-asserts. This also explains why chamber NPCs can't simply be
walked out the door: only a Waystone's teleport breaks the ward's pull.

Secondary backtracking seasoning: Chisel Light capacity, stamina veins,
outfit palettes; wings gain one new enemy variant on revisit (stone-wardens
re-petrify softened NPCs, adding time pressure to rescue runs).

### 4.4 The Village as living progress bar

Each rescued NPC appears in the Village: shops, upgrades, side-vignettes,
visible crowd growth — and Witnesses add entries to a **Fresco Hall** where
the true history of the calamity is assembled piece by piece.

### 4.5 Endings

Ending selection is driven by two independent counters — **Rescue count**
(Walkers saved) and **Truth count** (Witness testimonies heard) — plus the
player's conduct in the final confrontation. All routes are visible in the
ledger before the point of no return, and the game warns clearly at the
final door.

| Ending | Conditions | Outcome |
|---|---|---|
| **Bad — "The Last Statue"** | Enter the finale badly under-prepared (few rescues, no truths) *or* fail/choose the sacrifice at the climax | Amethyst's amulet cannot contain the curse's rebound; she seals it **by petrifying herself around it, permanently**. The Village survivors she did save hold a vigil at her statue. Not a game-over screen — a full, scored ending with credits. |
| **Mediocre — "A Quieter Kingdom"** | Beat the finale with partial rescues; truth incomplete | The curse's source is destroyed but its residue never lifts: all un-rescued Walkers and **all Anchored NPCs remain stone forever**, weathering in the epilogue montage. The Village lives, diminished. The ledger's unfilled pages turn in the wind. |
| **Good — "Everyone Comes Home"** | **All Walkers rescued** before the finale, then win | The curse is **fully wiped out at the source** — the only force that can free the Anchored. Epilogue: every Anchored statue wakes where she stood; Amethyst walks each old route one last time as they stream home. |
| **True — "The First Statue"** | Good-ending conditions **+ all 6 Witness truths** | The truths reveal the curse's origin — the gorgon was herself the *first* victim, a priestess petrified from the inside out. Armed with the whole story, Amethyst gets a different final confrontation: instead of destroying the source, she performs the game's final Soften on the gorgon herself. Everyone is saved — **including the monster.** Post-credits: the ledger's last page, every name crossed out, one name added. |

Design rules: the bad ending is authored content (poignant, not punitive) so
even "failure" is worth seeing; mediocre is the natural first-playthrough
result and doubles as NG+ motivation; good is 100% rescue; true is good +
paying attention to *people* rather than just collecting them — which is
the game's whole argument.

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

- **Amethyst** (full name always — no nickname): early-20s stonemason
  apprentice; practical, kind,
  wry. Long purple hair — her visual signature — plus a marble-veined arm
  that doubles as the self-petrify stamina UI. Her arc: from "I'm sorry, I
  need your shoulders" to keeping every promise.
- **NPCs:** all female — villagers, guards, priestesses; mentor **Master
  Ida** is the final rescue, petrified mid-gesture of shielding Amethyst.
  Every named NPC has a frozen-moment vignette (what was she doing when the
  wave hit?) revealed on rescue.
- **Tone:** melancholy-but-warm fairy tale (*Ori* × *The Swapper*).
  Petrification is tragic stillness — dignified poses, no body horror, no
  titillation. Target rating E10+/T.
- **Presentation:** two registers of storytelling. *Ambient* — inspect (F)
  lines, Amé monologue, softened murmurs, delivered through the message
  bar without stopping play. *Skits* — gameplay pauses for dialogue with
  bust/full-body character art (petrified variants via the stone shader
  in prototype; dedicated stone portraits in production, §8.5). The HUD
  keeps a persistent full-body Amé figure that petrifies in sync with her
  state — the normal/petrified pair every character's art already has.

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

1. **Petrified *sprite* variants are shaders, not art**: at 32–48 px, one
   stone shader applied to existing sprites gives every character a
   petrified form for free, with guaranteed consistency, plus an animated
   petrification wipe. (Narrative art — busts and CGs — is held to a higher
   standard; petrified versions there are dedicated images, see §8.5.)
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

**Scope control:** Amethyst ~10 animation sets; NPC archetypes share one
skeleton with 4 sets (idle/walk/run/panic) and palette-swapped outfits;
statues need zero; 3 humanoid + 4 monster enemy types suffice.

### 8.5 Event art: portraits, avatars, and CGs — quantified workload

With named NPCs, Witness testimonies, rescue vignettes, and four endings,
the game needs **narrative art** beyond sprites. This is static, single-image
work — squarely in AI's comfort zone — but volume and *cross-image character
consistency* must be budgeted deliberately.

**Inventory (target scope):**

| Asset | Count | AI difficulty | Notes |
|---|---|---|---|
| Amethyst dialogue bust + expressions | 1 base × ~8 expressions | Medium | Main character: train a LoRA on her accepted key art first; expressions via inpainting the face region only |
| Named-NPC dialogue busts | ~24 characters × 3 expressions ≈ 72 | Medium | One base per character, 2 extra expressions by face-inpaint. Shared body templates with outfit/palette variation keep them cheap and coherent |
| **Petrified bust variants** | ~25 (named NPCs) | Easy-Medium | A gray shader is *not* good enough at portrait scale — statues need carved-surface reading: unified marble/granite material, chiseled hair masses, blank or veined eyes, drapery-like clothing folds, cracks and weathering. These are **dedicated images derived from the flesh bust** via structure-preserving image-to-image (same lineart/pose via ControlNet-lineart or an image-edit API, restyled coloring) — far cheaper than from-scratch art (~15–30 min each once dialed in) while keeping the two versions recognizably *the same person*, which is the emotional point. Dialogue with a statue (Amethyst talking at her frozen friend) is a signature scene type |
| Major-character full-body art | ~8 (Amethyst, Ida, Curator, gorgon, 4 Witnesses) | Medium | Used in key events and the ledger's character pages |
| Event CGs (full-scene illustrations) | ~14–18 | Easy-Medium | Opening calamity (2–3), first forced "use" of a friend (1), Soften II gut-punch (1), Sanctuary relights (reuse 1 template × palette, 1–2), ending sets: bad 2, mediocre 2, good 3, true 3–4 |
| Rescue vignettes (per named NPC) | ~24 | Easy | **Do these as fresco/stained-glass panels**, not realistic scenes: a stylized "frozen moment" format is thematically perfect (stone imagery), hides AI's consistency weaknesses, and one strong style prompt makes all 24 feel like a set |
| Fresco Hall truth panels | 6 | Easy | Same fresco pipeline as vignettes |

**Total: roughly 145–170 unique AI-generated images**, of which ~120 are
busts/vignettes produced by repeatable pipelines. At a realistic AI-assisted
rate for a non-artist (generate → select → inpaint fixes → cleanup ≈ 0.5–2 h
per accepted image once the pipeline is dialed in), this is **4–8 weeks of
part-time work** — very feasible, but it should be treated as a real
milestone, not an afterthought.

**Consistency tactics (the actual risk, and its mitigations):**

1. **LoRA per major character** (Amethyst + ~4 story-critical faces), trained
   on their accepted key art. Minor NPCs don't need LoRAs — they appear in
   few images, and their bust *is* their canonical look.
2. **Expressions by inpainting, never regeneration**: keep the bust fixed,
   repaint only eyes/mouth. This is the single biggest consistency win.
3. **Design for consistency**: give every named NPC one high-contrast
   identifier (hair silhouette, headscarf, guard pauldron) that survives
   AI drift; the eye forgives a changed face far more than a changed
   silhouette.
4. **Stylize the hard cases**: anything requiring multiple characters
   interacting in one frame (the classic AI failure) goes to the fresco
   format or to sprite-based in-engine cutscenes instead of CGs.
5. Sprite-based cutscenes are the default storytelling mode; CGs are
   reserved for the ~18 moments listed. Keeping CG count disciplined is
   what keeps the 4–8 week estimate honest.

### 8.6 Generation pipeline integration

The coding assistant (a text model) cannot generate images itself; it
writes and maintains the **generation tooling** instead. Plan: a small
`tools/artgen/` Python package driving whatever image API is available
(OpenAI-style `images/generations` + `images/edits`, or a local ComfyUI
for ControlNet workflows):

- `characters/*.yaml` — one sheet per character (appearance tags, palette,
  identifier feature, LoRA/reference-image pointer) → prompt templates.
- `generate.py` — batch text-to-image for new assets (N candidates per
  slot, saved under `art/candidates/` for human selection).
- `derive.py` — structure-preserving image-to-image: petrified bust from
  flesh bust, expression variants by face-region inpaint.
- API key from an environment variable; keys never committed. Accepted
  images move to `art/final/` with their generation metadata sidecar
  (prompt, seed, source) so any asset can be regenerated or restyled later.

### 8.7 Consistency workflow

Lock a **style bible** first (one key image of Amethyst in the Village; cold
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
   pipeline art: Amethyst, 2 NPC archetypes, 1 enemy, rescue-ledger UI,
   first Sanctuary relight.
3. **M2 — Systems complete:** full ability ladder, all enemy types, 3 wings.
4. **M3 — Content complete → polish → Steam Next Fest demo.**

---

## 10. Open Questions

- Exact Soften durations/costs need prototyping — 8 s is a guess; the right
  number is "just too short to feel like freedom."
- Within a playthrough, no Walker rescue is permanently missable before the
  point of no return (a botched escort just re-freezes her in place, ledger
  updated). Confirm there's no level-design state that can strand a Walker
  unreachably.
- Should the bad ending be reachable *only* by explicit choice at the
  climax, or also by failing the final gauntlet? (Leaning: both funnel into
  the same authored scene, so failure is never a cheap game-over.)
- Fast travel: Waystone-to-Waystone after each Sanctuary relight — rescue
  escorts must stay tense, but *reaching* the escort shouldn't be tedious.
- NG+ carry-over (keep abilities, reset rescues?) to make true-ending runs
  pleasant.
- ~~Heroine rename~~ **Resolved:** the heroine is **Amethyst**, after the
  violet quartz — matching her long purple hair. Full name used
  everywhere; nicknames dropped as awkward to pronounce/type.
- Name/branding pass on the title.
