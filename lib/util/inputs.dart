String stringifyOptionalInt(int? value) => value?.toString() ?? "";

int? parseOptionalInt(String repr) => repr.isEmpty ? null : int.parse(repr);
