# Area design — The Quarry (Region 1)

Theme sheet in `docs/AREAS.md` (stone-as-labor; ochre/rust/bone palette;
mortar-slimes and quarry wisps; boss: the Foredame; ability: Chisel
Dash). Entry: the Square's east gate, opened by **Mason's Grip**.

**Structural rule — the Quarry is not linear.** Two parallel routes (the
high *scaffold line* and the low *haul road*) run east and cross at
three points: the Gate Terraces (start), the Crane Yard's drop shaft
(one-way, high→low), and the Switchback (a climbable junction). The
player picks a route, changes their mind mid-region, and the map keeps
them oriented.

## The full graph (11 rooms; built rooms in CAPS)

```
 high:      ┌──[CRANE YARD]────[SCAFFOLD HEIGHTS]──┐
            │        │drop                          │
 Square──[GATE       ▼                        [SWITCHBACK]──[Wisp Gallery]──[Colossus Shelf]──[FOREDAME'S DIG]
          TERRACES]──[HAUL ROAD]───[THE CUT]───────┘               │                                │
 low:                                                        (Powder Store,                 [QUARRY SANCTUARY]
                                                              hidden below)                  → Chisel Dash
```

| # | Room | Route | Content |
|---|------|-------|---------|
| Q1 | **GATE TERRACES** (room 9) | branch | climb the slabs (→ Crane Yard) or walk the road (→ Haul Road); Brona (rescue), the surveyor (anchored), Waystone |
| Q2 | **CRANE YARD** (room 10) | high | counterweight plate — only Hetta is heavy enough; jumpable **drop shaft** falls to the Haul Road (one-way crossing) |
| Q3 | **SCAFFOLD HEIGHTS** (room 16) | high | plank climb to the high gallery; the rigger (anchored); fall = safe drop to floor, walk back |
| Q4 | **HAUL ROAD** (room 17) | low | long flat road under the shaft; Rutta (rescue), Waystone |
| Q5 | **THE CUT** (room 11) | low | deep excavation; quarry block through the cracked seam → hidden cavity; Vess (rescue), the digger twins (anchored), Waystone |
| Q6 | **SWITCHBACK** (room 18) | junction | zigzag connecting low (bottom door) and high (top door); the Depths seal east |
| Q7 | Wisp Gallery | planned | quarry wisps drain Chisel Light; light-preservation runs |
| Q8 | Powder Store | planned, hidden | below the Gallery, behind a cracked wall (Dash) |
| Q9 | Colossus Shelf | planned | half-carved colossus blocks; rolling-ramp physics; the Witness (Sableth the forewoman) |
| Q10 | Foredame's Dig | planned | boss: the Foredame |
| Q11 | Quarry Sanctuary | planned | relight → **Chisel Dash** → back-unlocks the Village cellar |

Rescue budget: 3 rescuable (Brona, Rutta, Vess — each with own
Waystone) + 1 Witness later; 3 anchored set pieces so no room can be
emptied of usable stone.

## Door conventions (all areas)

- **Edge doors**: walk-through, 24×80, flush at x=0 / x=1256, standing
  on their floor (or ledge). Never two on the same edge at the same
  height.
- **Interior doorways** (buildings, shafts into rooms): press **F** to
  enter, so they can never swallow a player walking past.
- **Vertical drops**: open shafts, jumpable-across (≤100 px), clearly
  labeled; falling in is a deliberate route choice.

## Sample rooms (dev, keys `[`/`]`, rooms 12–15)

| Room | Region | Proves |
|---|---|---|
| 12 | Sunken Baths | statue pushed into a pool sinks onto a submerged valve-plate |
| 13 | Gorgon Gardens | sweeping petrifying gaze; statues (and stone-self) block it |
| 14 | Crystal Undercroft | darkness + player lamp; braziers lit permanently in stages |
| 15 | Marble Palace | the stone-warden re-seals softened NPCs mid-escort |
