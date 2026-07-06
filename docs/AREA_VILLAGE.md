# Area design — The Petrified Village (Region 0, tutorial wing)

The Village teaches the operation basics and seeds the key lore, one idea
per room, then opens into the wider map. It is also the hub the game
returns to forever (rescued NPCs repopulate it), so its layout must stay
legible after fifty visits.

## Area map

```
                      [Sanctuary (dark)]     [Bell Tower]
                             │                    │ (optional)
   [V1 The Street]──[V2 Well Yard]──[V3 Sanctuary Steps]──[V4 The Square]──→ Quarry gate (sealed)
         │                                                      │
   [V0 Cellar]                                          Baths stair (flooded)
    (hidden)
```

In-game map shapes (see `map.gd`): V1/V2 wide 2×1 rooms, V3 tall 1×2
(the climb), V4 large 2×2, V0 a faint unlabeled 1×1 outline under V1 —
the map hints at hidden space without confirming it.

## Rooms

| Room | Shape | Teaches (exactly one thing) | Lore beat | Status |
|---|---|---|---|---|
| **V1 The Street** | wide, flat | move/jump → inspect (F) → Soften + follow → statue-as-step | The wave; Lina (the personal stake); anchored Petra (some can't be helped *yet*) | built (room 3) |
| **V0 The Cellar** | small, hidden | "come back later" — a cracked floor nothing in the Village can break; opens only with Self-Petrification (Baths ability) | Where Amethyst survived; Master Ida's workshop, her absence | stub built under V1 |
| **V2 Well Yard** | wide, one pit | Waystone rescue vs. spending a person; Grace is finite | Marla (hope: rescue works); Sena (the cost); the thesis: *save one, use one* | built (room 4) |
| **V3 Sanctuary Steps** | tall climb | Anchored statues as permanent terrain; Chisel Light motes; optional rescue (Odile's long walk) | The dark Sanctuary — the wing's goal made visible and locked | built (room 5) |
| **V4 The Square** | large, open | nothing — a breather | The tableau of the wave's moment (anchored statues mid-life); four branches: Steps, Bell Tower, sealed Quarry gate, flooded Baths stair; rescued NPCs gather at the fountain | built (room 6) |
| **V5 Bell Tower** | narrow, vertical | nothing new — optional platforming test | View of where the wave came from (gorgon foreshadow, 2-line skit); mote cache | built (room 7) |

Progression: V1 → V2 → V3 → V4 (wing complete; Quarry gate is the next
region, Baths stair floods until its ability matters). V0 and V5 are
optional. The Sanctuary above V3 relights at the wing's end (M1 content)
and grants the next ability.

## Engine status

- ~~Fixed spawn per room~~ **Done:** doors carry a target entry id and
  every room spawns the player at the matching entry point; all village
  connections are two-way (3⇄4⇄5⇄6⇄7).
- **Save/load:** rescues, story flags, visited rooms, and key items
  autosave to `user://petr_save.json` on every room change; the game
  resumes in the saved room. F2 wipes the save (new game).
- **Key items persist** (amulet, motes) across resets and saves.
- **Pushing is gated** behind Mason's Grip (Village Sanctuary reward,
  not yet obtainable in the slice) so the tutorial stays Soften-pure;
  dev rooms 1/2 have it enabled for testing. First blocked shove gives
  a one-line message.
- The cellar's cracked floor is intentionally unbreakable in the Village
  slice (Self-Petrification is a later ability); a one-shot message
  tells the player so ("Nothing she can do about it. Yet.").

## Pacing rules (apply to every future area)

1. **One new idea per room.** Demonstrate before naming: the player
   pushes a statue before any text calls it a mechanic.
2. **Skit budget:** ≤4 lines per skit, ≤3 skits per room (V1's three are
   the intro exception; V4 has zero — breathers follow dense rooms).
3. **Text budget:** ≤3 persistent world labels visible per screen, each
   ≤3 words, small and dim. NPC name tags only within ~140 px. Anything
   longer is an inspect line, a one-shot message, or a skit.
4. **Every room contains one thing you cannot have yet** (V0's cracked
   floor, Petra, the Sanctuary door, the sealed gate) — the Metroidvania
   promise is taught by wanting, not by tutorial text.
5. **Rescue rhythm:** each room after V1 offers at most one rescue;
   early rescues must be *almost* effortless (Marla) before they are
   costly (Odile), before they are impossible (Anchored).

## Lore drip order

1. V1: what happened (the wave), who it took (Lina), and that some stone
   is beyond the amulet (Petra, anchored).
2. V2: rescue is possible (Marla) and rescue has a price (Sena).
3. V3: where power comes from (the dark Sanctuary) — the wing's quest.
4. V4: what was lost at scale (the tableau) — wordless.
5. V0/V5 (optional): who Amethyst is; where the wave came from.
Names to hold back until later wings: the gorgon, Ida's fate, the
Curator, Grace's true nature.
