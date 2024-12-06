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
    nguardpos = guardpos
    nguarddir = guarddir
    while nguardpos == guardpos
        nguardpos = guardpos .+ nguarddir
        if !checkbounds(Bool, obstaclemap, nguardpos...)
            return nothing
        end
        if obstaclemap[nguardpos...]
            # Turn right
            nguardpos = guardpos
            if nguarddir == (-1, 0)
                nguarddir = (0, 1)
            elseif nguarddir == (0, 1)
                nguarddir = (1, 0)
            elseif nguarddir == (1, 0)
                nguarddir = (0, -1)
            elseif nguarddir == (0, -1)
                nguarddir = (-1, 0)
            end
        end
    end
    return (nguardpos, nguarddir)

end

function visitedmap(map)
    visitedmap = fill((0, 0), size(map.obstaclemap))
    guardpos = map.guardstart
    guarddir = (-1, 0)
    visitedmap[guardpos...] = (-1, 0)

    while true
        tuple = guardstep(map.obstaclemap, guardpos, guarddir)
        if isnothing(tuple)
            break
        else
            (guardpos, guarddir) = tuple
        end
        if visitedmap[guardpos...] == guarddir
            # loop found
            return nothing
        end
        visitedmap[tuple[1]...] = guarddir
    end

    return visitedmap
end

function solve1()
    map = readmap()
    return count(x -> x != (0, 0), visitedmap(map))
end

function bruteforcesolve2()
    map = readmap()

    sum = 0
    for idx ∈ eachindex(map.obstaclemap)
        nobstaclemap = copy(map.obstaclemap)
        nobstaclemap[idx] = true
        nmap = Map(map.guardstart, nobstaclemap)
        if isnothing(visitedmap(nmap))
            sum += 1
            display(sum)
        end
    end
    return sum
end