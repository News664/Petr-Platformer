# Backgrounds

Parallax layers per biome — AI's best use case, generate freely.

- **Size:** generate 1792×1024+, ship layers at 1920×1080; far layers
  can be lower detail. 3–4 layers per biome (sky/far/mid/near),
  separated by hand or by generating each depth band as its own image.
- **Naming:** `<biome>_L<n>.png` (L0 = farthest).

## Prompt template

> {STYLE_TAG}, distant background layer for a 2D platformer,
> {biome_desc}, layered silhouettes, atmospheric perspective, empty
> foreground, no characters
