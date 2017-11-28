import std.algorithm;
import std.ascii;
import std.conv;
import std.exception;
import std.range;
import std.string;

alias Registers = int[4];
alias Instruction = int delegate(ref Registers);
alias Instructions = Instruction[];

int resolve_register(const char[] name) {
    enforce(name.length == 1, "Register names are a single character");
    immutable character = name[0];
    enforce(character.isAlpha, "Registers must be a letter");
    immutable register_index = to!int(character-'a');
    enforce(register_index >= 0 && register_index < Registers.length, "Register '%c' does not exist".format(character));
    return register_index;
}

Instruction compile_inc(const string[] args) {
    enforce(args.length == 1, "inc requires a single argument");

    immutable register_index = resolve_register(args[0]);
    return delegate(ref Registers registers) {
        ++registers[register_index];
        return 1;
    };
}

Instruction compile_jnz(const string[] args) {
    enforce(args.length == 2, "jnz requires two arguments");

    immutable distance = to!int(args[1]);
    immutable source = args[0];
    if (source.length == 1 && source[0].isAlpha) {
        immutable register_index = resolve_register(args[0]);
        enforce(register_index < Registers.length, "Invalid register '%c'".format(args[0][0]));
        return delegate(ref Registers registers) {
            return (0 == registers[register_index]) ? 1 : distance;
        };
    } else {
        immutable immediate_value = to!int(args[0]);
        if (0 == immediate_value) {
            return delegate(ref Registers) {
                return 1;
            };
        } else {
            return delegate(ref Registers) {
                return distance;
            };
        }
    }
}

Instruction compile_dec(const string[] args) {
    enforce(args.length == 1, "dec requires a single argument");

    immutable register_index = resolve_register(args[0]);
    return delegate(ref Registers registers) {
        --registers[register_index];
        return 1;
    };
}

Instruction compile_cpy(const string[] args) {
    enforce(args.length == 2, "cpy requires two arguments");

    immutable source = args[0];
    immutable dest_register_index = resolve_register(args[1]);
    if (source.length == 1 && source[0].isAlpha) {
        immutable source_register_index = resolve_register(args[0]);
        return delegate(ref Registers registers) {
            registers[dest_register_index] = registers[source_register_index];
            return 1;
        };
    }
    else {
        immutable immediate_value = to!int(args[0]);
        return delegate(ref Registers registers) {
            registers[dest_register_index] = immediate_value;
            return 1;
        };
    }
}

template DispatchOpcode(string token) {
    const char[] DispatchOpcode =
        `if (opcode == "%s") { return compile_%s(tokens[1..$]); }`
            .format(token, token);
}

Instruction compile_instruction(const string[] tokens) {
    enforce(tokens.length > 0, "Missing opcode");

    immutable opcode = tokens[0];

    mixin(DispatchOpcode!("inc"));
    mixin(DispatchOpcode!("dec"));
    mixin(DispatchOpcode!("cpy"));
    mixin(DispatchOpcode!("jnz"));

    throw new Exception("Unknown opcode '%s'".format(opcode));
}

Instructions compile_instructions(T)(T commands)
{
    Instructions seed;
    return
        commands
        .map!split
        .map!compile_instruction
        .fold!((instructions, instruction) => instructions ~ instruction)(seed);
}

private Registers execute(const Instructions code) {
    Registers registers;
    int len = to!int(code.length);
    int ip = 0;
    while (ip >= 0 && ip < len) {
        ip += code[ip](registers);
    }
    return registers;
}

int part1(T)(T code) {
    return code.compile_instructions.execute[resolve_register("a")];
}

int part2(T)(T code) {
    auto modified_code = ["cpy 1 c"].chain(code);
    return part1(modified_code);
}

unittest {
    immutable sample_code =
    [
        "cpy 41 a",
        "inc a",
        "inc a",
        "dec a",
        "jnz a 2",
        "dec a"
    ];

    assert(42 == part1(sample_code));
}
