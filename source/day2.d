import std.typecons;
import std.algorithm;
import std.array;

alias Position = Tuple!(int,int);

immutable char[3][3] keypad = [['1','2','3'],['4','5','6'],['7','8','9']];
immutable auto start = Position(1,1);

char at_position(int x, int y) {
    return keypad[y][x];
}

Position move(CharT)(Position begin, CharT direction) {
  final switch (direction) {
    case 'U':
      return Position(begin[0],max(0,begin[1]-1));
    case 'D':
      return Position(begin[0],min(keypad.length-1,begin[1]+1));
    case 'L':
      return Position(max(0,begin[0]-1),begin[1]);
    case 'R':
      return Position(min(keypad[0].length-1,begin[0]+1),begin[1]);
  }
}

unittest {
  assert(Position(1,0)==Position(1,0).move('U'), "Can't move above top");
  assert(Position(0,1)==Position(0,1).move('L'), "Can't move beyond left edge");
  assert(Position(1,2)==Position(1,2).move('D'), "Can't move below bottom");
  assert(Position(2,1)==Position(2,1).move('R'), "Can't move beyond right edge");

  assert(Position(1,0)==Position(1,1).move('U'), "Can move up");
  assert(Position(0,1)==Position(1,1).move('L'), "Can move left");
  assert(Position(1,2)==Position(1,1).move('D'), "Can move down");
  assert(Position(2,1)==Position(1,1).move('R'), "Can move right");
}

Position move(Position start, const char[] directions) {
  return directions
            .fold!((position,direction) => position.move(direction))(start);
}

unittest {
    assert(Position(0,0)==start.move("UL"), "Can move up and left");
    assert(Position(2,1)==start.move("ULDRR"), "Can move up left down right right");
}

string part1(T)(T lines) {
    return lines
        .cumulativeFold!((position,line) => position.move(line))(start)
        .map!(position => at_position(position[0],position[1]))
        .fold!((results,press) => results ~ press)("");
}

unittest {
    assert("1985"==part1(["ULL","RRDDD","LURDL","UUUUD"]), "Can run example");
}