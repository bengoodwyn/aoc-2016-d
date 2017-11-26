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
