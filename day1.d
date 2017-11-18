import std.algorithm;
import std.conv;
import std.math;
import std.stdio;
import std.string;

struct Pos {
  long x;
  long y;
  ushort dir;
};

struct Command {
  char direction;
  uint distance;
};

auto turn(Pos pos, char dir) {
  switch (dir) {
    case 'R':
      pos.dir = (pos.dir + 1) % 4;
      break;
    case 'L':
      pos.dir = (pos.dir + 3) % 4;
      break;
    default:
      assert(false);
  }
  return pos;
};

unittest {
  Pos pos;
  pos.dir = 0;
  assert(1 == turn(pos, 'R').dir);
  assert(3 == turn(pos, 'L').dir);
  pos.dir = 1;
  assert(2 == turn(pos, 'R').dir);
  assert(0 == turn(pos, 'L').dir);
  pos.dir = 2;
  assert(3 == turn(pos, 'R').dir);
  assert(1 == turn(pos, 'L').dir);
  pos.dir = 3;
  assert(0 == turn(pos, 'R').dir);
  assert(2 == turn(pos, 'L').dir);
}

auto move(Pos pos, ulong distance) {
  switch (pos.dir) {
    case 0:
      pos.y = pos.y + distance;
      break;
    case 1:
      pos.x = pos.x + distance;
      break;
    case 2:
      pos.y = pos.y - distance;
      break;
    case 3:
      pos.x = pos.x - distance;
      break;
    default:
      assert(false);
  }
  return pos;
};

unittest {
  Pos pos = {3, 7, 0};
  pos.dir = 0;
  assert(Pos(3,9,0)==move(pos,2));
  pos.dir = 1;
  assert(Pos(5,7,1)==move(pos,2));
  pos.dir = 2;
  assert(Pos(3,5,2)==move(pos,2));
  pos.dir = 3;
  assert(Pos(1,7,3)==move(pos,2));
}

auto part1(IterT)(IterT commands) {
  auto result = commands
    .map!(str => Command( str[0], to!uint(str[1..$]))) 
    .fold!((pos, command) =>
          move(
            turn(pos, command.direction),
            command.distance)
        )(Pos());
  return abs(result.x) + abs(result.y);
}

unittest {
  assert(0 == part1(["R0"]));
}
