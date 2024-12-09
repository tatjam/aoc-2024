using DataStructures
using Combinatorics

@enum Operation begin
    plus = 1
    times = 2
    concat = 3
end
function getpairs()
    lines = readlines("07_input.txt")
    pairs = Array{Tuple{Int64,Stack{Int64}}}(undef, 0)
    for line ∈ lines
        toks = split(line, ':')
        arr = map(x -> parse(Int64, x), split(toks[2], ' ', keepempty=false))
        stack = Stack{Int64}()
        for elem ∈ reverse(arr)
            push!(stack, elem)
        end
        push!(pairs, (parse(Int64, toks[1]), stack))
    end
    return pairs
end

# Consumes both operations and numbers
function operate!(operations::Stack{Operation}, numbers::Stack{Int64})
    num = convert(BigInt, pop!(numbers))
    while !isempty(operations)
        op = pop!(operations)
        if op == plus
            num += pop!(numbers)
        elseif op == times
            num *= pop!(numbers)
        elseif op == concat
            rhs = pop!(numbers)
            num = num * 10^(ndigits(rhs)) + rhs
        end
    end
    return num
end

function bruteforce(pair)
    # We must generate as many operations as (numbers - 1)
    ops = [plus, times, concat]
    combs = multiset_permutations.(with_replacement_combinations(ops, length(pair[2]) - 1), length(pair[2]) - 1)
    for comb ∈ combs
        for scomb ∈ comb
            opstack = Stack{Operation}()
            for op ∈ scomb
                push!(opstack, op)
            end
            result = operate!(opstack, deepcopy(pair[2]))
            if result == pair[1]
                return convert(BigInt, result)
            end
        end
    end
    return convert(BigInt, 0)
end
