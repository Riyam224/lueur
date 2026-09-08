#!/usr/bin/env python3
"""Prepare Lueur Google Play Store screenshots straight from real captures.

Unlike generate_store_screenshots.py (which drew a synthetic phone bezel and
a marketing headline over each screenshot), this takes the raw captures in
store1/ *as they are* — same app bar, same status bar, no added frame, no
overlay text — and only does the minimum needed to satisfy Google Play's
technical requirements (see validate_assets.py):

  - PNG, RGB (no alpha channel)
  - each side within [320, 3840]px
  - long side no more than 2x the short side

The store1 captures are 1080x2424 (aspect ~2.244:1), which breaks the last
rule. Since cropping would cut off real content (and the app bar/status bar
must not be touched), the fix is to pad — add a thin color strip stretched
from each edge's own pixels on the left/right — rather than crop anything
away. This is content-preserving: every original pixel stays exactly where
it was, just centered on a slightly wider canvas.
"""

import math
import os

from PIL import Image, ImageFilter

STORE_DIR = os.path.dirname(os.path.abspath(__file__))
SOURCE_DIR = os.path.join(STORE_DIR, "store1")

MAX_ASPECT = 2.0
EDGE_SAMPLE_PX = 6
EDGE_BLUR_RADIUS = 12

# Same nine screens the marketing set has always covered, now taken as-is
# instead of composited into a headline+bezel mockup.
SCREENS = [
    {"out": "store-screenshot-1.png", "screenshot": "chat_with_ai_luna_more_light.png"},
    {"out": "store-screenshot-2.png", "screenshot": "home_dark.png"},
    {"out": "store-screenshot-3.png", "screenshot": "journal_dark.png"},
    {"out": "store-screenshot-4.png", "screenshot": "timeline_light.png"},
    {"out": "store-screenshot-5.png", "screenshot": "profile_choose_theme_and language_dark.png"},
    {"out": "store-screenshot-6.png", "screenshot": "breathing_light.png"},
    {"out": "store-screenshot-7.png", "screenshot": "freedraw_light.png"},
    {"out": "store-screenshot-8.png", "screenshot": "sudoku_dark.png"},
    {"out": "store-screenshot-9.png", "screenshot": "profile_dark.png"},
]


def pillarbox_to_max_aspect(shot: Image.Image) -> Image.Image:
    """Widen the canvas (never crop) so long/short side <= MAX_ASPECT.

    The added strips are a soft blur stretched from the image's own left/
    right edge pixels, so the pad reads as ambient background rather than a
    hard color bar, and the original screenshot is pasted back unmodified
    and centered.
    """
    width, height = shot.size
    longer, shorter = max(width, height), min(width, height)
    if longer / shorter <= MAX_ASPECT:
        return shot

    # Only the (portrait) screenshots we handle need padding, and only ever
    # on the sides — the width is the short side, so widen it.
    target_width = math.ceil(height / MAX_ASPECT)
    pad_total = target_width - width
    pad_left = pad_total // 2
    pad_right = pad_total - pad_left

    canvas = Image.new("RGB", (target_width, height))

    left_strip = shot.crop((0, 0, EDGE_SAMPLE_PX, height)).resize((pad_left, height))
    right_strip = shot.crop((width - EDGE_SAMPLE_PX, 0, width, height)).resize((pad_right, height))
    left_strip = left_strip.filter(ImageFilter.GaussianBlur(EDGE_BLUR_RADIUS))
    right_strip = right_strip.filter(ImageFilter.GaussianBlur(EDGE_BLUR_RADIUS))

    canvas.paste(left_strip, (0, 0))
    canvas.paste(right_strip, (pad_left + width, 0))
    canvas.paste(shot, (pad_left, 0))
    return canvas


def prepare(entry):
    src_path = os.path.join(SOURCE_DIR, entry["screenshot"])
    shot = Image.open(src_path).convert("RGB")
    shot = pillarbox_to_max_aspect(shot)

    out_path = os.path.join(STORE_DIR, entry["out"])
    shot.save(out_path, "PNG")
    print(f"saved {out_path} ({shot.width}x{shot.height})")


def main():
    for entry in SCREENS:
        prepare(entry)


if __name__ == "__main__":
    main()
