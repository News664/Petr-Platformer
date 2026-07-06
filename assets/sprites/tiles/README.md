# Tilesets

One tileset per biome (Village, Quarry, Baths, Gardens, Undercroft,
Palace, Heart).

- **Size:** 32×32 px tiles, sheet PNG on a 32-grid; include 47-tile
  autotile blob per terrain material where possible.
- **Naming:** `<biome>_tiles.png`.

## Pipeline

AI drafts a texture swatch → manual cut into seamless tiles in
Aseprite (budget a few hours per biome; seams are always hand-fixed).

> pixel art tileset texture, {biome_desc}, 32px grid, muted palette,
> cold marble whites and teals with warm lantern accents, seamless
