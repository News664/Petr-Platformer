# Dialogue busts

Head-and-shoulders portraits shown in the dialogue panel.

- **Size:** generate 1024×1024, ship at 512×512 (PNG, transparent bg).
- **Naming:** `<char>_<state>_<expr>.png` — e.g. `ame_flesh_neutral.png`,
  `ame_flesh_worried.png`, `marla_stone.png`.
  States: `flesh`, `stone`. Expressions (flesh only): `neutral`, `smile`,
  `worried`, `determined` (+ extras for Amé: `tears`, `resolve`).
- **Targets:** Amé ×8 expressions; ~24 named NPCs ×3; stone variant ×1
  each (derived, no expressions — stone does not emote).

## Prompt template (new base bust)

> {STYLE_TAG}, bust portrait of {character_desc}, head and shoulders,
> three-quarter view facing left, neutral expression, plain dark
> background, transparent background

- Expressions: **inpaint the face region only** of the accepted base.
- Stone variant: img2img from the accepted flesh bust with the
  petrified clause (see `assets/README.md`), high structure preservation
  (ControlNet lineart or low denoise).

Character descriptions live in `tools/artgen/characters.json`.
