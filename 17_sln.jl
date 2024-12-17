using DataStructures

mutable struct SystemState
    A::BigInt
    B::BigInt
    C::BigInt
    prog::Array{UInt8}
    PC::UInt64
    out::Array{UInt8}
end

function load_systemstate_and_program()
    lines = readlines("17_input.txt")
    progstr = lines[5][10:end]
    prog = Array{UInt8}(undef, 0)
    for tok in split(progstr, ',')
        push!(prog, parse(UInt8, tok))
    end

    state = SystemState(
        parse(BigInt, lines[1][12:end]),
        parse(BigInt, lines[2][12:end]),
        parse(BigInt, lines[3][12:end]),
        prog,
        0,
        UInt8[]
    )


    return state
end

# Does not advance PC
function readcombo!(state)
    combo = state.prog[state.PC+2]
    if combo <= 3
        return combo
    elseif combo == 4
        return state.A
    elseif combo == 5
        return state.B
    elseif combo == 6
        return state.C
    end
end

# Returns false once halted
function statestep!(state)
    if state.PC > length(state.prog) - 2
        return false
    end

    display(state)

    ins = state.prog[state.PC+1]
    step = true
    if ins == 0
        num = state.A
        den = 2^readcombo!(state)
        state.A = num ÷ den
    elseif ins == 1
        state.B = xor(state.B, state.prog[state.PC+2])
    elseif ins == 2
        state.B = mod(readcombo!(state), 8)
    elseif ins == 3
        if state.A != 0
            step = false
            state.PC = state.prog[state.PC+2]
        end
    elseif ins == 4
        state.B = xor(state.B, state.C)
    elseif ins == 5
        val = readcombo!(state)
        push!(state.out, mod(val, 8))
    elseif ins == 6
        num = state.A
        den = 2^readcombo!(state)
        state.B = num ÷ den
    elseif ins == 7
        num = state.A
        den = 2^readcombo!(state)
        state.C = num ÷ den
    end

    if step
        state.PC += 2
    end

    return true
end

function run!(state)
    while statestep!(state)

    end

    ostr = ""
    first = true
    for v in state.out
        if !first
            ostr = ostr * ","
        end
        ostr = ostr * string(v)
        first = false
    end
    display(string(ostr))
end