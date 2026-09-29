#!/usr/bin/env python3
import os
import sys
from pathlib import Path
from PIL import Image

V1_ROOT = Path(__file__).resolve().parent.parent

def test_hires_scaling_invertibility():
    native_path = V1_ROOT / "masters" / "native" / "TimeDuck-Native-Neutral.png"
    native_img = Image.open(native_path).convert("RGBA")
    native_pixels = native_img.load()

    scales = [2, 4, 8, 16, 32, 64]
    for scale in scales:
        hires_path = V1_ROOT / "hi-res" / f"{scale}x" / f"TimeDuck-Neutral-{scale}x.png"
        hires_img = Image.open(hires_path).convert("RGBA")
        
        # Downscale by exact factor using NEAREST
        down_img = hires_img.resize((13, 10), Image.NEAREST)
        down_pixels = down_img.load()

        for y in range(10):
            for x in range(13):
                if native_pixels[x, y] != down_pixels[x, y]:
                    raise AssertionError(f"Scaling invertibility failed for {scale}x at ({x},{y})")
    return True

def test_webp_decode_integrity():
    native_png = Image.open(V1_ROOT / "masters" / "native" / "TimeDuck-Native-Neutral.png").convert("RGBA")
    native_webp = Image.open(V1_ROOT / "webp" / "transparent" / "TimeDuck-Neutral.webp").convert("RGBA")
    
    png_pix = native_png.load()
    webp_pix = native_webp.load()

    for y in range(10):
        for x in range(13):
            if png_pix[x, y] != webp_pix[x, y]:
                raise AssertionError(f"WebP lossless decode mismatch at ({x},{y})")
    return True

def test_palette_fidelity():
    allowed_colors = {
        (255, 216, 77, 255),   # duckBody
        (201, 166, 46, 255),   # duckShad
        (255, 138, 60, 255),   # duckBill
        (20, 20, 32, 255),     # duckEye
        (255, 255, 255, 255),  # white
        (0, 0, 0, 0)           # transparent
    }
    native_png = Image.open(V1_ROOT / "masters" / "native" / "TimeDuck-Native-Neutral.png").convert("RGBA")
    pixels = native_png.load()
    for y in range(10):
        for x in range(13):
            p = pixels[x, y]
            if p not in allowed_colors:
                raise AssertionError(f"Illegal color {p} detected at ({x},{y}) in neutral master")
    return True

if __name__ == "__main__":
    test_hires_scaling_invertibility()
    test_webp_decode_integrity()
    test_palette_fidelity()
    print("All automated QA integrity checks PASSED (100% compliance).")
