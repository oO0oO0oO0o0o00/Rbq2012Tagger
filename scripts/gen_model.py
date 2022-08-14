def do(name: str, fields: list[tuple[str, bool, tuple]]):
    OPEN, CLOSE, IND, NL, DQ = '{', '}', '    ', '\n', '"'
    class_name = chcase(name, pascal=True)
    print(
        f"""{name}.dart:

class {class_name} {OPEN}
    static final tableName = "{name}";
    {f'{NL}{IND}'.join([f"static const col{chcase(field[0], pascal=True)} = {DQ}{field[0]}{DQ};" for field in fields])}

    {f'{NL}{IND}'.join([f"{'' if field[1] else 'final '}{field[2][1]}{'?' if field[1] else ''} {chcase(field[0])};" for field in fields])}

    {class_name}({OPEN}
        {', '.join([f"{'' if field[1] else 'required '}this.{chcase(field[0])}" for field in fields])}
    {CLOSE});

    {class_name}.fromMap(Map<String, Object?> map)
        : {f',{NL}{IND}{IND}'.join([
            f"{chcase(field[0])} = {field[2][5 if field[1] else 4].format(f'map[col{chcase(field[0], pascal=True)}]')}"
            for field in fields
        ])};

    Map<String, Object?> toMap() => {OPEN}{NL}{IND}{IND}{f',{NL}{IND}{IND}'.join([
        f"col{chcase(field[0], pascal=True)}: {field[2][3 if field[1] else 2].format(chcase(field[0]))}"
        for field in fields
    ])};{NL}{IND}{CLOSE}

{CLOSE}


{name}_viewmodel.dart:

class {class_name}ViewModel with ChangeNotifier {OPEN}
    {class_name}? _model;
    {f'{NL}{IND}'.join([
        f"{field[2][1]}? get {chcase(field[0])} => _model?.{chcase(field[0])};{NL}{NL}{IND}"
        f"set {chcase(field[0])}({field[2][1]}? value) {OPEN}{NL}{IND}{IND}"
        f"final model = _model;{NL}{IND}{IND}if (model == null || value == model.{chcase(field[0])}) return;{NL}{IND}{IND}model.{chcase(field[0])} = value;{NL}{IND}{IND}notifyListeners();{NL}{IND}{IND}{CLOSE}{NL}"
        for field in fields
    ])}
{CLOSE}


{name}_service.dart:

class {class_name}Service {OPEN}
    static Future<void> createTable(Database db, int version) async {OPEN}
        await db.execute('CREATE TABLE ${OPEN}{class_name}.tableName{CLOSE} ('
        {f',{NL}{IND}{IND}'.join([f"${OPEN}{class_name}.col{chcase(field[0], pascal=True)}{CLOSE} {field[2][0]}" for field in fields])}\
) WITHOUT ROWID');
    {CLOSE}
{CLOSE}
        """)


def chcase(identifier, pascal=False):
    parts = identifier.split('_')
    for i in range(0 if pascal else 1, len(parts)):
        parts[i] = f"{parts[i][0].upper()}{parts[i][1:]}"
    return ''.join(parts)


class Dtypes:
    string = ("TEXT", "String", "{}", "{}", "{} as String", "{} as String?")
    int = ("INT", "int", "{}", "{}", "{} as int", "{} as int?")
    bool = ("INT", "bool", "{}", "{}", "{} as int != 0",
            "{0} == null ? null : ({0} as int != 0)")
    datetime = ("INT", "DateTime", "{}.millisecondsSinceEpoch",
                "{}?.millisecondsSinceEpoch",
                "DateTime.fromMillisecondsSinceEpoch({} as int)",
                "{0} == null ? null : DateTime.fromMillisecondsSinceEpoch({0} as int)")


if __name__ == '__main__':
    do("search_options", [
        ("name", False, Dtypes.string),
        ("by_name", True, Dtypes.string),
        ("by_name_case", True, Dtypes.bool),
        ("from_time", True, Dtypes.datetime),
        ("to_time", True, Dtypes.datetime),
        ("from_size_kb", True, Dtypes.int),
        ("to_size_kb", True, Dtypes.int),
        ("tags", True, Dtypes.string),
        ("xtags", True, Dtypes.string),
    ])
