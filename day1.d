import std.algorithm;
import std.conv;
import std.math;
import std.stdio;
import std.string;

enum Cardinal: ubyte {
  North = 0,
  East,
  South,
  West
};

enum Turn: char {
  Right = 'R',
  Left = 'L'
};

struct Position {
  long x;
  long y;
  Cardinal cardinal;
};

struct Command {
  Turn turn;
  long distance;
};

auto turn(Position position, Turn turn) {
  final switch (turn) {
    case Turn.Right:
      position.cardinal = cast(Cardinal)((position.cardinal + 1) % 4);
      break;
    case Turn.Left:
      position.cardinal = cast(Cardinal)((position.cardinal + 3) % 4);
      break;
  }
  return position;
};

unittest {
  Position pos;
  pos.cardinal = Cardinal.North;
  assert(Cardinal.East == turn(pos, Turn.Right).cardinal);
  assert(Cardinal.West == turn(pos, Turn.Left).cardinal);
  pos.cardinal = Cardinal.East;
  assert(Cardinal.South == turn(pos, Turn.Right).cardinal);
  assert(Cardinal.North == turn(pos, Turn.Left).cardinal);
  pos.cardinal = Cardinal.South;
  assert(Cardinal.West == turn(pos, Turn.Right).cardinal);
  assert(Cardinal.East == turn(pos, Turn.Left).cardinal);
  pos.cardinal = Cardinal.West;
  assert(Cardinal.North == turn(pos, Turn.Right).cardinal);
  assert(Cardinal.South == turn(pos, Turn.Left).cardinal);
}

auto move(Position pos, long distance) {
  final switch (pos.cardinal) {
    case Cardinal.North:
      pos.y += distance;
      break;
    case Cardinal.East:
      pos.x += distance;
      break;
    case Cardinal.South:
      pos.y -= distance;
      break;
    case Cardinal.West:
      pos.x -= distance;
      break;
  }
  return pos;
};

unittest {
  Position pos = {3, 7, Cardinal.North};
  pos.cardinal = Cardinal.North;
  assert(Position(3,9,pos.cardinal)==move(pos,2));
  pos.cardinal = Cardinal.East;
  assert(Position(5,7,pos.cardinal)==move(pos,2));
  pos.cardinal = Cardinal.South;
  assert(Position(3,5,pos.cardinal)==move(pos,2));
  pos.cardinal = Cardinal.West;
  assert(Position(1,7,pos.cardinal)==move(pos,2));
}

auto part1(IterT)(IterT commands) {
  auto result = commands
    .map!(str => Command(cast(Turn)(str[0]), to!long(str[1..$]))) 
    .fold!((pos, command) =>
          move(
            turn(pos, command.turn),
            command.distance)
        )(Position());
  return abs(result.x) + abs(result.y);
}

unittest {
  assert(0 == part1(["R0"]));
}
