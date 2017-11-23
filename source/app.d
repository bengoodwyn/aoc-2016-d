import std.stdio;
import std.string;
import std.typecons;

alias Job = Tuple!(int,string);

immutable Job[] jobs = [
    tuple(1, ","),
    tuple(2, "\\n")
];

auto input(int day) {
    return File("inputs/day%d.txt".format(day));
}

void main() {
    static foreach (job; jobs) {
        static foreach (part; 1..3) {
            mixin((
                `import day%d;` ~
                `write("Day %d Part %d: ");` ~
                `writeln(day%d.part%d(input(%d).byLine(KeepTerminator.no,'%s')));`
                ).format(job[0],job[0],part,job[0],part,job[0],job[1]));
        }
    }
}