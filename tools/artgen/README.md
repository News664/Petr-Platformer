# artgen

Image generation tooling. Stdlib-only Python 3.9+ — no packages to install.

## Setup

```sh
export ARTGEN_API_KEY=sk-...            # or LABNANA_API_KEY; never commit keys
export ARTGEN_BASE_URL=https://api.labnana.com   # default; any OpenAI-style API works
export ARTGEN_MODEL=gpt-image-1                  # override per provider
```

## Usage

```sh
python tools/artgen/generate.py --char ame --shot bust               # 4 candidates
python tools/artgen/generate.py --char ame --shot full --state stone # petrified
python tools/artgen/generate.py --shot cg --desc "the wave of stone rolling down the village street at dawn"
python tools/artgen/generate.py --char ame --shot bust --dry-run     # print request only
```

Output goes to `assets/candidates/<shot>/` (gitignored) with a `.json`
sidecar per image (prompt/model/size/date). Pick winners, clean them up,
and move image+sidecar into the proper `assets/` folder per that
folder's README.

- Characters: `characters.json` (descriptions + the one identifier each
  image must preserve).
- Templates & shared style tag: `shots.json` — edit the style tag only
  there and in `assets/README.md` together.
- Switching providers later = change `ARTGEN_BASE_URL`/`ARTGEN_MODEL`;
  the endpoint used is `POST {base}/v1/images/generations` and both
  `b64_json` and `url` response formats are handled.
