import std.algorithm;
import std.stdio;
import std.string;
import day1;

void main() {
  writeln(
      day1.part1(
        File("day1.txt")
          .byLine(KeepTerminator.no, ',')
          .map!strip
          .filter!(x => x.length>0)
        )
      );
}
