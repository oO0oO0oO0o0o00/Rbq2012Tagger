from collections import Counter
from pathlib import Path
from api.db import AlbumDB

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


def txt2db(path):
    with AlbumDB(path) as db:
        cursor = db.cursor()
        for file in path.glob("*.txt"):
            db.insert(cursor, next(x for x in path.glob(
                f"{file.stem}.*") if x.suffix != ".txt"), load_txt(file))
        db.commit()


def db2txt(path):
    with AlbumDB(path) as db:
        cursor = db.cursor()
        for file in path.glob("*.txt"):
            save_txt(file, db.fetch(cursor, next(x for x in path.glob(
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
