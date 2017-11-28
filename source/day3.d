import std.algorithm;
import std.conv;
import std.string;

auto part1(T)(T lines) {
    return lines
            .map!split
            .map!(x => [ to!int(x[0]), to!int(x[1]), to!int(x[2]) ])
            .map!sort
            .filter!(x => (x[0] + x[1]) > x[2])
            .count();
}

unittest {
    assert(0 == part1(["5 10 25"]));
    assert(0 == part1(["25 10 5"]));
    assert(1 == part1(["5 21 25"]));
    assert(1 == part1(["25 21 5"]));
}

int[] group9(int[] accum, int x) {
    if (accum.length == 9) {
        return [x];
    } else {
        return accum ~ x;
    }
}

auto adapt(T)(T lines) {
    int[] seed;
    return lines
            .map!split
            .joiner
            .map!(x => to!int(x))
            .cumulativeFold!(group9)(seed)
            .filter!(x => x.length == 9)
            .map!(x => [
                    "%d %d %d".format(x[0],x[3],x[6]),
                    "%d %d %d".format(x[1],x[4],x[7]),
                    "%d %d %d".format(x[2],x[5],x[8])
                ])
            .joiner;
}

auto part2(T)(T lines) {
    auto vertical_lines = adapt(lines);

    return part1(vertical_lines);
}

