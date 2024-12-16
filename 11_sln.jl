using DataStructures

# Use this to display UInt as decimals
# Base.show(io::IO, x::T) where {T<:Union{UInt, UInt128, UInt64, UInt32, UInt16, UInt8}} = Base.print(io, x)

function getstones()
    line = readlines("11_input.txt")[1]
    stones_str = split(line, ' ')
    stones = Array{UInt64}(undef, 0)
    for stone_str in stones_str
        push!(stones, parse(UInt64, stone_str))
    end
    return stones
end

# Returns either [stone] or [stone, stone]
function applyrule(stone)
    out = Array{UInt64}(undef, 0)
    if stone == 0
        resize!(out, 1)
        out[1] = 1
    else
        stonedigits = ndigits(stone)
        if iseven(stonedigits)
            resize!(out, 2)
            # Left ndigits / 2 is simply stone ÷ 10^(ndigits/2)
            out[1] = stone ÷ 10^(stonedigits ÷ 2)
            # Right ndigits is stone - the previous number * 10^(ndigits / 2)
            out[2] = stone - out[1] * 10^(stonedigits ÷ 2)
        else
            resize!(out, 1)
            out[1] = 2024 * stone
        end
    end

    return out
end

# Because the order, and count of stones doesn't matter, we can use a set and only
# solve each stone once
function smartsolve(stones, n)
    # First is stone value, second is number of stones
    stoneset = Accumulator{UInt64,Int64}()
    for stone in stones
        inc!(stoneset, stone)
    end

    for it in 1:n
        nstoneset = Accumulator{UInt64,Int64}()
        for stone in stoneset
            if stone.second == 0
                reset!(stoneset, stone.first)
            else
                result = applyrule(stone.first)
                for nstone in result
                    inc!(nstoneset, nstone, stone.second)
                end
            end
        end
        stoneset = nstoneset
    end

    for stone in stoneset
        if stone.second == 0
            reset!(stoneset, stone.first)
        end
    end

    # At the end we simply count
    total = 0
    for stone in stoneset
        total += stone.second
    end
    return total
end
