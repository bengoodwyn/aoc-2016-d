import std.stdio;
import std.string;
import std.typecons;

alias Job = Tuple!(int,int,string);

immutable Job[] jobs = [
    tuple(1, 1, ","),
    tuple(1, 2, ","),
    tuple(2, 1, "\\n"),
    tuple(2, 2, "\\n")
];

auto input(int day) {
    return File("inputs/day%d.txt".format(day));
}

void main() {
    static foreach (job; jobs) {
        mixin(
            (`import day%d;` ~
            `write("Day %d Part %d: ");` ~
            `writeln(day%d.part%d(input(%d).byLine(KeepTerminator.no,'%s')));`)
            .format(job[0],job[0],job[1],job[0],job[1],job[0],job[2]));
    }
}