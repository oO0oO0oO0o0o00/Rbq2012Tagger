from datetime import datetime, timedelta
from pathlib import Path
import re
import shutil
from typing import Optional


class BackupConfig:
    _datetime_format = '%Y%m%d-%H%M%S-%f'
    def __init__(
            self, maxCount: Optional[int] = None, maxDays: Optional[int] = None
    ) -> None:
        assert maxCount is None or maxCount > 0
        assert maxDays is None or maxDays > 0
        self.maxCount = maxCount
        self.maxDays = maxDays

    def backup(self, target: Path) -> Path:
        backup = BackupConfig._backup_folder(target) \
            / datetime.now().strftime(BackupConfig._datetime_format)
        shutil.copy(target, backup)
        self._trim(target)
        return backup

    def _trim(self, target: Path):
        backups = [
            (p, BackupConfig._parse_datetime())
            for p in BackupConfig._backup_folder(target)
                .glob(f"{target.stem}-*{target.suffix}")
        ]
        backups.sort(lambda x: x[1], reverse=True)
        keep = backups[:self.maxCount or len(backups)]
        if self.maxDays:
            oldest = datetime.now() - timedelta(days=self.maxDays)
            keep = [x for x in backups if x[1] > oldest]
        for backup in backups:
            if backup not in keep:
                backup[0].unlink()

    def _backup_folder(target: Path) -> Path:
        return target.parent / "backup"

    def _parse_datetime(name: str, path: Path):
        match = re.match(r'.+-(\d8-\d6-\d2)', path.stem)
        if match is None:
            return None
        try:
            return datetime.strptime(f"{match.group(1)}0000", BackupConfig._datetime_format)
        except ValueError:
            return None
