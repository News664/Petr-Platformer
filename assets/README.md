# Assets

Source art for the game, produced with the AI pipeline in `tools/artgen/`
and finished by hand. Only accepted files live in these folders; raw
generations land in `candidates/` (gitignored) and are promoted here after
selection/cleanup. Every accepted image keeps its generation sidecar
(`<name>.json`: prompt, model, seed/size, date) so it can be regenerated
or restyled later.

## Folder map

| Folder | Contents |
|---|---|
| `portraits/busts/` | Dialogue bust portraits (flesh + stone + expressions) |
| `portraits/full/` | Full-body character art (flesh + stone) |
| `cg/` | Full-scene event illustrations |
| `frescoes/` | Rescue vignettes & truth panels (stained-glass/fresco style) |
| `sprites/characters/` | In-game pixel sprites and sheets |
| `sprites/tiles/` | Tilesets per biome |
| `backgrounds/` | Parallax background layers |
| `ui/` | Icons, frames, 9-patches |
| `style/` | The style bible: accepted key images all generation is conditioned on |
| `candidates/` | Raw generator output, gitignored — never referenced by the game |

## The style tag

Every prompt begins with the shared style tag so the set stays coherent.
Current wording (v1 — revise only here, then regenerate):

> painted storybook illustration, melancholy fairy tale, soft volumetric
> light, muted palette of cold marble whites and teals against warm
> lantern ambers, gentle linework, dignified and tender mood, no gore,
> no text, no watermark

Petrified-variant clause, appended when generating stone versions:

> as a weathered marble statue, single unified stone material, chiseled
> hair masses, blank softly-veined eyes, drapery-like stone clothing
> folds, fine cracks and weathering, cold rim light

## Rules of thumb

- Generate N≥4 candidates per slot, pick one, inpaint fixes; budget
  20–30% of time for manual cleanup.
- Expressions are made by inpainting the face region of the accepted
  base bust — never by regenerating the whole image.
- Petrified busts/CGs are derived from the accepted flesh image via
  structure-preserving img2img (same lineart), not from scratch.
- Every named character has one high-contrast identifier (hair
  silhouette, headscarf, pauldron) that must survive into every image.
