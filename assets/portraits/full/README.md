# Full-body character art

Used in skits, the ledger's character pages, and the HUD status figure
(Amé only, flesh + stone pair swapped by game state).

- **Size:** generate 1024×1536 (2:3 portrait), ship at 512×768
  (PNG, transparent bg).
- **Naming:** `<char>_<state>_full.png` — e.g. `ame_flesh_full.png`,
  `ame_stone_full.png`.
- **Targets:** Amé (both states, highest priority — the HUD uses them),
  then Ida, the gorgon, the Curator, the 6 Witnesses; other named NPCs
  only if a skit demands it.

## Prompt template

> {STYLE_TAG}, full body character art of {character_desc}, standing,
> relaxed pose, full figure visible head to feet, three-quarter view,
> plain background, transparent background

- Stone variant: img2img from the accepted flesh image + petrified
  clause. The pose must not change between the pair — the whole point
  is the same person in both states.
- Amé's identifier: long purple hair + marble-veined left arm. The veins
  must be visible in the flesh variant (they are her stamina UI motif).
