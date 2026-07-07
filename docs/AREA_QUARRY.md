# Area design — The Quarry (Region 1)

First real region. Theme sheet in `docs/AREAS.md` (stone-as-labor:
terraces, scaffolds, cranes; ochre/rust/bone palette; mortar-slimes and
quarry wisps; boss: the Foredame; ability: Chisel Dash).

**Structural rule — unlike the Village, the Quarry is not linear.**
Rooms form loops and offer route choices; the map is what keeps the
player oriented. Target shape: two parallel routes (high scaffold route,
low haul-road route) that cross at least twice, with the boss and
Sanctuary at the far end reachable by either.

## Current graph (built rooms in caps)

```
                 [CRANE YARD]══════════╗
                ↗ (up the slabs)       ║ (down)
 Square ══ [GATE TERRACES]══════════[THE CUT]── Depths (stub) → …boss, Sanctuary
                └─ lower haul road ────┘
```

- Entry: the Square's east gate, opened by **Mason's Grip**.
- **Gate Terraces (room 9)** — the branch room. Climb the scaffold slabs
  to the Crane Yard door (top-east), or walk the lower haul road to The
  Cut (ground-east). Waystone on the haul road; Brona (rescue, easy);
  the surveyor (anchored, on the scaffold).
- **Crane Yard (room 10)** — high route. Counterweight lesson: the gate
  plate needs more weight than any crate — only Hetta (kneeler) is heavy
  enough, and the Waystone is a room away: use her, and feel it. Exits
  west (Terraces top) and east (down into The Cut).
- **The Cut (room 11)** — low route. A deep excavation with climb-steps
  on both walls; the digger twins (anchored) at the bottom; Vess
  (rescue, easy — the region's breather rescue); a **quarry block**
  pushed off the west lip smashes a cracked seam in the pit floor,
  opening a mote cavity — the Grip+gravity combo that Chisel Dash will
  later make trivial. Exits west (Terraces, lower), east-up (Crane
  Yard), and the sealed **Depths** (rest of the region).

The 9⇄10⇄11⇄9 triangle means every built room is reachable two ways —
the non-linearity sample the rest of the region scales up from.

## Planned beyond the slice

Depths (~8 more rooms): rolling-block ramps, rope elevators (plate-
driven), the wisp fields (Chisel Light pressure), one Witness (Sableth
the forewoman), hidden room behind a collapse, the Foredame's dig, and
the Quarry Sanctuary (Chisel Dash → back-unlocks the Village cellar).

## Sample rooms (dev, keys `[`/`]`, rooms 12–15)

One idea-proof room per later region, using the prototype mechanics:

| Room | Region | Proves |
|---|---|---|
| 12 | Sunken Baths | statue pushed into a pool sinks onto a submerged valve-plate |
| 13 | Gorgon Gardens | sweeping petrifying gaze; statues (and stone-self) block it as cover |
| 14 | Crystal Undercroft | darkness + player lamp; braziers lit permanently stage by stage |
| 15 | Marble Palace | the stone-warden patrol re-seals softened NPCs mid-escort |
