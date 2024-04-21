from pathlib import Path
import random

from loguru import logger

from api.db import AlbumDB
from api.ftypes import is_image


def main(von, nach):
    paths = [von]
    von_root = von
    idx = 0
    while idx < len(paths):
        von = paths[idx]
        logger.info("merging {}...", von)
        merge(von, von_root, nach)
        paths += [
            d for d in von.iterdir()
            if not d.name.startswith(".") and d.is_dir()
        ]
        idx += 1


def merge(from_path: Path, root: Path, to_path: Path):
    renames = [
        (src, resolve_move_conflict(src, to_path))
        for src in from_path.iterdir() if is_image(src)
    ]
    if not renames:
        return
    from_db = AlbumDB(from_path)
    additional_tags = list(from_path.relative_to(root).parts)
    if from_db.is_valid or additional_tags:
        with AlbumDB.open_or_raise(to_path) as to_db:
            if from_db.is_valid:
                with from_db:
                    for src, dst in renames:
                        to_db.insert(path=dst, tags=from_db.fetch(path=src))
            for _, dst in renames:
                to_db.insert(path=dst, tags=additional_tags)
    for src, dst in renames:
        src.rename(dst)


def resolve_move_conflict(src: Path, dest_folder: Path):
    dest = dest_folder / src.name
    if not dest.exists():
        return dest
    base_name, suffix_name = src.stem, src.suffix
    folder_name = src.parent.name
    dest = dest_folder / f"{base_name}-{folder_name}{suffix_name}"
    if not dest.exists():
        return dest
    for _ in range(10):
        dest = dest_folder / f"{base_name}-{folder_name}-{random.randint()}{suffix_name}"
        if dest.exists():
            continue
        return dest
    raise FileExistsError(
        f"Cannot generate a name for {src} in {dest_folder}."
    )


root = Path(r"D:\LOFL\repositories")
main(root / "oldPictures", root / "Pictures")
# root = Path(r"C:\Users\barco\Pictures\exp")
# main(root / "root", root / "dst")
