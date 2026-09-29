#!/usr/bin/env python3
"""
TimeDuck Standalone Reconstruction Validation Test
=================================================
Composites isolated components from construction/components/ and asserts 100% pixel match.
"""

from pathlib import Path
from PIL import Image

CONST_ROOT = Path(__file__).resolve().parent.parent

DUCK_BASE_MATRIX = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwy....",
    "..yyyyyyooo..",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

COLOR_MAP = {
    "y": (255, 216, 77, 255),
    "d": (201, 166, 46, 255),
    "o": (255, 138, 60, 255),
    "k": (20, 20, 32, 255),
    "w": (255, 255, 255, 255),
    ".": (0, 0, 0, 0)
}

def matrix_to_image(matrix):
    h = len(matrix)
    w = len(matrix[0])
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    pixels = img.load()
    for y, row in enumerate(matrix):
        for x, ch in enumerate(row):
            if ch in COLOR_MAP:
                pixels[x, y] = COLOR_MAP[ch]
            else:
                pixels[x, y] = (0, 0, 0, 0)
    return img

def test_reconstruction():
    auth_master = matrix_to_image(DUCK_BASE_MATRIX)
    auth_pixels = auth_master.load()

    reconstructed = Image.new("RGBA", (13, 10), (0, 0, 0, 0))
    components_to_composite = [
        CONST_ROOT / "components" / "tail" / "comp_tail_neutral.png",
        CONST_ROOT / "components" / "body" / "comp_body_core.png",
        CONST_ROOT / "components" / "shading" / "comp_shading_underbelly.png",
        CONST_ROOT / "components" / "head" / "comp_head_crown_skull.png",
        CONST_ROOT / "components" / "beak" / "comp_beak_neutral.png",
        CONST_ROOT / "components" / "eyes" / "comp_eye_neutral_open.png",
        CONST_ROOT / "components" / "feet" / "comp_feet_standing.png",
    ]

    for comp_path in components_to_composite:
        comp_img = Image.open(comp_path).convert("RGBA")
        reconstructed.alpha_composite(comp_img)

    rec_pixels = reconstructed.load()

    for y in range(10):
        for x in range(13):
            if auth_pixels[x, y] != rec_pixels[x, y]:
                raise AssertionError(f"Reconstruction mismatch at ({x},{y}): expected {auth_pixels[x, y]}, got {rec_pixels[x, y]}")

    print("Reconstruction Validation Test: 100% BIT-FOR-BIT MATCH PASSED.")
    return True

if __name__ == "__main__":
    test_reconstruction()
