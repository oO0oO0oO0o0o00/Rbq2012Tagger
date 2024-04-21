import itertools
from pathlib import Path
import sqlite3
from typing import Optional

from api.backup import BackupConfig


class AlbumDB:
    def __init__(self, path: Path):
        if path.suffix != ".db":
            path /= ".rbq2012.tagger/album.db"
        if path.exists():
            self._db_path = path
        else:
            self._db_path = None
        self._conn: Optional[sqlite3.Connection] = None
    
    @property
    def recycle_path(self) -> Path:
        return self._db_path.parent / "recycle"

    @staticmethod
    def open_or_raise(path: Path) -> "AlbumDB":
        db = AlbumDB(path)
        if db._db_path is None:
            raise FileNotFoundError("Create album with the App first.")
        return db
    
    @property
    def is_valid(self) -> bool:
        return self._db_path is not None

    def __enter__(self):
        self._conn = sqlite3.connect(self._db_path)
        self._conn.__enter__()
        return self

    def __exit__(self, *args, **kwargs):
        self._conn.__exit__(*args, **kwargs)
        self._conn = None

    def cursor(self) -> sqlite3.Cursor:
        return self._conn.cursor()
    
    def commit(self):
        self._conn.commit()

    def insert(
            self, path: Path, tags: list[str], cursor: Optional[sqlite3.Cursor] = None
        ):
        self.insert_all([path], tags, cursor)

    def insert_all(
            self, paths: list[Path], tags: list[str], cursor: Optional[sqlite3.Cursor]
        ):
        if not tags:
            return
        db = cursor or self._conn
        db.execute(
            f"INSERT OR IGNORE INTO tagged(name, tag) VALUES {', '.join(['(?, ?)'] * len(tags))}",
            [e for p in itertools.product([path.name for path in paths], tags) for e in p])

    def fetch(
            self, path: Path, cursor: Optional[sqlite3.Cursor] = None
        ) -> list[str]:
        db = cursor or self._conn
        res = db.execute("SELECT tag FROM tagged WHERE name = ?", [path.name])
        return [x[0] for x in res.fetchall()]
    
    def backup(self, config: Optional["BackupConfig"] = None):
        (config or BackupConfig()).backup()

