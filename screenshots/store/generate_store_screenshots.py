#!/usr/bin/env python3
"""Generate Lueur Google Play Store marketing screenshots.

TikTok-style composition: headline (DM Serif Display) above a clean,
generic modern-smartphone frame (thin dark bezel, centered punch-hole
camera cut into the screen edge, bottom home indicator) holding an app
screenshot, on a brand lavender gradient. Rendered at 4x supersample and
LANCZOS-downsampled to the final 1080x1920 for crisp text/edges.
"""

import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT = "/Users/r/StudioProjects/lueur"
SCREENSHOTS_DIR = os.path.join(ROOT, "screenshots")
OUT_DIR = os.path.join(SCREENSHOTS_DIR, "store")
# Raw source captures for the store assets — kept in their own folder so
# regenerating store assets never depends on whatever happens to be in the
# top-level screenshots/ folder (used for the README) at the time.
SOURCE_DIR = os.path.join(OUT_DIR, "store1")
FONTS_DIR = os.path.join(ROOT, "assets", "fonts")

HEADLINE_FONT_PATH = os.path.join(FONTS_DIR, "DMSerifDisplay-Regular.ttf")
HEADLINE_FONT_PATH_SANS = os.path.join(FONTS_DIR, "Nunito-Bold.ttf")
BODY_FONT_PATH = os.path.join(FONTS_DIR, "Nunito-SemiBold.ttf")

SCALE = 4
FINAL_W, FINAL_H = 1080, 1920
W, H = FINAL_W * SCALE, FINAL_H * SCALE

# AppColors.lavenderLilac -> AppColors.pastelOrchid (lib/core/styling/app_colors.dart)
GRADIENT_TOP = (0xB7, 0xAE, 0xDC)
GRADIENT_BOTTOM = (0x6E, 0x59, 0xC5)

MARGIN_X = 90 * SCALE
TOP_MARGIN = 130 * SCALE
HEADLINE_BLOCK_H = 340 * SCALE
BOTTOM_MARGIN = 110 * SCALE

# Clean, generic modern-smartphone frame: thin uniform dark bezel, modestly
# rounded corners, centered punch-hole camera, bottom home indicator — not
# tied to any specific real device model.
FRAME_CORNER_R = 32 * SCALE
BEZEL_WIDTH = 9 * SCALE
BEZEL_COLOR = (0x16, 0x16, 0x18, 255)

# Punch-hole camera dot, sized as a fraction of the frame width. Modeled on
# the Galaxy S26's centered front camera: a small circle fully inset within
# the display glass (not straddling the bezel seam), offset a touch down
# from the very top edge of the screen.
PUNCH_HOLE_FRACTION = 0.045
PUNCH_HOLE_INSET_FRACTION = 0.003

# Every raw emulator capture bakes in an oversized punch-hole camera blob in
# the status bar (rows ~45-128 at the 1080px source width) — not something
# this script draws. Crop it off the top of every screenshot before framing,
# so the screen content flows edge-to-edge from just below the synthetic
# punch hole.
NOTCH_CROP_TOP = 145

# Center/radius of that same baked-in blob, used instead of NOTCH_CROP_TOP
# for an entry that wants to keep its real status bar (time/network/battery)
# visible — the blob gets painted over with the row's flat background color
# rather than cropping the whole status bar away.
STATUS_BLOB_CENTER = (539, 86)
STATUS_BLOB_ERASE_RADIUS = 48


def erase_status_blob(shot):
    bg = shot.getpixel((STATUS_BLOB_CENTER[0] + 150, STATUS_BLOB_CENTER[1]))
    draw = ImageDraw.Draw(shot)
    r = STATUS_BLOB_ERASE_RADIUS
    draw.ellipse(
        [
            (STATUS_BLOB_CENTER[0] - r, STATUS_BLOB_CENTER[1] - r),
            (STATUS_BLOB_CENTER[0] + r, STATUS_BLOB_CENTER[1] + r),
        ],
        fill=bg,
    )
    return shot


# Region of the emulator's "3G" text + no-signal triangle in the status bar
# (right side, next to the battery icon), replaced with real wifi + cellular
# signal glyphs for an entry that keeps its status bar visible — a real
# device would show wifi and a normal signal reading, not a flaky "3G" +
# no-signal warning triangle. The glyphs are lifted pixel-for-pixel from
# another raw capture's status bar (same emulator template, same
# position/size for every screenshot) rather than hand-drawn, so they match
# the wifi + signal icons already visible on every other screenshot exactly.
NETWORK_ICON_CLEAR_BOX = (868, 45, 972, 96)
WIFI_GLYPH_SOURCE = "timeline_dark.png"
WIFI_GLYPH_BOX = (886, 48, 970, 92)  # wifi fan + cellular signal triangle, as one unit

