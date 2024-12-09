using Combinatorics

function readmap()
    lines = readlines("08_input.txt")
    mapwidth = length(lines[1])
    mapheight = length(lines)

    # Antennas are ('char', (y, x))
    antennas = []

    for y ∈ eachindex(lines)
        for x ∈ eachindex(lines[y])
            if lines[y][x] != '.'
                antenna = (lines[y][x], (y, x))
                push!(antennas, antenna)
            end
        end
    end

    return (antennas=antennas, size=(mapheight, mapwidth))
end

function pushtofreq!(out, antenna)
    freq = antenna[1]
    for outarray ∈ out
        if outarray[1] == freq
            push!(outarray[2], antenna[2])
            return true
        end
    end
    return false
end

# Returns an array of arrays, of all antenna location for a given frequency
function antennapairs(map)
    out = []
    for antenna ∈ map.antennas
        found = pushtofreq!(out, antenna)
        if !found
            npair = (antenna[1], [])
            push!(npair[2], antenna[2])
            push!(out, npair)
        end
    end
    return out
end

function inbounds(pos, map)
    return pos[1] > 0 && pos[1] <= map.size[1] && pos[2] > 0 && pos[2] <= map.size[2]
end

# Returns each antinode between the antennas contained in freq,
# possibly duplicated
function getantinodes(freq, map)
    pairs = combinations(freq[2], 2)
    out = []
    for pair ∈ pairs
        from1to2 = pair[2] .- pair[1]
        anodea = pair[1] .- from1to2
        if inbounds(anodea, map)
            push!(out, anodea)
        end
        anodeb = pair[2] .+ from1to2
        if inbounds(anodeb, map)
            push!(out, anodeb)
        end
    end
    return out
end

function getantinodes_resonant_dir!(out, start, dir, map)
    pos = start
    while inbounds(pos, map)
        push!(out, pos)
        pos = pos .+ dir
    end
end

function getantinodes_resonant_pair!(out, pair, map)
    from1to2 = pair[2] .- pair[1]
    from2to1 = pair[1] .- pair[2]
    getantinodes_resonant_dir!(out, pair[1], from1to2, map)
    getantinodes_resonant_dir!(out, pair[2], from2to1, map)
end

function getantinodes_resonant(freq, map)
    pairs = combinations(freq[2], 2)
    out = []
    for pair ∈ pairs
        getantinodes_resonant_pair!(out, pair, map)
    end
    return out
end

function solve1()
    map = readmap()
    ants = antennapairs(map)
    antinodes = vcat(
        Base.map(
            x -> getantinodes(x, map),
            ants)...
    )
    antinodeset = Set(antinodes)
    return length(antinodeset)
end

function solve2()
    map = readmap()
    ants = antennapairs(map)
    antinodes = vcat(
        Base.map(
            x -> getantinodes_resonant(x, map),
            ants)...
    )
    antinodeset = Set(antinodes)
    return length(antinodeset)
end