import std.algorithm;
import std.stdio;
import std.string;
import day1;
import day2;

void main() {
  writeln(
      day1.part1(
        File("inputs/day1.txt")
          .byLine(KeepTerminator.no, ',')
          .map!strip
          .filter!(x => x.length>0)
        )
      );
  writeln(
      day1.part2(
        File("inputs/day1.txt")
          .byLine(KeepTerminator.no, ',')
          .map!strip
          .filter!(x => x.length>0)
        )
      );
  writeln(
      day2.part1(
        File("inputs/day2.txt")
          .byLine(KeepTerminator.no)
          .map!strip
          .filter!(x => x.length>0)
        )
      );
}
