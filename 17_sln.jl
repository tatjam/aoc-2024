using DataStructures
using LinearAlgebra
using JuMP
using Juniper
using Ipopt


mutable struct SystemState
    A::Int64
    B::Int64
    C::Int64
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

    ins = state.prog[state.PC+1]
    step = true
    if ins == 0
        num = state.A
        den = 2^readcombo!(state)
        state.A = num ÷ den
    elseif ins == 1
        state.B = Base.xor(state.B, state.prog[state.PC+2])
    elseif ins == 2
        state.B = mod(readcombo!(state), 8)
    elseif ins == 3
        if state.A != 0
            step = false
            state.PC = state.prog[state.PC+2]
        end
    elseif ins == 4
        state.B = Base.xor(state.B, state.C)
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

function basestate()
    st = load_systemstate_and_program()
    st.A = 0
    return st
end

function reset!(st)
    st.A = 0
    st.B = 0
    st.C = 0
    st.PC = 0
    empty!(st.out)
end


# Tests every bit in A of the input to state and builds how it,
# INDEPENDENTLY affects the output.
function influencemap(st, n)
    out = Matrix{Int32}(undef, (n, length(st.prog)))
    # None except max set run 
    reset!(st)
    st.A = 1 << n
    run!(st)
    default = convert.(Int32, st.out)
    for i in 0:(n-1)
        reset!(st)
        st.A = (1 << i | 1 << n)
        run!(st)
        out[i+1, :] .= convert.(Int32, st.out) .- default
    end
    return out
end

# First approximation, estimates a large quantity of bits.
# Last quantity is found by bruteforce
function buildquine(st)
    # Note that all starting output numbers, except for the very last two,
    # depend only on 5 bits of the starting value, such that each bit of output 
    # only overlaps with two bits of the other (except the last few bits which 
    # are found by bruteforce)
    # Thus to build a solution we simply bruteforce the bits in blocks of 8, checking
    # two output numbers, and that we don't mess up the solution to our left!
    # We leave the last three numbers to be found by bruteforce

    bits = zeros(Int32, 46)
    bits[46] = 1
    bits[1] = 0
    for out in 1:15
        @bp
        # We change every bit, checking both our output and left neighbor until we 
        # get the result right
        good = false
        for comb in 0:(2^12-1)
            wpos = (out - 1) * 3 + 1
            digs = digits(comb, base=2, pad=12)
            for bit in 1:12
                if bit + wpos - 1 < 46
                    bits[bit+wpos-1] = digs[bit]
                end
            end
            testbits(st, bits)
            if st.out[out] == st.prog[out] && st.out[out+1] == st.prog[out+1]
                good = true
            end
            if out != 1
                if st.out[out-1] != st.prog[out-1]
                    good = false
                end
            end
            if good
                break
            end
        end
        display(out)
        if !good
            display("NOT GOOD!")
            return bits
        end
    end
end

function finish_bruteforce(st, bits)
    # Last 7 digits need to be bruteforced. This means changing 
    # 21 bits, which can be done in reasonable time 
    for comb in 0:(2^21-1)
        digs = digits(comb, base=2, pad=21)
        for bit in 1:21
            bits[46-bit] = digs[bit]
        end
        testbits(st, bits)
        if st.out == st.prog
            return bits
        end
    end
end

function testbits(st, Abits)
    reset!(st)
    st.A = 0
    for i in eachindex(Abits)
        if Abits[i] > 0.5
            st.A = st.A | (1 << (i - 1))
        end
    end
    run!(st)
end

function test(st, A)
    reset!(st)
    st.A = A
    run!(st)
end

function solve()
    @info "Loading solution"
    st = load_systemstate_and_program()
    initial = buildquine(st)
    final = finish_bruteforce(st, initial)
    out = Int64(0)
    for i in eachindex(final)
        if final[i] > 0.5
            out = out | (1 << (i - 1))
        end
    end
    return out
end