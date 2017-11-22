import std.typecons;
import std.algorithm;
import std.array;

alias Position = Tuple!(int,int);

immutable char[3][3] basic_keypad = [['1','2','3'],['4','5','6'],['7','8','9']];
immutable auto basic_keypad_start = Position(1,1);

immutable char[5][5] crazy_keypad = [
    [' ',' ','1',' ',' '],
    [' ','2','3','4',' '],
    ['5','6','7','8','9'],
    [' ','A','B','C',' '],
    [' ',' ','D',' ',' ']
];
immutable auto crazy_keypad_start = Position(0,2);

char at_position(T)(T keypad, int x, int y) {
    return keypad[y][x];
}

Position move_ignoring_keys(T, CharT)(T keypad, Position begin, CharT direction) {
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

Position move(T, CharT)(T keypad, Position begin, CharT direction) {
    Position end = move_ignoring_keys(keypad, begin, direction);
    if (' ' == at_position(keypad, end[0], end[1])) {
        return begin;
    }
    return end;
}

unittest {
  assert(Position(1,0)==move(basic_keypad,Position(1,0),'U'), "Can't move above top");
  assert(Position(0,1)==move(basic_keypad,Position(0,1),'L'), "Can't move beyond left edge");
  assert(Position(1,2)==move(basic_keypad,Position(1,2),'D'), "Can't move below bottom");
  assert(Position(2,1)==move(basic_keypad,Position(2,1),'R'), "Can't move beyond right edge");

  assert(Position(1,0)==move(basic_keypad,basic_keypad_start,'U'), "Can move up");
  assert(Position(0,1)==move(basic_keypad,basic_keypad_start,'L'), "Can move left");
  assert(Position(1,2)==move(basic_keypad,basic_keypad_start,'D'), "Can move down");
  assert(Position(2,1)==move(basic_keypad,basic_keypad_start,'R'), "Can move right");
}

unittest {
  assert(Position(1,1)==move(crazy_keypad,Position(1,1),'U'), "Won't move into a space");
}

Position moves(T)(T keypad, Position start, const char[] directions) {
  return directions
            .fold!((position,direction) => move(keypad,position,direction))(start);
}

unittest {
    assert(Position(0,0)==moves(basic_keypad,basic_keypad_start,"UL"), "Can move up and left");
    assert(Position(2,1)==moves(basic_keypad,basic_keypad_start,"ULDRR"), "Can move up left down right right");
}

string part1(T)(T lines) {
    return lines
        .cumulativeFold!((position,line) => moves(basic_keypad,position,line))(basic_keypad_start)
        .map!(position => at_position(basic_keypad, position[0],position[1]))
        .fold!((results,press) => results ~ press)("");
}

unittest {
    assert("1985"==part1(["ULL","RRDDD","LURDL","UUUUD"]), "Can run example");
}

string part2(T)(T lines) {
    return lines
        .cumulativeFold!((position,line) => moves(crazy_keypad,position,line))(crazy_keypad_start)
        .map!(position => at_position(crazy_keypad, position[0],position[1]))
        .fold!((results,press) => results ~ press)("");
}

unittest {
    assert("5DB3"==part2(["ULL","RRDDD","LURDL","UUUUD"]), "Can run example");
}