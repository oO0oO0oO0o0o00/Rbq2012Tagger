from pathlib import Path


image_extensions = [
    "png", "jpg", "jpeg", "gif", "webp", "bmp"
]

image_suffixes = ["." + x for x in image_extensions]

def is_image(path: Path):
    return path.suffix.lower() in image_suffixes
