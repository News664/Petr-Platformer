# Style bible

The accepted key images that define the game's look. Everything else is
generated *conditioned on these* (reference image / img2img / LoRA
training set as tooling allows).

Produce these first, in order:

1. `key_ame_village.png` — Amé standing in the petrified village square
   among statues, lanterns lit. This image decides the palette and
   rendering style for the whole project.
2. `key_ame_turnaround.png` — Amé front/side/back model sheet.
3. `key_statue_study.png` — one villager statue, flesh-vs-stone pair.
4. `key_palette.png` — swatch sheet extracted from 1 (cold marble
   whites/teals vs. warm lantern ambers) with hex values annotated.

When a generated asset drifts off-style, the fix is a reference to these
files, not more prompt words.
