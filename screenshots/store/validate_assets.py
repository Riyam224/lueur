#!/usr/bin/env python3
"""One-time validation of Google Play store assets against technical requirements.

Checks screenshots/store/store-screenshot-*.png and feature-graphic-1024x500.png
against Google Play's documented technical requirements. Does not fix anything,
only reports pass/fail per rule.
"""

import glob
import os
import re

from PIL import Image

STORE_DIR = os.path.dirname(os.path.abspath(__file__))

SCREENSHOT_MIN_SIDE = 320
SCREENSHOT_MAX_SIDE = 3840
SCREENSHOT_MAX_ASPECT = 2.0
SCREENSHOT_MAX_BYTES = 8 * 1024 * 1024

FEATURE_GRAPHIC_NAME = "feature-graphic-1024x500.png"
FEATURE_GRAPHIC_EXACT_SIZE = (1024, 500)
FEATURE_GRAPHIC_SANITY_MAX_BYTES = 15 * 1024 * 1024

VALID_FORMATS = {"PNG", "JPEG"}


def human_size(num_bytes):
    if num_bytes >= 1024 * 1024:
        return f"{num_bytes / (1024 * 1024):.2f} MB"
    return f"{num_bytes / 1024:.1f} KB"


def check_screenshot(path):
    filename = os.path.basename(path)
    file_size = os.path.getsize(path)

    with Image.open(path) as img:
        fmt = img.format
        mode = img.mode
        width, height = img.size

    checks = []

    fmt_ok = fmt in VALID_FORMATS
    checks.append(("Format is PNG or JPEG", fmt_ok, f"got {fmt}"))

    if fmt == "PNG":
        alpha_ok = mode == "RGB"
        checks.append(
            (
                "No alpha channel (RGB, not RGBA)",
                alpha_ok,
                f"mode is {mode}" if not alpha_ok else "",
            )
        )
    else:
        checks.append(("No alpha channel (RGB, not RGBA)", True, "N/A (not PNG)"))

    sides_ok = all(SCREENSHOT_MIN_SIDE <= s <= SCREENSHOT_MAX_SIDE for s in (width, height))
    checks.append(
        (
            f"Sides within [{SCREENSHOT_MIN_SIDE}, {SCREENSHOT_MAX_SIDE}]px",
            sides_ok,
            f"got {width}x{height}" if not sides_ok else "",
        )
    )

    longer, shorter = max(width, height), min(width, height)
    aspect = longer / shorter if shorter else float("inf")
    aspect_ok = aspect <= SCREENSHOT_MAX_ASPECT
    checks.append(
        (
            f"Aspect ratio <= {SCREENSHOT_MAX_ASPECT}:1",
            aspect_ok,
            f"got {aspect:.3f}:1" if not aspect_ok else "",
        )
    )

    size_ok = file_size < SCREENSHOT_MAX_BYTES
    checks.append(
        (
            "File size < 8MB",
            size_ok,
            f"got {human_size(file_size)}" if not size_ok else "",
        )
    )

    return {
        "filename": filename,
        "dimensions": f"{width}x{height}",
        "mode": mode,
        "format": fmt,
        "file_size": human_size(file_size),
        "checks": checks,
        "passed": all(ok for _, ok, _ in checks),
    }


def check_feature_graphic(path):
    filename = os.path.basename(path)
    file_size = os.path.getsize(path)

    with Image.open(path) as img:
        fmt = img.format
        mode = img.mode
        width, height = img.size

    checks = []

    fmt_ok = fmt in VALID_FORMATS
    checks.append(("Format is PNG or JPEG", fmt_ok, f"got {fmt}"))

    if fmt == "PNG":
        alpha_ok = mode == "RGB"
        checks.append(
            (
                "No alpha channel (RGB, not RGBA)",
                alpha_ok,
                f"mode is {mode}" if not alpha_ok else "",
            )
        )
    else:
        checks.append(("No alpha channel (RGB, not RGBA)", True, "N/A (not PNG)"))

    exact_ok = (width, height) == FEATURE_GRAPHIC_EXACT_SIZE
    checks.append(
        (
            f"Dimensions exactly {FEATURE_GRAPHIC_EXACT_SIZE[0]}x{FEATURE_GRAPHIC_EXACT_SIZE[1]}",
            exact_ok,
            f"got {width}x{height}" if not exact_ok else "",
        )
    )

    size_ok = file_size <= FEATURE_GRAPHIC_SANITY_MAX_BYTES
    checks.append(
        (
            "File size <= 15MB (sanity check)",
            size_ok,
            f"got {human_size(file_size)}" if not size_ok else "",
        )
    )

    return {
        "filename": filename,
        "dimensions": f"{width}x{height}",
        "mode": mode,
        "format": fmt,
        "file_size": human_size(file_size),
        "checks": checks,
        "passed": all(ok for _, ok, _ in checks),
    }


