struct Map
    guardstart::Tuple{Int32,Int32}
    obstaclemap::Matrix{Bool}
end


function readmap()
    lines = readlines("06_input.txt")
    mapwidth = length(lines[1])
    mapheight = length(lines)

    obstaclemap = Matrix{Bool}(undef, mapheight, mapwidth)
    guardstart = nothing

    for lineidx ∈ eachindex(lines)
        line = lines[lineidx]
        for colidx ∈ eachindex(line)
            obstaclemap[lineidx, colidx] = line[colidx] == '#'
            if line[colidx] == '^'
                guardstart = (lineidx, colidx)
            end
        end
    end

    return Map(guardstart, obstaclemap)
end

# Returns nothing if guard goes out of map,
# otherwise returns (nguardpos, nguarddir)
function guardstep(obstaclemap, guardpos, guarddir)
    nguardpos = guardpos .+ guarddir
    if !checkbounds(Bool, obstaclemap, nguardpos...)
        return nothing
    end

    nguarddir = guarddir
    if obstaclemap[nguardpos...]
        # Turn right
        nguardpos = guardpos
        if guarddir == (-1, 0)
            nguarddir = (0, 1)
        elseif guarddir == (0, 1)
            nguarddir = (1, 0)
        elseif guarddir == (1, 0)
            nguarddir = (0, -1)
        elseif guarddir == (0, -1)
            nguarddir = (-1, 0)
        end
    end

    return (nguardpos, nguarddir)
end

function visitedmap(map)
    visitedmap = fill(false, size(map.obstaclemap))
    guardpos = map.guardstart
    guarddir = (-1, 0)
    visitedmap[guardpos...] = true

    while true
        tuple = guardstep(map.obstaclemap, guardpos, guarddir)
        if isnothing(tuple)
            break
        else
            (guardpos, guarddir) = tuple
        end
        visitedmap[tuple[1]...] = true
    end

    return visitedmap
end

function solve1()
    map = readmap()
    return count(x -> x == true, visitedmap(map))
end