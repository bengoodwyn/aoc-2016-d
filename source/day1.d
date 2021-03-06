import std.algorithm;
import std.conv;
import std.math;
import std.range;
import std.stdio;
import std.string;
import std.typecons;

immutable separator = ',';

enum Cardinal: ubyte {
  North = 0,
  East,
  South,
  West
};

enum Turn: char {
  Right = 'R',
  Left = 'L',
  None = 'N'
};

struct Position {
  long x;
  long y;
  Cardinal cardinal;
};

auto coords(Position position) {
  return tuple(position.x, position.y);
}

auto distance(Position position) {
  return abs(position.x) + abs(position.y);
}

struct Command {
  Turn turn;
  long distance;
};

auto turn(const Position position, const Turn turn) {
  final switch (turn) with (Turn) {
    case Right:
      return Position(
              position.x,
              position.y,
              to!Cardinal((position.cardinal + 1) % 4));
    case Left:
      return Position(
              position.x,
              position.y,
              to!Cardinal((position.cardinal + 3) % 4));
    case None:
      return position;
  }
};

unittest {
  struct TestCase {
    Cardinal start;
    Turn turn;
    Cardinal end;
  }

  immutable TestCase[] test_cases = [
    { Cardinal.North, Turn.Right, Cardinal.East  },
    { Cardinal.North, Turn.Left,  Cardinal.West  },
    { Cardinal.East,  Turn.Right, Cardinal.South },
    { Cardinal.East,  Turn.Left,  Cardinal.North },
    { Cardinal.South, Turn.Right, Cardinal.West  },
    { Cardinal.South, Turn.Left,  Cardinal.East  },
    { Cardinal.West,  Turn.Right, Cardinal.North },
    { Cardinal.West,  Turn.Left,  Cardinal.South },
    { Cardinal.North, Turn.None,  Cardinal.North },
    { Cardinal.East,  Turn.None,  Cardinal.East  },
    { Cardinal.South, Turn.None,  Cardinal.South },
    { Cardinal.West,  Turn.None,  Cardinal.West  },
  ];

  foreach (test_case; test_cases) {
    immutable start = Position(0, 0, test_case.start);

    immutable end = turn(start, test_case.turn);

    assert(end == Position(0, 0, test_case.end));
  }
}

auto move(const Position pos, const long distance) {
  final switch (pos.cardinal) with (Cardinal) {
    case North:
      return Position(pos.x, pos.y + distance, pos.cardinal);
    case East:
      return Position(pos.x + distance, pos.y, pos.cardinal);
    case South:
      return Position(pos.x, pos.y - distance, pos.cardinal);
    case West:
      return Position(pos.x - distance, pos.y, pos.cardinal);
  }
};

unittest {
  struct TestCase {
    Position start;
    long distance;
    Position end;
  }

  immutable TestCase[] test_cases = [
    { {3,7,Cardinal.North}, 2, { 3,9,Cardinal.North} },
    { {3,7,Cardinal.East }, 3, { 6,7,Cardinal.East } },
    { {3,7,Cardinal.South}, 4, { 3,3,Cardinal.South} },
    { {3,7,Cardinal.West }, 5, {-2,7,Cardinal.West } }
  ];

  foreach (test_case; test_cases) {
    immutable end = move(test_case.start, test_case.distance);

    assert(end == test_case.end);
  }
}

auto part1(IterT)(IterT commands) {
  immutable final_position =
    commands
    .map!strip
    .map!(str => Command(to!Turn(str[0]), to!long(str[1..$])))
    .fold!((position, command) =>
          move(
            turn(position, command.turn),
            command.distance)
        )(Position());
  return final_position.distance;
}

unittest {
  struct TestCase {
    long distance;
    string[] commands;
  }

  immutable TestCase[] test_cases = [
   { 0,  []},
   { 5,  ["R2","L3"]},
   { 2,  ["R2","R2","R2"]},
   { 12, ["R5","L5","R5","R3"]},
   { 0,  ["R0"]},
   { 1,  ["R1"]},
   { 10, ["R10"]},
   { 10, ["R5","L5"]},
   { 0,  ["R3","L3","L3","L3"]}
  ];

  foreach (test_case; test_cases) {
    immutable distance = part1(test_case.commands);

    assert(distance == test_case.distance);
  }
}

struct FoldState {
  Position position;
  bool[Tuple!(long,long)] visited;
}

FoldState update_state(FoldState state, Command command) {
  state.visited[state.position.coords] = true;
  state.position = move(
    turn(state.position, command.turn),
    command.distance);
  return state;
}

auto part2(IterT)(IterT commands) {
  auto range =
    commands
    .map!strip
    .map!(str => Command(to!Turn(str[0]), to!long(str[1..$])))
    .map!(command =>
            chain(
              Command(command.turn, 1).repeat().take(1),
              Command(Turn.None, 1).repeat().take(command.distance-1)))
    .joiner
    .cumulativeFold!update_state(FoldState())
    .filter!(state => state.position.coords in state.visited)
    .map!(state => state.position);
  if (range.empty) {
    return 0;
  } else {
    return range.front.distance;
  }
}

unittest {
  struct TestCase {
    long distance;
    string[] commands;
  }

  immutable TestCase[] test_cases = [
    { 0, [] },
    { 0, ["R3", "L3", "L3", "L3", "R3"]},
    { 5, ["L5", "R3", "L3", "L3", "L300", "R3"]}
  ];

  foreach (test_case; test_cases) {
    immutable distance = part2(test_case.commands);

    assert(distance == test_case.distance);
  }
}
