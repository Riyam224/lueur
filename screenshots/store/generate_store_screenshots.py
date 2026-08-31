#!/usr/bin/env python3
"""Generate Lueur Google Play Store marketing screenshots.

TikTok-style composition: headline (DM Serif Display) above a Samsung
Galaxy S26-style phone frame (thin graphite bezel, centered punch-hole
camera, synthetic One UI status bar) holding an app screenshot, on a brand
lavender gradient. Rendered at 4x supersample and LANCZOS-downsampled to
the final 1080x1920 for crisp text/edges.
"""

import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT = "/Users/r/StudioProjects/lueur"
SCREENSHOTS_DIR = os.path.join(ROOT, "screenshots")
OUT_DIR = os.path.join(SCREENSHOTS_DIR, "store")
FONTS_DIR = os.path.join(ROOT, "assets", "fonts")

HEADLINE_FONT_PATH = os.path.join(FONTS_DIR, "DMSerifDisplay-Regular.ttf")
BODY_FONT_PATH = os.path.join(FONTS_DIR, "Nunito-SemiBold.ttf")
STATUS_FONT_PATH = os.path.join(FONTS_DIR, "Nunito-Bold.ttf")

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

# Samsung Galaxy S26-style frame: thin graphite bezel, modestly rounded
# corners (flatter than an iPhone frame), centered punch-hole camera.
FRAME_CORNER_R = 46 * SCALE
BEZEL_WIDTH = 9 * SCALE
BEZEL_COLOR = (0x2A, 0x2A, 0x2F, 255)
BEZEL_HIGHLIGHT = (0x4A, 0x4A, 0x52, 255)

# Synthetic One UI status bar drawn on top of every cropped screenshot.
STATUS_BAR_FRACTION = 0.046
PUNCH_HOLE_FRACTION = 0.30

# Every raw emulator capture bakes in an oversized punch-hole camera blob in
# the status bar (rows ~45-128 at the 1080px source width) — not something
# this script draws. Crop it off the top of every screenshot before framing,
# then a clean synthetic status bar + punch hole is drawn back on below.
NOTCH_CROP_TOP = 145

SCREENS = [
    {
        "out": "store-screenshot-1.png",
        "headline": "Meet Luna, your calm companion",
        # Long, filled-out conversation instead of a near-empty two-bubble
        # capture, so the phone frame isn't mostly blank space.
        "screenshot": "chat_with_ai_luna_more_light.png",
    },
    {
        "out": "store-screenshot-2.png",
        "headline": "Check in with how you feel",
        "screenshot": "home_screen_dark.png",
    },
    {
        "out": "store-screenshot-3.png",
        "headline": "A cozy space for your thoughts",
        "screenshot": "journal_dark.png",
    },
    {
        "out": "store-screenshot-4.png",
        "headline": "Every moment, remembered",
        "screenshot": "timeline_light.png",
    },
    {
        "out": "store-screenshot-5.png",
        "headline": "Always in your language",
        "screenshot": "profile_with_theming_langs_dark.png",
    },
    {
        "out": "store-screenshot-6.png",
        "headline": "A slow breath with Luna",
        "screenshot": "breathing_with_luna_light.png",
    },
    {
        "out": "store-screenshot-7.png",
        "headline": "Draw out what words can't say",
        "screenshot": "freedrawing_light.png",
    },
    {
        "out": "store-screenshot-8.png",
        "headline": "A small puzzle to unwind",
        "screenshot": "sudoku_screen_dark.png",
    },
]

for _entry in SCREENS:
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
        font = ImageFont.truetype(HEADLINE_FONT_PATH, size)
        lines = wrap_text(draw, text, font, max_width)
        ascent, descent = font.getmetrics()
        line_height = (ascent + descent) * 1.08
        total_height = line_height * len(lines)
        widest = max(draw.textbbox((0, 0), line, font=font)[2] for line in lines)
        if total_height <= max_height and widest <= max_width:
            return font, lines, line_height
        size -= 4 * SCALE
    return font, lines, line_height


def draw_headline(canvas_draw, text):
    max_width = W - 2 * MARGIN_X
    font, lines, line_height = fit_headline_font(
        canvas_draw, text, max_width, HEADLINE_BLOCK_H, 118 * SCALE
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
            fill=(0x2B, 0x21, 0x38, 70),
        )
        canvas_draw.text((x, y), line, font=font, fill=(0xFF, 0xFF, 0xFF, 255))
        y += line_height
    return TOP_MARGIN + total_height


def rounded_mask(size, radius):
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [(0, 0), (size[0] - 1, size[1] - 1)], radius=radius, fill=255
    )
    return mask


def luminance(rgb):
    r, g, b = rgb
    return 0.299 * r + 0.587 * g + 0.114 * b