def print_report(result):
    status = "PASS" if result["passed"] else "FAIL"
    print(f"\n{result['filename']}  [{status}]")
    print(
        f"  dimensions={result['dimensions']}  mode={result['mode']}  "
        f"format={result['format']}  size={result['file_size']}"
    )
    for label, ok, detail in result["checks"]:
        mark = "PASS" if ok else "FAIL"
        suffix = f" -- {detail}" if detail and not ok else ""
        print(f"    [{mark}] {label}{suffix}")


def natural_key(path):
    m = re.search(r"store-screenshot-(\d+)\.png$", path)
    return int(m.group(1)) if m else 0


def main():
    screenshot_paths = sorted(
        glob.glob(os.path.join(STORE_DIR, "store-screenshot-*.png")),
        key=natural_key,
    )

    print("=" * 70)
    print("GOOGLE PLAY STORE ASSET VALIDATION")
    print("=" * 70)

    print(f"\nFound {len(screenshot_paths)} store-screenshot-*.png file(s):")
    for p in screenshot_paths:
        print(f"  - {os.path.basename(p)}")

    screenshot_results = [check_screenshot(p) for p in screenshot_paths]

    print("\n" + "-" * 70)
    print("PHONE SCREENSHOTS")
    print("-" * 70)
    for result in screenshot_results:
        print_report(result)

    feature_graphic_path = os.path.join(STORE_DIR, FEATURE_GRAPHIC_NAME)
    feature_result = None
    print("\n" + "-" * 70)
    print("FEATURE GRAPHIC")
    print("-" * 70)
    if os.path.exists(feature_graphic_path):
        feature_result = check_feature_graphic(feature_graphic_path)
        print_report(feature_result)
    else:
        print(f"\n{FEATURE_GRAPHIC_NAME}  [FAIL] -- file not found")

    print("\n" + "-" * 70)
    print("COUNT CHECK")
    print("-" * 70)
    count = len(screenshot_paths)
    count_ok = 2 <= count <= 8
    print(f"\nTotal screenshots ready for submission: {count}")
    print(f"Files: {', '.join(os.path.basename(p) for p in screenshot_paths)}")
    print(f"Within Google Play's required range of 2-8: {'PASS' if count_ok else 'FAIL'}")

    print("\n" + "=" * 70)
    print("SUMMARY")
    print("=" * 70)

    passed_screenshots = [r for r in screenshot_results if r["passed"]]
    failed_screenshots = [r for r in screenshot_results if not r["passed"]]

    print(
        f"\n{len(passed_screenshots)}/{len(screenshot_results)} screenshots "
        f"pass all checks."
    )

    if failed_screenshots:
        print("\nFailures:")
        for r in failed_screenshots:
            for label, ok, detail in r["checks"]:
                if not ok:
                    print(f"  - {r['filename']}: {label} -- {detail}")

    if feature_result is not None:
        fg_status = "PASS" if feature_result["passed"] else "FAIL"
        print(f"\nFeature graphic: {fg_status}")
        if not feature_result["passed"]:
            for label, ok, detail in feature_result["checks"]:
                if not ok:
                    print(f"  - {feature_result['filename']}: {label} -- {detail}")
    else:
        print(f"\nFeature graphic: FAIL -- {FEATURE_GRAPHIC_NAME} not found")

    print(f"\nCount check: {'PASS' if count_ok else 'FAIL'} ({count} screenshots, need 2-8)")

    overall_ok = (
        not failed_screenshots
        and feature_result is not None
        and feature_result["passed"]
        and count_ok
    )
    print(f"\nOVERALL: {'ALL CHECKS PASSED' if overall_ok else 'ISSUES FOUND -- SEE ABOVE'}")


if __name__ == "__main__":
    main()
