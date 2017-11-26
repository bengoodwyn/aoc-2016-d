import std.range;
import std.stdio;
import std.string;

private auto input_lines(int day, char separator)
in {
    assert(day > 0);
    assert(day <= 25);
}
out (result) {
    assert(&result !is null);
    assert(isForwardRange!string);
}
body {
    return File("inputs/day%d.txt".format(day))
            .byLine(KeepTerminator.no, separator);
}

void main() {
    static foreach (day; 1..26) {
        {
            mixin(`import day_module = day%d;`.format(day));
            static foreach (part; 1..3) {
                {
                    static if (is(typeof(mixin(`day_module.part%d`.format(part))))) {
                        immutable description = "Day %d Part %d: ".format(day, part);
                        static if (is(typeof(day_module.separator))) {
                            immutable separator = day_module.separator;
                        } else {
                            immutable separator = '\n';
                        }
                        auto lines = input_lines(day, separator);
                        auto result = mixin(`day_module.part%d`.format(part))(lines);
                        writeln(description, result);
                    }
                }
            }
        }
    }
}