def draw_status_bar_icons(draw, right_edge, mid_y, icon_h, color):
    """Draw simple signal / wifi / battery glyphs, right-aligned at right_edge."""
    gap = icon_h * 0.55

    # Battery (rightmost): outline + fill + nub.
    batt_w, batt_h = icon_h * 1.9, icon_h * 0.95
    batt_x1 = right_edge
    batt_x0 = batt_x1 - batt_w
    batt_y0 = mid_y - batt_h / 2
    batt_y1 = mid_y + batt_h / 2
    nub_w = icon_h * 0.18
    draw.rounded_rectangle(
        [(batt_x0, batt_y0), (batt_x1, batt_y1)], radius=icon_h * 0.16,
        outline=color, width=max(1, round(icon_h * 0.09)),
    )
    draw.rounded_rectangle(
        [(batt_x1, mid_y - batt_h * 0.22), (batt_x1 + nub_w, mid_y + batt_h * 0.22)],
        radius=icon_h * 0.05, fill=color,
    )
    pad = icon_h * 0.16
    draw.rounded_rectangle(
        [(batt_x0 + pad, batt_y0 + pad), (batt_x1 - pad, batt_y1 - pad)],
        radius=icon_h * 0.08, fill=color,
    )

    # Wifi (middle): three concentric arcs + dot.
    wifi_cx = batt_x0 - gap - icon_h
    wifi_cy = mid_y + icon_h * 0.35
    for i, r in enumerate((icon_h * 0.95, icon_h * 0.62, icon_h * 0.3)):
        bbox = [(wifi_cx - r, wifi_cy - r), (wifi_cx + r, wifi_cy + r)]
        draw.arc(bbox, start=215, end=325, fill=color, width=max(1, round(icon_h * 0.14)))
    dot_r = icon_h * 0.09
    draw.ellipse(
        [(wifi_cx - dot_r, wifi_cy - dot_r), (wifi_cx + dot_r, wifi_cy + dot_r)], fill=color
    )

    # Signal bars (leftmost): 4 ascending bars.
    bars_w = icon_h * 1.7
    bar_x1 = wifi_cx - icon_h - gap
    bar_x0 = bar_x1 - bars_w
    n = 4
    bar_gap = bars_w * 0.12
    bar_w = (bars_w - bar_gap * (n - 1)) / n
    base_y = mid_y + icon_h * 0.5
    for i in range(n):
        bh = icon_h * (0.35 + 0.22 * i)
        x0 = bar_x0 + i * (bar_w + bar_gap)
        x1 = x0 + bar_w
        y1 = base_y
        y0 = base_y - bh
        draw.rounded_rectangle([(x0, y0), (x1, y1)], radius=bar_w * 0.25, fill=color)

    return bar_x0


def build_status_bar(width, bg_color):
    # Height is a fixed fraction of the standard 1080x2424 source captures'
    # full screen height (not of `width`), so it matches real status-bar
    # proportions regardless of how much of the screenshot got cropped.
    status_h = round(2424 * STATUS_BAR_FRACTION)

    bar = Image.new("RGB", (width, status_h), bg_color)
    draw = ImageDraw.Draw(bar)

    text_color = (0x1A, 0x1A, 0x1A) if luminance(bg_color) > 140 else (0xFF, 0xFF, 0xFF)

    font_size = round(status_h * 0.46)
    try:
        font = ImageFont.truetype(STATUS_FONT_PATH, font_size)
    except OSError:
        font = ImageFont.truetype(BODY_FONT_PATH, font_size)
    pad_x = round(width * 0.045)
    draw.text((pad_x, status_h / 2), "9:41", font=font, fill=text_color, anchor="lm")

    icon_h = status_h * 0.42
    draw_status_bar_icons(draw, width - pad_x, status_h / 2, icon_h, text_color)

    # Centered punch-hole camera.
    r = status_h * PUNCH_HOLE_FRACTION / 2
    cx, cy = width / 2, status_h / 2
    draw.ellipse([(cx - r, cy - r), (cx + r, cy + r)], fill=(0, 0, 0))

    return bar, status_h


def sample_bg_color(img, y=2):
    row = [img.getpixel((x, y)) for x in range(0, img.width, max(1, img.width // 40))]
    r = sum(p[0] for p in row) // len(row)
    g = sum(p[1] for p in row) // len(row)
    b = sum(p[2] for p in row) // len(row)
    return (r, g, b)


def build_phone_frame(screenshot_path, frame_top, frame_bottom, crop_top=0):
    frame_h = frame_bottom - frame_top
    shot = Image.open(screenshot_path).convert("RGB")
    if crop_top:
        shot = shot.crop((0, crop_top, shot.width, shot.height))

    bg_color = sample_bg_color(shot)
    status_bar, status_h = build_status_bar(shot.width, bg_color)
    combined = Image.new("RGB", (shot.width, shot.height + status_h))
    combined.paste(status_bar, (0, 0))
    combined.paste(shot, (0, status_h))
    shot = combined

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
    # Thin highlight ring for a machined-metal edge look.
    bezel_draw.rounded_rectangle(
        [(0, 0), (bezel.width - 1, bezel.height - 1)],
        radius=FRAME_CORNER_R + BEZEL_WIDTH,
        outline=BEZEL_HIGHLIGHT,
        width=max(1, round(SCALE * 1.2)),
    )

    shot_resized = shot.resize((frame_w, frame_h), Image.Resampling.LANCZOS)
    inner_mask = rounded_mask((frame_w, frame_h), FRAME_CORNER_R)
    bezel.paste(shot_resized, (BEZEL_WIDTH, BEZEL_WIDTH), inner_mask)

    # Power button (right edge) and volume rocker (left edge) for a
    # recognizable Galaxy S silhouette.
    btn_color = BEZEL_HIGHLIGHT
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
    draw = ImageDraw.Draw(canvas)

    draw_headline(draw, entry["headline"])

    frame_top = TOP_MARGIN + HEADLINE_BLOCK_H
    frame_bottom = H - BOTTOM_MARGIN
    screenshot_path = os.path.join(SCREENSHOTS_DIR, entry["screenshot"])
    bezel, bezel_x, shadow, shadow_pad = build_phone_frame(
        screenshot_path, frame_top, frame_bottom, entry.get("crop_top", 0)
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
