import std.algorithm;
import std.ascii;
import std.conv;
import std.exception;
import std.range;
import std.string;

alias Registers = int[5];
alias Token = string;
alias Instruction = Token[];
alias Instructions = Instruction[];

int resolve_register(const char[] name) {
    enforce(name.length == 1, "Register names are a single character");
    immutable character = name[0];
    enforce(character.isAlpha, "Registers must be a letter");
    immutable register_index = to!int(character-'a');
    enforce(register_index >= 0 && register_index < Registers.length, "Register '%c' does not exist".format(character));
    return register_index+1;
}

unittest {
    assert(1 == resolve_register("a"), "can reference register a");
    assert(2 == resolve_register("b"), "can reference register b");
    assert(3 == resolve_register("c"), "can reference register c");
    assert(4 == resolve_register("d"), "can reference register d");
}

Registers execute_inc(const char[][] args, Registers start) {
    enforce(args.length == 1, "inc requires a single argument");

    Registers registers = start;
    immutable register_index = resolve_register(args[0]);
    ++registers[register_index];
    ++registers[0];
    return registers;
}

unittest {
    immutable Registers start = [1,2,3,4,5];
    Registers end = execute_inc(["a"],start);

    assert(end == [2,3,3,4,5], "can add one to register");
}

Registers execute_dec(const char[][] args, Registers start) {
    enforce(args.length == 1, "dec requires a single argument");

    Registers registers = start;
    immutable register_index = resolve_register(args[0]);
    --registers[register_index];
    ++registers[0];
    return registers;
}

unittest {
    immutable Registers start = [1,2,3,4,5];
    Registers end = execute_dec(["a"],start);

    assert(end == [2,1,3,4,5], "can subtract one from register");
}

Registers execute_jnz(const char[][] args, Registers start) {
    enforce(args.length == 2, "jnz requires two arguments");

    Registers registers = start;
    immutable distance = to!int(args[1]);
    auto source = args[0];
    if (source.length == 1 && source[0].isAlpha) {
        immutable register_index = resolve_register(args[0]);
        enforce(register_index < Registers.length, "Invalid register '%c'".format(args[0][0]));
        if (0 == registers[register_index]) {
            ++registers[0];
        } else {
            registers[0] += distance;
        }
    } else {
        immutable immediate_value = to!int(args[0]);
        if (0 == immediate_value) {
            ++registers[0];
        } else {
            registers[0] += distance;
        }
    }
    return registers;
}

unittest {
    immutable Registers start = [1,2,3,4,0];

    assert([2,2,3,4,0] == execute_jnz(["0","100"], start), "can avoid jump for zero");
    assert([101,2,3,4,0] == execute_jnz(["1","100"], start), "can jmp for non-zero");
    assert([2,2,3,4,0] == execute_jnz(["d","100"], start), "can avoid jmp for zero register");
    assert([101,2,3,4,0] == execute_jnz(["c","100"], start), "can jmp for non-zero register");
}

Registers execute_cpy(const char[][] args, Registers start) {
    enforce(args.length == 2, "cpy requires two arguments");

    Registers registers = start;
    auto source = args[0];
    immutable dest_register_index = resolve_register(args[1]);
    if (source.length == 1 && source[0].isAlpha) {
        immutable source_register_index = resolve_register(args[0]);
        registers[dest_register_index] = registers[source_register_index];
    }
    else {
        immutable immediate_value = to!int(args[0]);
        registers[dest_register_index] = immediate_value;
    }
    ++registers[0];
    return registers;
}

unittest {
    immutable Registers start = [1,2,3,4,5];

    assert([2,2,3,4,2] == execute_cpy(["a","d"], start), "can cpy register to register");
    assert([2,2,3,4,55] == execute_cpy(["55","d"], start), "can cpy immediate value to register");
}

template DispatchOpcode(string token) {
    const char[] DispatchOpcode =
        `if (opcode == "%s") { return execute_%s(instruction[1..$], registers); }`
            .format(token, token);
}

Registers execute_instruction(Instruction instruction, Registers registers) {
    enforce(instruction.length > 0, "Missing opcode");

    auto opcode = instruction[0];

    mixin(DispatchOpcode!("inc"));
    mixin(DispatchOpcode!("dec"));
    mixin(DispatchOpcode!("cpy"));
    mixin(DispatchOpcode!("jnz"));

    throw new Exception("Unknown opcode '%s'".format(opcode));
}

unittest {
    immutable Registers start = [1,2,3,4,5];

    assert([2,3,3,4,5] == execute_instruction(["inc","a"], start), "can execute inc");
    assert([2,2,2,4,5] == execute_instruction(["dec","b"], start), "can execute dec");
    assert([2,5,3,4,5] == execute_instruction(["cpy","d","a"], start), "can execute cpy");
    assert([5,2,3,4,5] == execute_instruction(["jnz","c","4"], start), "can execute jnz");
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

Registers execute(Instructions code) {
    Registers registers;
    int len = to!int(code.length);
    while (registers[0] >= 0 && registers[0] < len) {
        registers = code[registers[0]].execute_instruction(registers);
    }
    return registers;
}