_wifi_glyph_cache = None


def _wifi_glyph():
    global _wifi_glyph_cache
    if _wifi_glyph_cache is None:
        ref = Image.open(os.path.join(SOURCE_DIR, WIFI_GLYPH_SOURCE)).convert("RGB")
        crop = ref.crop(WIFI_GLYPH_BOX)
        import numpy as np

        arr = np.array(crop)
        lum = arr.mean(axis=2)
        alpha = np.clip((lum - 40) / (220 - 40) * 255, 0, 255).astype("uint8")
        rgba = np.zeros((crop.height, crop.width, 4), dtype="uint8")
        rgba[..., 0] = 255
        rgba[..., 1] = 255
        rgba[..., 2] = 255
        rgba[..., 3] = alpha
        _wifi_glyph_cache = Image.fromarray(rgba, "RGBA")
    return _wifi_glyph_cache


def draw_wifi_icon(shot):
    bg = shot.getpixel((NETWORK_ICON_CLEAR_BOX[0] - 68, 70))
    draw = ImageDraw.Draw(shot)
    draw.rectangle(NETWORK_ICON_CLEAR_BOX, fill=bg)
    shot.paste(_wifi_glyph(), (WIFI_GLYPH_BOX[0], WIFI_GLYPH_BOX[1]), _wifi_glyph())
    return shot

# Every entry keeps its real status bar (time/network/battery) visible
# instead of the usual top crop — only the baked-in emulator camera blob is
# painted over. "chat_with_ai_luna_more_dark" is the one raw capture whose
# status bar reads "3G" instead of showing a wifi icon, so it also gets the
# drawn wifi glyph.
_STATUS_BAR_VISIBLE = {
    "crop_top": 0,
    "skip_notch_crop": True,
    "erase_blob": True,
}

SCREENS = [
    {
        "out": "store-screenshot-1.png",
        "headline": "These are Lueur's features",
        "screenshot": "features_dark.png",
        **_STATUS_BAR_VISIBLE,
        "wifi_icon": True,
    },
    {
        "out": "store-screenshot-2.png",
        "headline": "Check in with how you feel",
        "screenshot": "home_light.png",
        **_STATUS_BAR_VISIBLE,
    },
    {
        "out": "store-screenshot-3.png",
        "headline": "Talk it out with Luna",
        "screenshot": "chat_with_ai_luna_more_dark.png",
        **_STATUS_BAR_VISIBLE,
        "wifi_icon": True,
    },
    {
        "out": "store-screenshot-4.png",
        "headline": "Your week, your streak, your story",
        "screenshot": "journal_light.png",
        **_STATUS_BAR_VISIBLE,
    },
    {
        "out": "store-screenshot-5.png",
        "headline": "Every moment, remembered",
        "screenshot": "timeline_dark.png",
        **_STATUS_BAR_VISIBLE,
    },
    {
        "out": "store-screenshot-6.png",
        "headline": "Breathe easy with Luna",
        "screenshot": "breathing_light.png",
        **_STATUS_BAR_VISIBLE,
    },
    {
        "out": "store-screenshot-7.png",
        "headline": "A small puzzle to unwind",
        "screenshot": "sudoku_dark.png",
        **_STATUS_BAR_VISIBLE,
    },
    {
        "out": "store-screenshot-8.png",
        "headline": "Draw out what words can't say",
        "screenshot": "freedraw_light.png",
        **_STATUS_BAR_VISIBLE,
    },
    {
        "out": "store-screenshot-9.png",
        "headline": "Always in your language",
        "screenshot": "profile_choose_theme_and language_dark.png",
        **_STATUS_BAR_VISIBLE,
    },
    {
        "out": "store-screenshot-10.png",
        "headline": "Your journey, all in one place",
        "screenshot": "profile_light.png",
        **_STATUS_BAR_VISIBLE,
    },
]

for _entry in SCREENS:
    if not _entry.get("skip_notch_crop"):
        _entry["crop_top"] = max(_entry.get("crop_top", 0), NOTCH_CROP_TOP)


