import std.algorithm;
import std.ascii;
import std.conv;
import std.exception;
import std.range;
import std.stdio;
import std.string;
import std.typecons;

alias Registers = int[5];
alias Token = string;
alias Instruction = Token[];
alias Instructions = Instruction[];
alias Jit = int delegate(ref Registers, ref Instructions);

int resolve_register(char name) {
    enforce(name.isAlpha, "Registers must be a letter");
    immutable register_index = to!int(name-'a');
    enforce(register_index >= 0 && register_index < Registers.length, "Register '%c' does not exist".format(name));
    return register_index+1;
}

unittest {
    assert(1 == resolve_register('a'), "can reference register a");
    assert(2 == resolve_register('b'), "can reference register b");
    assert(3 == resolve_register('c'), "can reference register c");
    assert(4 == resolve_register('d'), "can reference register d");
}

Jit jit_inc(Instruction instruction) {
    enforce(instruction.length == 2, "inc requires a single argument");

    immutable register_index = resolve_register(instruction[1][0]);
    return delegate(ref Registers registers, ref Instructions) {
                ++registers[register_index];
                ++registers[0];
                return -1;
            };
}

unittest {
    Registers registers = [1,2,3,4,5];
    Instructions instructions;

    jit_inc(["inc","a"])(registers, instructions);

    assert(registers == [2,3,3,4,5], "can add one to register");
}

Jit jit_dec(Instruction instruction) {
    enforce(instruction.length == 2, "dec requires a single argument");

    immutable register_index = resolve_register(instruction[1][0]);
    return delegate(ref Registers registers, ref Instructions) {
                --registers[register_index];
                ++registers[0];
                return -1;
            };
}

unittest {
    Registers registers = [1,2,3,4,5];
    Instructions instructions;

    jit_dec(["dec","a"])(registers, instructions);

    assert(registers == [2,1,3,4,5], "can subtract one from register");
}

Jit jit_jnz(Instruction instruction) {
    enforce(instruction.length == 3, "jnz requires two arguments");

    auto distance = instruction[2];
    int delegate(Registers) distance_delegate;
    if (distance.length == 1 && distance[0].isAlpha) {
        immutable register_index = resolve_register(distance[0]);
        distance_delegate = delegate(Registers registers) {
            return registers[register_index];
        };
    } else {
        immutable immediate_value = to!int(distance);
        distance_delegate = delegate(Registers) {
            return immediate_value;
        };
    }

    auto source = instruction[1];
    if (source.length == 1 && source[0].isAlpha) {
        immutable register_index = resolve_register(source[0]);
        return delegate(ref Registers registers, ref Instructions) {
                    if (0 == registers[register_index]) {
                        ++registers[0];
                    } else {
                        registers[0] += distance_delegate(registers);
                    }
                    return -1;
                };
    } else {
        immutable immediate_value = to!int(source);
        if (0 == immediate_value) {
            return delegate(ref Registers registers, ref Instructions) {
                        ++registers[0];
                        return -1;
                    };
        } else {
            return delegate(ref Registers registers, ref Instructions) {
                        registers[0] += distance_delegate(registers);
                        return -1;
                    };
        }
    }
}

unittest {
    immutable Registers start = [1,2,3,4,0];
    Registers registers;
    Instructions instructions;

    registers = start;
    jit_jnz(["jnz","0","100"])(registers, instructions);
    assert([2,2,3,4,0] == registers, "can avoid jump for zero");

    registers = start;
    jit_jnz(["jnz","1","100"])(registers, instructions);
    assert([101,2,3,4,0] == registers, "can jmp for non-zero");
    
    registers = start;
    jit_jnz(["jnz","d","100"])(registers, instructions);
    assert([2,2,3,4,0] == registers, "can avoid jmp for zero register");
    
    registers = start;
    jit_jnz(["jnz","c","100"])(registers, instructions);
    assert([101,2,3,4,0] == registers, "can jmp for non-zero register");
    
    registers = start;
    jit_jnz(["jnz","a","b"])(registers, instructions);
    assert([4,2,3,4,0] == registers, "can supply register for jmp offset");
}

Jit jit_cpy(Instruction instruction) {
    enforce(instruction.length == 3, "cpy requires two arguments");

    auto dest = instruction[2];
    if (dest.length != 1 || !dest[0].isAlpha) {
        return delegate(ref Registers registers, ref Instructions) {
                    ++registers[0];
                    return -1;
                };
    }

    immutable dest_register_index = resolve_register(instruction[2][0]);
    auto source = instruction[1];
    if (source.length == 1 && source[0].isAlpha) {
        immutable source_register_index = resolve_register(source[0]);
        return delegate(ref Registers registers, ref Instructions) {
                    registers[dest_register_index] = registers[source_register_index];
                    ++registers[0];
                    return -1;
                };
    }
    else {
        immutable immediate_value = to!int(instruction[1]);
        return delegate(ref Registers registers, ref Instructions) {
                    registers[dest_register_index] = immediate_value;
                    ++registers[0];
                    return -1;
                };
    }
}

