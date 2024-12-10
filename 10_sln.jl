
function readmap()
    lines = readlines("10_input.txt")
    mapwidth = length(lines[1])
    mapheight = length(lines)

    map = Matrix{Int8}(undef, mapheight, mapwidth)

    for y ∈ eachindex(lines)
        for x ∈ eachindex(lines[y])
            map[y, x] = parse(Int8, lines[y][x])
        end
    end

    return map
end

function isuptrail(npos, currenth, map)
    if npos[1] > 0 && npos[2] > 0 && npos[1] <= size(map)[1] && npos[2] <= size(map)[2]
        return map[npos...] == currenth + 1
    else
        return false
    end
end

# Recursively finds all rechable 9s moving uptrail
function findreachable9(start, map)
    if map[start...] == 9
        return start
    else
        total = []
        # Find uptrail directions
        directions = [(-1, 0), (0, -1), (1, 0), (0, 1)]
        for dir in directions
            npos = start .+ dir
            if isuptrail(npos, map[start...], map)
                total = vcat(total, findreachable9(npos, map))
            end
        end

        return total
    end
end

function findtrailheads(map)
    out = []
    for j in 1:size(map)[2]
        for i in 1:size(map)[1]
            if map[i, j] == 0
                push!(out, (i, j))
            end
        end
    end
    return out
end

function solve1()
    map = readmap()
    trailheads = findtrailheads(map)
    total = 0
    for thead in trailheads
        total += length(Set(findreachable9(thead, map)))
    end
    return total
end

function solve2()
    map = readmap()
    trailheads = findtrailheads(map)
    total = 0
    for thead in trailheads
        total += length(findreachable9(thead, map))
    end
    return total
end