def vertical_gradient(width, height, top_rgb, bottom_rgb):
    base = Image.new("RGB", (1, height), 0)
    for y in range(height):
        t = y / max(height - 1, 1)
        r = round(top_rgb[0] + (bottom_rgb[0] - top_rgb[0]) * t)
        g = round(top_rgb[1] + (bottom_rgb[1] - top_rgb[1]) * t)
        b = round(top_rgb[2] + (bottom_rgb[2] - top_rgb[2]) * t)
        base.putpixel((0, y), (r, g, b))
    return base.resize((width, height), Image.Resampling.NEAREST)


def wrap_text(draw, text, font, max_width):
    words = text.split(" ")
    lines = []
    current = ""
    for word in words:
        candidate = f"{current} {word}".strip()
        bbox = draw.textbbox((0, 0), candidate, font=font)
        if bbox[2] - bbox[0] <= max_width or not current:
            current = candidate
        else:
            lines.append(current)
            current = word
    if current:
        lines.append(current)
    return lines


def fit_headline_font(draw, text, max_width, max_height, start_size):
    size = start_size
    while size > 40 * SCALE:
        font = ImageFont.truetype(HEADLINE_FONT_PATH_SANS, size)
        lines = wrap_text(draw, text, font, max_width)
        ascent, descent = font.getmetrics()
        line_height = (ascent + descent) * 0.78
        total_height = line_height * len(lines)
        widest = max(draw.textbbox((0, 0), line, font=font)[2] for line in lines)
        if total_height <= max_height and widest <= max_width:
            return font, lines, line_height
        size -= 4 * SCALE
    return font, lines, line_height


def draw_headline(canvas_draw, text):
    max_width = W - 2 * MARGIN_X
    font, lines, line_height = fit_headline_font(
        canvas_draw, text, max_width, HEADLINE_BLOCK_H, 68 * SCALE
    )
    total_height = line_height * len(lines)
    y = TOP_MARGIN + (HEADLINE_BLOCK_H - total_height) / 2
    shadow_offset = 3 * SCALE
    for line in lines:
        bbox = canvas_draw.textbbox((0, 0), line, font=font)
        x = (W - (bbox[2] - bbox[0])) / 2
        canvas_draw.text(
            (x + shadow_offset, y + shadow_offset),
            line,
            font=font,
            fill=(0x2B, 0x21, 0x38, 40),
        )
        canvas_draw.text((x, y), line, font=font, fill=(0x1A, 0x1A, 0x1A, 255))
        y += line_height
    return TOP_MARGIN + total_height


def rounded_mask(size, radius):
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [(0, 0), (size[0] - 1, size[1] - 1)], radius=radius, fill=255
    )
    return mask


