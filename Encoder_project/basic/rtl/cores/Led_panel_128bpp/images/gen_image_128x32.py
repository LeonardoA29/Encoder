#!/usr/bin/env python3
"""
gen_panel_hex.py
Genera 6 archivos .hex: imageR0.hex, imageG0.hex, imageB0.hex, imageR1.hex, imageG1.hex, imageB1.hex
Cada archivo contiene 4096 palabras (16-bit) en orden row-major para su segmento (32 filas x 128 columnas).

Uso:
    python gen_panel_hex.py input_image.png

Dependencias:
    pip install pillow numpy
"""
import sys
from PIL import Image
import numpy as np
from pathlib import Path

EXPECTED_W = 128
EXPECTED_H = 64
SEGMENT_ROWS = 32
WORDS_PER_FILE = 4096  # 128 * 32

def ensure_rgb(im: Image.Image) -> Image.Image:
    if im.mode != "RGB":
        return im.convert("RGB")
    return im

def map_8_to_16(arr8: np.ndarray) -> np.ndarray:
    # arr8: uint8 array 0..255 -> returns uint16 array 0..65535
    # exact scale: val16 = val8 * 257  (65535/255 = 257)
    return (arr8.astype(np.uint16) * 257).astype(np.uint16)

def create_hex_file(values16: np.ndarray, filename: Path, little_endian_bytes: bool = False):
    """
    values16: 1D array length 4096 of dtype uint16
    Writes one 4-hex-digit value per line (address 0..4095).
    If little_endian_bytes=True, the bytes are swapped before writing (i.e. low byte first)
    """
    assert values16.size == WORDS_PER_FILE
    with open(filename, "w") as f:
        for v in values16:
            if little_endian_bytes:
                # swap bytes for little-endian visual (optional)
                lo = v & 0xFF
                hi = (v >> 8) & 0xFF
                val = (lo << 8) | hi
            else:
                val = int(v)
            f.write(f"{val:04X}\n")

def main():
    if len(sys.argv) < 2:
        print("Uso: python gen_panel_hex.py ruta/imagen.png")
        sys.exit(1)

    img_path = Path(sys.argv[1])
    if not img_path.exists():
        print("Archivo no encontrado:", img_path)
        sys.exit(1)

    im = Image.open(img_path)
    im = ensure_rgb(im)

    # Resize if necessary (preferencia: error en lugar de reescalar? -> aquí hacemos resize con nearest)
    if im.width != EXPECTED_W or im.height != EXPECTED_H:
        print(f"Advertencia: la imagen tiene tamaño {im.width}x{im.height}, se redimensionará a {EXPECTED_W}x{EXPECTED_H} (nearest).")
        im = im.resize((EXPECTED_W, EXPECTED_H), resample=Image.NEAREST)

    # Convert to numpy array shape (H, W, 3)
    arr = np.array(im, dtype=np.uint8)
    # We'll split into two segments: seg0 rows 0..31, seg1 rows 32..63
    out_dir = Path.cwd()

    for seg in (0, 1):
        row_start = seg * SEGMENT_ROWS
        row_end = row_start + SEGMENT_ROWS
        segment = arr[row_start:row_end, :, :]  # shape (32, 128, 3)

        # flatten in row-major order: rows first, then cols
        # For each channel create a 1D array length 4096 of uint16
        for ch_idx, ch_name in enumerate(("R", "G", "B")):
            channel8 = segment[:, :, ch_idx]  # shape (32,128)
            channel8_flat = channel8.reshape(-1)  # length 4096, row-major
            channel16_flat = map_8_to_16(channel8_flat)  # uint16 array length 4096

            filename = out_dir / f"image{ch_name}{seg}.hex"
            create_hex_file(channel16_flat, filename, little_endian_bytes=False)
            print(f"Wrote {filename} ({WORDS_PER_FILE} words)")

    print("Hecho. Archivos generados en:", out_dir)

if __name__ == "__main__":
    main()
