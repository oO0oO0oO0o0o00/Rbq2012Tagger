import json
from pathlib import Path

from api.db import AlbumDB


def main(root: Path):
    with AlbumDB(root) as db:
        recycle = db.recycle_path
        if not recycle.exists():
            return
        for file in recycle.iterdir():
            if file.suffix == ".json" or not file.is_file():
                continue
            json_path = recycle / f"{file.stem}.json"
            if not json_path.exists():
                continue
            tags = json.load(open(json_path))
            dst = root / file.name
            file.rename(dst)
            db.insert(dst, tags)
            json_path.unlink()


main(Path(r"C:\Users\barco\Pictures\Saved Pictures"))