def build_phone_frame(
    screenshot_path, frame_top, frame_bottom, crop_top=0, erase_blob=False, wifi_icon=False
):
    frame_h = frame_bottom - frame_top
    shot = Image.open(screenshot_path).convert("RGB")
    if erase_blob:
        shot = erase_status_blob(shot)
    if wifi_icon:
        shot = draw_wifi_icon(shot)
    if crop_top:
        shot = shot.crop((0, crop_top, shot.width, shot.height))

    aspect = shot.width / shot.height
    frame_w = int(frame_h * aspect)
    frame_x = (W - frame_w) // 2

    bezel = Image.new("RGBA", (frame_w + 2 * BEZEL_WIDTH, frame_h + 2 * BEZEL_WIDTH), (0, 0, 0, 0))
    bezel_draw = ImageDraw.Draw(bezel)
    bezel_draw.rounded_rectangle(
        [(0, 0), (bezel.width - 1, bezel.height - 1)],
        radius=FRAME_CORNER_R + BEZEL_WIDTH,
        fill=BEZEL_COLOR,
    )

    shot_resized = shot.resize((frame_w, frame_h), Image.Resampling.LANCZOS)
    inner_mask = rounded_mask((frame_w, frame_h), FRAME_CORNER_R)
    bezel.paste(shot_resized, (BEZEL_WIDTH, BEZEL_WIDTH), inner_mask)

    # Punch-hole camera dot, fully inset within the screen content (like a
    # real in-display camera cutout) rather than a separate status-bar icon.
    hole_r = frame_w * PUNCH_HOLE_FRACTION / 2
    hole_cx = BEZEL_WIDTH + frame_w / 2
    hole_cy = BEZEL_WIDTH + frame_w * PUNCH_HOLE_INSET_FRACTION + hole_r
    bezel_draw.ellipse(
        [(hole_cx - hole_r, hole_cy - hole_r), (hole_cx + hole_r, hole_cy + hole_r)],
        fill=(0, 0, 0, 255),
    )

    # Power button (right edge) and volume rocker (left edge) — subtle marks
    # in the same flat bezel tone, just enough to read as a phone silhouette.
    btn_color = BEZEL_COLOR
    power_h = bezel.height * 0.09
    power_y0 = bezel.height * 0.22
    bezel_draw.rounded_rectangle(
        [(bezel.width - SCALE * 2, power_y0), (bezel.width + SCALE * 2, power_y0 + power_h)],
        radius=SCALE * 2, fill=btn_color,
    )
    vol_h = bezel.height * 0.075
    for i, vol_y0 in enumerate((bezel.height * 0.16, bezel.height * 0.16 + vol_h + SCALE * 6)):
        bezel_draw.rounded_rectangle(
            [(-SCALE * 2, vol_y0), (SCALE * 2, vol_y0 + vol_h)],
            radius=SCALE * 2, fill=btn_color,
        )

    # Home indicator: short rounded bar centered at the bottom of the
    # screen area, the detail that reads as "clean modern phone".
    indicator_w = frame_w * 0.25
    indicator_h = 1.6 * SCALE
    indicator_x0 = BEZEL_WIDTH + (frame_w - indicator_w) / 2
    indicator_y1 = BEZEL_WIDTH + frame_h - 6 * SCALE
    bezel_draw.rounded_rectangle(
        [(indicator_x0, indicator_y1 - indicator_h), (indicator_x0 + indicator_w, indicator_y1)],
        radius=indicator_h / 2,
        fill=(0xF2, 0xF2, 0xF2, 210),
    )

    shadow = Image.new("RGBA", (bezel.width + 160 * SCALE, bezel.height + 160 * SCALE), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    pad = 80 * SCALE
    shadow_draw.rounded_rectangle(
        [(pad, pad + 24 * SCALE), (pad + bezel.width, pad + bezel.height + 24 * SCALE)],
        radius=FRAME_CORNER_R + BEZEL_WIDTH,
        fill=(0x2B, 0x21, 0x38, 110),
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(28 * SCALE))

    return bezel, frame_x - BEZEL_WIDTH, shadow, pad


def render(entry):
    canvas = vertical_gradient(W, H, GRADIENT_TOP, GRADIENT_BOTTOM).convert("RGBA")

    accent_layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    accent_draw = ImageDraw.Draw(accent_layer)
    # Soft mint blob, top-left
    accent_draw.ellipse(
        [-120 * SCALE, -140 * SCALE, 260 * SCALE, 220 * SCALE],
        fill=(0x5B, 0xBF, 0xA0, 160),
    )
    # Soft orange blob, bottom-right
    accent_draw.ellipse(
        [W - 300 * SCALE, H - 260 * SCALE, W + 140 * SCALE, H + 100 * SCALE],
        fill=(0xE8, 0x82, 0x5A, 140),
    )
    accent_layer = accent_layer.filter(ImageFilter.GaussianBlur(40 * SCALE))
    canvas = Image.alpha_composite(canvas, accent_layer)

    draw = ImageDraw.Draw(canvas)

    draw_headline(draw, entry["headline"])

    frame_top = TOP_MARGIN + HEADLINE_BLOCK_H
    frame_bottom = H - BOTTOM_MARGIN
    screenshot_path = os.path.join(SOURCE_DIR, entry["screenshot"])
    bezel, bezel_x, shadow, shadow_pad = build_phone_frame(
        screenshot_path,
        frame_top,
        frame_bottom,
        entry.get("crop_top", 0),
        entry.get("erase_blob", False),
        entry.get("wifi_icon", False),
    )
    bezel_y = frame_top

    shadow_x = bezel_x - shadow_pad
    shadow_y = bezel_y - shadow_pad
    canvas.alpha_composite(shadow, (shadow_x, shadow_y))
    canvas.alpha_composite(bezel, (bezel_x, bezel_y))

    final = canvas.convert("RGB").resize((FINAL_W, FINAL_H), Image.Resampling.LANCZOS)
    out_path = os.path.join(OUT_DIR, entry["out"])
    final.save(out_path, "PNG")
    print(f"saved {out_path}")


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    for entry in SCREENS:
        render(entry)


if __name__ == "__main__":
    main()
