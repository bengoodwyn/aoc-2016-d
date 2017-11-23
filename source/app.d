import std.stdio;
import std.string;
import std.typecons;

auto input(int day) {
    return File("inputs/day%d.txt".format(day));
}

void main() {
    static foreach (day; 1..3) {
        static foreach (part; 1..3) {
            mixin(`import day%d;`
                    .format(day));
            mixin(`write("Day %d Part %d: ");`
                    .format(day, part));
            mixin(`writeln(day%d.part%d(input(%d).byLine(KeepTerminator.no,'%s')));`
                    .format(day,part,day,mixin(`day%d.separator`.format(day))));
        }
    }
}