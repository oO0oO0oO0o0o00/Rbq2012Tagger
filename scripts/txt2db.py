from collections import Counter
from pathlib import Path
import sqlite3


k_escape_char = '\\'
k_escaped_chars = set(x for x in '()[]\\')
k_whitespaces = set(x for x in ', \r\n')

i_path = Path(
    r"C:\Users\barco\repos\inferences\train_1\makat_proc\fastvalid_crop_prepro")
i_rm_tags = set(["photo_(medium)", "lips"])
# "realistic", "1girl", "photorealistic"
# i_insert_tags = ["rbq2012"]
i_insert_tags = []
i_rm_tags |= set(i_insert_tags)


def load_txt(path):
    with open(path) as fp:
        data = fp.read()
    result = []
    buf = []
    escaping = False

    def fin():
        if len(buf) > 0:
            result.append(''.join(buf))
            buf.clear()

    for ch in data:
        if escaping:
            escaping = False
            buf.append(ch)
        elif ch == k_escape_char:
            escaping = True
        elif ch in k_whitespaces:
            fin()
        else:
            buf.append(ch)
    fin()
    return result


def save_txt(path, tags, sep=', '):
    data = sep.join(''.join(
        (k_escape_char + ch) if ch in k_escaped_chars else ch for ch in tag
    ) for tag in tags)
    with open(path, 'w') as fp:
        fp.write(data)


def open_db(path: Path) -> sqlite3.Connection:
    db_path = path / ".rbq2012.tagger/album.db"
    if not db_path.exists():
        raise RuntimeError("Create album with the App first.")
    return sqlite3.connect(db_path)


def save_db(db: sqlite3.Cursor, path, tags):
    for tag in tags:
        db.execute("INSERT OR IGNORE INTO tagged(name, tag) values (?, ?)", [path.name, tag])


def load_db(db: sqlite3.Cursor, path):
    res = db.execute("SELECT tag FROM tagged WHERE name = ?", [path.name])
    return res.fetchall()


def txt2db(path):
    with open_db(path) as db:
        cursor = db.cursor()
        for file in path.glob("*.txt"):
            save_db(cursor, next(x for x in path.glob(
                f"{file.stem}.*") if x.suffix != ".txt"), load_txt(file))
        db.commit()


def db2txt(path):
    with open_db(path) as db:
        cursor = db.cursor()
        for file in path.glob("*.txt"):
            save_txt(file, load_db(cursor, next(x for x in path.glob(
                f"{file.stem}.*") if x.suffix != ".txt")))


def stat_txt(path):
    counter = Counter()
    for file in path.glob("*.txt"):
        for tag in load_txt(file):
            counter[tag] += 1
    print(counter)


def filter_txt(path):
    for file in path.glob("*.txt"):
        tags = i_insert_tags + [x for x in load_txt(file) if x not in i_rm_tags]
        save_txt(file, tags)


if __name__ == '__main__':
    # txt2db(i_path)
    db2txt(i_path)
    # filter_txt(i_path)
