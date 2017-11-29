import std.range;
import assembunny;

int part1(T)(T code) {
    return code.collect_instructions.execute[resolve_register("a")];
}

int part2(T)(T code) {
    auto modified_code = ["cpy 1 c"].chain(code);
    return part1(modified_code);
}

unittest {
    immutable sample_code =
    [
        "cpy 41 a",
        "inc a",
        "inc a",
        "dec a",
        "jnz a 2",
        "dec a"
    ];

    assert(42 == part1(sample_code));
}
