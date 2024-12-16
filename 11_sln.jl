using Graphs
using NamedGraphs
using GLMakie, SGtSNEpi

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

# At every node that bifurcates, we find the minimum of time for another bifurcation
# (Returns an array as big as the bifurcation set)
# At most n is returned
function mintobifurcation(bifurcating, graph, n)
    out = fill(n + 1, length(bifurcating))

    for i in eachindex(bifurcating)
        open = neighbors(graph, bifurcating[i])

        for it in 1:n
            found = false
            for j in eachindex(open)
                ns = neighbors(graph, open[j])
                if length(ns) == 2
                    found = true
                    break
                else
                    # This is safe as we replace the open we just inspected
                    open[j] = ns[1]
                end
            end
            if found
                out[i] = it
                break
            end
        end
    end

    return out
end

# We only need to decompose each stone once, so we can build a graph 
# with each stone and its decomposition diagram.
# To build this graph, we run the iterations, but instead of just 
# blindly evaluating each stone, we allow it to either decompose into
# new stones or to link to existing ones
# 
function smartsolve(stones, n)
    graph = NamedDiGraph{UInt64}()
    unconnected = Set{UInt64}()

    bifurcating = Set{UInt64}()

    for stone in stones
        add_vertex!(graph, stone)
        push!(unconnected, stone)
    end

    for i in 1:n
        new_unconnected = Set{UInt64}()
        for explore in unconnected
            results = applyrule(explore)
            for result in results
                if !has_vertex(graph, result)
                    add_vertex!(graph, result)
                    push!(new_unconnected, result)
                end
                add_edge!(graph, explore, result)
            end
            if length(results) == 2
                push!(bifurcating, explore)
            end
        end
        unconnected = new_unconnected
    end

    bifurcating = collect(bifurcating)

    mintobif = mintobifurcation(bifurcating, graph, n)

    # Any edge which ends in a non-bifurcating node can be simplified
    # We iteratively trim all edges that end in non-bifurcating nodes, as
    # these do not create new stones.

    return graph, mintobif
end

function solve1()

end