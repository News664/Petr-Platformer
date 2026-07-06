#!/usr/bin/env python3
"""Generate game art candidates via an OpenAI-style images API.

Default provider is https://api.labnana.com; point ARTGEN_BASE_URL at any
other OpenAI-compatible endpoint to switch. The API key is read from
ARTGEN_API_KEY (or LABNANA_API_KEY) and is never written to disk.

Examples:
  # 4 bust candidates of Amé, flesh
  python generate.py --char ame --shot bust

  # her petrified full-body variant prompt
  python generate.py --char ame --shot full --state stone

  # a free-form scene using the fresco template
  python generate.py --shot fresco --desc "a baker kneeling over spilled flour, caught mid-motion by a wave of stone"

  # inspect the request without spending credits
  python generate.py --char ame --shot bust --dry-run
"""

import argparse
import base64
import datetime
import json
import os
import sys
import urllib.error
import urllib.request
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[1]
DEFAULT_OUT = REPO / "assets" / "candidates"

BASE_URL = os.environ.get("ARTGEN_BASE_URL", "https://api.labnana.com")
MODEL = os.environ.get("ARTGEN_MODEL", "gpt-image-1")
API_KEY = os.environ.get("ARTGEN_API_KEY") or os.environ.get("LABNANA_API_KEY")


def load_json(name):
    return json.loads((HERE / name).read_text(encoding="utf-8"))


def build_prompt(args, shots):
    shot = shots["shots"][args.shot]
    if args.prompt:
        return args.prompt, shot["size"]
    desc = args.desc
    if args.char:
        chars = load_json("characters.json")
        if args.char not in chars:
            sys.exit(f"unknown char {args.char!r}; known: {', '.join(chars)}")
        desc = chars[args.char]["desc"]
    if not desc:
        sys.exit("need --char, --desc, or --prompt")
    stone = ", " + shots["stone_clause"] if args.state == "stone" else ""
    prompt = shot["template"].format(style=shots["style_tag"], desc=desc, stone=stone)
    return prompt, shot["size"]


def request_images(prompt, n, size, model, base_url, timeout=600):
    url = base_url.rstrip("/") + "/v1/images/generations"
    payload = {"model": model, "prompt": prompt, "n": n, "size": size}
    req = urllib.request.Request(
        url,
        data=json.dumps(payload).encode("utf-8"),
        headers={
            "Authorization": f"Bearer {API_KEY}",
            "Content-Type": "application/json",
        },
    )
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            data = json.load(resp)
    except urllib.error.HTTPError as e:
        sys.exit(f"API error {e.code}: {e.read().decode(errors='replace')[:500]}")
    images = []
    for item in data.get("data", []):
        if "b64_json" in item:
            images.append(base64.b64decode(item["b64_json"]))
        elif "url" in item:
            with urllib.request.urlopen(item["url"], timeout=timeout) as img:
                images.append(img.read())
    if not images:
        sys.exit(f"no images in response: {json.dumps(data)[:500]}")
    return images


def main():
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--char", help="character id from characters.json")
    p.add_argument("--shot", required=True,
                   help="template from shots.json (bust/full/fresco/cg/background/ui)")
    p.add_argument("--state", choices=["flesh", "stone"], default="flesh")
    p.add_argument("--desc", help="free-form subject description (instead of --char)")
    p.add_argument("--prompt", help="raw prompt, bypasses all templates")
    p.add_argument("--n", type=int, default=4, help="candidates to generate (default 4)")
    p.add_argument("--size", help="override the shot's default size, e.g. 1024x1024")
    p.add_argument("--model", default=MODEL)
    p.add_argument("--base-url", default=BASE_URL)
    p.add_argument("--out", type=Path, default=None,
                   help=f"output dir (default {DEFAULT_OUT}/<shot>/)")
    p.add_argument("--dry-run", action="store_true",
                   help="print the request payload and exit")
    args = p.parse_args()

    shots = load_json("shots.json")
    if args.shot not in shots["shots"]:
        sys.exit(f"unknown shot {args.shot!r}; known: {', '.join(shots['shots'])}")
    prompt, size = build_prompt(args, shots)
    size = args.size or size

    if args.dry_run:
        print(json.dumps({"base_url": args.base_url, "model": args.model,
                          "n": args.n, "size": size, "prompt": prompt}, indent=2))
        return
    if not API_KEY:
        sys.exit("set ARTGEN_API_KEY (or LABNANA_API_KEY) in the environment")

    out_dir = args.out or (DEFAULT_OUT / args.shot)
    out_dir.mkdir(parents=True, exist_ok=True)
    stamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    stem = "_".join(x for x in [args.char or "scene", args.state, stamp] if x)

    print(f"requesting {args.n} image(s) from {args.base_url} [{args.model}] ...")
    images = request_images(prompt, args.n, size, args.model, args.base_url)
    meta = {"prompt": prompt, "model": args.model, "size": size,
            "base_url": args.base_url, "date": stamp}
    for i, blob in enumerate(images):
        path = out_dir / f"{stem}_{i}.png"
        path.write_bytes(blob)
        path.with_suffix(".json").write_text(json.dumps(meta, indent=2), encoding="utf-8")
        print(f"  wrote {path.relative_to(REPO)}")
    print("done — promote keepers out of candidates/ per assets/README.md")


if __name__ == "__main__":
    main()
