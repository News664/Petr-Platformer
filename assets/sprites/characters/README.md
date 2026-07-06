# Character sprites

In-game pixel sprites. Petrified variants are the runtime stone shader —
never separate sprite art.

- **Size:** characters 32–48 px tall, frames on a grid (e.g. 48×48 cells),
  sheet as one PNG per character. Nearest-neighbor, no anti-aliasing
  against transparency.
- **Naming:** `<char>_sheet.png` + `<char>_sheet.json` (frame map).
- **Targets:** Amé ~10 animation sets (idle, run, jump, fall, land,
  push, soften-cast, petrify, hurt, rescue-walk); NPC archetypes share
  one skeleton: idle/walk/run/panic ×4, palette-swapped outfits;
  statue poses are single frames (no animation).

## Pipeline

AI pixel tools (PixelLab / Retro Diffusion class) for drafts →
Aseprite cleanup. Prompt template for drafts:

> pixel art game sprite, {character_desc}, side view, 48px character,
> clean silhouette, transparent background, {animation} animation frames

Consistency: lock Amé's palette (purple hair, warm skin, slate dress)
in `tools/artgen/characters.json` and reuse exact hex values in Aseprite.
