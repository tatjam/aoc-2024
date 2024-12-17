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

    display(state.B)

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

# We use a slightly confusing notation where the bit in 
# bits[i] is the ith bit. Thus, in the display, the bits
# are revered! (This is similar to Julia's digits)
struct KnownBits
    bits::BitArray{}
    known::BitArray{}
end

function emptyknownbits(n)
    return KnownBits(falses(n), falses(n))
end

function knownnumber(x, n)
    return KnownBits(digits(x, base=2, pad=n), trues(n))
end


function knowbit!(kb::KnownBits, i, v)
    kb.bits[i] = v
    kb.known[i] = true
end

# Shifting right moves bits to the LEFT in our representation
# (to lower rindices)
function shr(kb::KnownBits, n)::KnownBits
    if n > length(kb.bits)
        return knownnumber(0, length(kb.bits))
    end
    out = emptyknownbits(length(kb.bits))
    for i = 1:(length(kb.bits)-n)
        out.bits[i] = kb.bits[i+n]
        out.known[i] = kb.known[i+n]
    end
    for i = (length(kb.bits)-n+1):length(kb.bits)
        out.bits[i] = 0
        out.known[i] = 1
    end
    return out
end

# Most significant 1, returned as bit position (length - i)
# If no significant 1 is found, -1 is returned
function ms1(kb::KnownBits)::Int64
    for i in eachindex(kb.known)
        if kb.known[i] && kb.bits[i]
            return length(kb.known) - i + 1
        end
    end
    return -1
end

function isfullyknown(kb::KnownBits)
    for v in kb.known
        if v == false
            return false
        end
    end
    return true
end

function tonumber(kb::KnownBits)::Int64
    z = Int64(0)
    for i in eachindex(kb.bits)
        if kb.bits[i]
            z |= 1 << (i - 1)
        end
    end

    return z
end

function shr(kb::KnownBits, n::KnownBits)::KnownBits
    out = emptyknownbits(length(kb.bits))
    # If we know all bits, we can do the shift
    if isfullyknown(n)
        return shr(kb, tonumber(n))
    elseif ms1(n) >= length(kb.bits)
        # Every unknown is shifted out and we are left with all zeroes
        for i in length(kb.bits)
            out.bits[i] = 0
            out.known[i] = 1
        end
    end

    return out
end

function xor(lhs::KnownBits, rhs::KnownBits)::KnownBits
    @assert length(lhs.bits) == length(rhs.bits)
    out = emptyknownbits(length(lhs.bits))
    for i in 1:length(lhs.bits)
        if lhs.known[i] && rhs.known[i]
            out.known[i] = 1
            out.bits[i] = lhs.bits[i] ⊻ rhs.bits[i]
        else
            out.known[i] = 0
            out.bits[i] = 0
        end
    end
    return out
end


# The rules are:
# A[i+1] = A[i]>>3
# C[i+1] = A[i] >> B[i] xor 0b10
# B[i+1] = ((B[i] xor 2) xor C[i+1]) xor 3
# And the output value is B[i+1] & 0b111
# We set the lower 3 bits of each B[i+1]
# Furthermore, we have the condition that A must be minimum, thus at any point 
# that we may freely choose bits, we choose them to be 0
function findquine(prog)
    # Condition 2^45 < A < 2^46 implies bit 45 of A is set and any bit bigger than 46 is unset
    # A is simply right-shifted each iteration, so its value is "unique"
    a = emptyknownbits(45)
    knowbit!(a, 45, 1)

    # Each bit in B and C is eventually a (very complex) function of A
    bs = [emptyknownbits(45) for i = 1:length(prog)+1]
    cs = [emptyknownbits(45) for i = 1:length(prog)+1]
    for i in 1:45
        knowbit!(bs[1], i, 0)
        knowbit!(cs[1], i, 0)
    end

    for it in eachindex(prog)
        locala = shr(a, (it - 1) * 3)
        display(bs[it])
        cs[it+1] = shr(locala, xor(bs[it], knownnumber(2, 45)))

        bs[it+1] = xor(xor(xor(bs[it], knownnumber(2, 45)), cs[it+1]), knownnumber(3, 45))

    end
end