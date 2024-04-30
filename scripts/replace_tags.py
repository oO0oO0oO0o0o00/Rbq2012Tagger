from pathlib import Path
from typing import Optional, Union

from api.db import AlbumDB

def placeholders(count: Union[int, list], *, text: Optional[str] = None):
    if isinstance(count, list):
        count = len(count)
    text = text or "?"
    return ",".join([text] * count)

def main(path: Path):
    cond_tags = ["records"]
    to_tags = ["snap"]
    rm_tags = ["records"]
    with AlbumDB(path) as db:
        db.cursor().execute(f"""
insert or ignore into tagged(name, tag)
select name, tmp.* from tagged
cross join (values {placeholders(to_tags, text='(?)')}) as tmp
where tag in ({placeholders(cond_tags)})
""", [*to_tags, *cond_tags]).execute(f"""
delete from tagged where name in (
    select name from tagged where tag in ({placeholders(cond_tags)})
) and tag in ({placeholders(rm_tags)})
""", [*cond_tags, *rm_tags])


main(Path(r"F:\LOFL\repositories\Pictures"))
