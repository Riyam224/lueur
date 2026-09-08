#!/usr/bin/env python3
"""Check every store-screenshot-*.png is exactly 1080x1920. Check-only, no writes."""

import glob
import os
import re

from PIL import Image

REQUIRED_SIZE = (1080, 1920)
STORE_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)))


def main():
    files = sorted(
        glob.glob(os.path.join(STORE_DIR, "store-screenshot-*.png")),
        key=lambda f: int(re.search(r"(\d+)", os.path.basename(f)).group(1)),
    )

    passed = []
    failed = []

    for path in files:
        name = os.path.basename(path)
        with Image.open(path) as im:
            size = im.size

        if size == REQUIRED_SIZE:
            print(f"{name} — {size[0]}x{size[1]} — PASS")
            passed.append(name)
        else:
            req_w, req_h = REQUIRED_SIZE
            w, h = size
            reasons = []
            if w != req_w:
                reasons.append(f"width off by {abs(w - req_w)}px")
            if h != req_h:
                reasons.append(f"height off by {abs(h - req_h)}px")
            reason = ", ".join(reasons)
            print(f"{name} — {w}x{h} — FAIL ({reason})")
            failed.append((name, size))

    print()
    print(f"Summary: {len(passed)}/{len(files)} passed")
    if failed:
        print("Failed files:")
        for name, size in failed:
            print(f"  {name} — {size[0]}x{size[1]}")


if __name__ == "__main__":
    main()
