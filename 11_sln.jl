using Graphs
using NamedGraphs

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

# We only need to decompose each stone once, so we can build a graph 
# with each stone and its decomposition diagram.
# To build this graph, we run the iterations, but instead of just 
# blindly evaluating each stone, we allow it to either decompose into
# new stones or to link to existing ones
# After everything is done we step through the graph and find how many stones 
# remain
function smartsolve(stones, n)
    graph = NamedDiGraph{UInt64}()
    unconnected = Set{UInt64}()

    for stone in stones
        add_vertex!(graph, stone)
        push!(unconnected, stone)
    end

    for i in 1:n
        new_unconnected = Set{UInt64}()
        for explore in unconnected
            results = applyrule(explore)
            for result in results
                if has_vertex(graph, result)
                    add_edge!(graph, explore, result)
                else
                    add_vertex!(graph, result)
                    push!(new_unconnected, result)
                end
            end
        end
        unconnected = new_unconnected
    end

    return graph
end