unittest {
    immutable Registers start = [1,2,3,4,5];
    Registers registers;
    Instructions instructions;

    registers = start;
    jit_cpy(["cpy","a","d"])(registers, instructions);
    assert([2,2,3,4,2] == registers, "can cpy register to register");

    registers = start;
    jit_cpy(["cpy","55","d"])(registers, instructions);
    assert([2,2,3,4,55] == registers, "can cpy immediate value to register");

    registers = start;
    jit_cpy(["cpy","1","2"])(registers, instructions);
    assert([2,2,3,4,5] == registers, "If toggling produces an invalid instruction (like cpy 1 2) and an attempt is later made to execute that instruction, skip it instead");
}

int tgl(int ip, ref Instructions instructions) {
    if (ip < 0) { return -1; }
    if (ip >= instructions.length) { return -1; }

    Instruction original = instructions[ip];
    if (original.length == 2) {
        if ("inc" == original[0]) {
            original[0] = "dec";
        } else {
            original[0] = "inc";
        }
    } else if (original.length == 3) {
        if ("jnz" == original[0]) {
            original[0] = "cpy";
        } else {
            original[0] = "jnz";
        }
    }

    return ip;
}

unittest {
    Instructions instructions;

    instructions = [[],[]];
    assert(-1 == tgl(-1, instructions), "If an attempt is made to toggle an instruction outside the program, nothing happens");
    assert(-1 == tgl(2, instructions), "If an attempt is made to toggle an instruction outside the program, nothing happens");
    instructions = [
        ["inc","a"],
        ["dec","a"],
        ["tgl","a"],
        ["jnz","a","b"],
        ["cpy","a","b"]
    ];
    assert("dec" == instructions[tgl(0, instructions)][0], "inc becomes dec");
    assert("inc" == instructions[tgl(1, instructions)][0], "all other one-argument instructions become inc");
    assert("inc" == instructions[tgl(2, instructions)][0], "all other one-argument instructions become inc");
    assert("cpy" == instructions[tgl(3, instructions)][0], "jnz becomes cpy");
    assert("jnz" == instructions[tgl(4, instructions)][0], "all other two-instructions become jnz");
    instructions
        .map!(x => x[1])
        .each!(x => assert(x == "a", "The arguments of a toggled instruction are not affected"));
    instructions
        .filter!(x => x.length > 2)
        .map!(x => x[2])
        .each!(x => assert(x == "b", "The arguments of a toggled instruction are not affected"));
}

Jit jit_tgl(Instruction instruction) {
    enforce(instruction.length == 2, "tgl requires one argument");
    auto offset = instruction[1];
    if (offset.length == 1 && offset[0].isAlpha) {
        immutable register_index = resolve_register(offset[0]);
        return delegate(ref Registers registers, ref Instructions instructions) {
                    auto ip = registers[0];
                    ++registers[0];
                    return tgl(ip+registers[register_index], instructions);
                };
    }
    else {
        immutable immediate_value = to!int(offset);
        return delegate(ref Registers registers, ref Instructions instructions) {
                    auto ip = registers[0];
                    ++registers[0];
                    return tgl(ip+immediate_value, instructions);
                };
    }
}

template DispatchOpcode(string token) {
    const char[] DispatchOpcode =
        `if (opcode == "%s") { return jit_%s(instruction); }`
            .format(token, token);
}

Jit jit_instruction(Instruction instruction) {
    enforce(instruction.length > 0, "Missing opcode");

    auto opcode = instruction[0];

    mixin(DispatchOpcode!("inc"));
    mixin(DispatchOpcode!("dec"));
    mixin(DispatchOpcode!("cpy"));
    mixin(DispatchOpcode!("jnz"));
    mixin(DispatchOpcode!("tgl"));

    throw new Exception("Unknown opcode '%s'".format(opcode));
}

Instructions collect_instructions(T)(T commands)
{
    Instructions seed;
    string[] tokens;
    return commands
        .fold!((instructions, line) =>
            instructions ~
                (line
                .split
                .fold!((a,b)=>a~b.dup)(tokens))
            )(seed);
}

unittest {
    immutable string[] commands = ["a b c","a b","a b cd e"];

    assert([["a","b","c"],["a","b"],["a","b","cd","e"]] == collect_instructions(commands), "can parse tokens");
}

Jit[] jit_compile(Instructions code) {
    Jit[] seed;
    return code
            .map!((instruction) => jit_instruction(instruction))
            .fold!((jits, jit) => (jits ~ jit))(seed);
}

Registers execute(Instructions code) {
    Registers registers;
    auto jits = jit_compile(code);
    auto ip = registers[0];
    while (ip >= 0 && ip < jits.length) {
        debug(assembunny) writeln("Executing: ip=%d %s".format(ip, code[ip]));
        immutable modified_ip = jits[ip](registers, code);
        if (modified_ip >= 0) {
            jits[modified_ip] = jit_instruction(code[modified_ip]);
            debug(assembunny) writeln("Recompiled: ip=%d %s".format(modified_ip, code[modified_ip]));
        }
        ip = registers[0];
    }
    return registers;
}

unittest {
    Instructions code = [["inc","a"],["dec","b"],["cpy","7","d"]];

    immutable result = execute(code);

    assert([3,1,-1,0,7] == result,"can execute some instructions");
}
