import assembunny;

int part1(T)(T code) {
    return code.collect_instructions.execute[resolve_register('a')];
}

unittest {
    immutable sample_code =
    [
        "cpy 2 a",
        "tgl a",
        "tgl a",
        "tgl a",
        "cpy 1 a",
        "dec a",
        "dec a",
    ];

    assert(3 == part1(sample_code));
}
