
function getmap()
    lines = readlines("04_input.txt")
    maparray = []
    for line ∈ lines
        row = Char[]
        for char ∈ line
            push!(row, char)
        end
        push!(maparray, row)
    end

    return hcat(maparray...)
end

function check(map, remstr, x, dx)
    if length(remstr) == 0
        return true
    end

    smap = size(map)
    if x[1] <= 0 || x[2] <= 0 || x[1] > smap[1] || x[2] > smap[2]
        return false
    end

    if map[x[1], x[2]] == remstr[1]
        return check(map, remstr[2:end], (x[1] + dx[1], x[2] + dx[2]), dx)
    else
        return false
    end
end

manhattan_dirs() = return [(0, -1), (0, 1), (-1, 0), (1, 0),
    (-1, -1), (-1, 1), (1, -1), (1, 1)];



function numxmas(map, x)
    dirs = manhattan_dirs()
    sum = 0

    for dir ∈ dirs
        sum += check(map, "XMAS", x, dir)
    end

    return sum
end

function getxmas(map)
    # We find all X, and then search neighbors in all directions, 
    # this is fairly naive
    xcoords = findall(x -> x == 'X', map)
    return sum(Base.map(x -> numxmas(map, (x[1], x[2])), xcoords))

end

function isxshapedmas(map, cx, cy)
    # Top-left to bottom right check
    is_tl_mas = check(map, "MAS", (cx - 1, cy - 1), (1, 1))
    is_tl_sam = check(map, "SAM", (cx - 1, cy - 1), (1, 1))
    is_tl = is_tl_mas || is_tl_sam
    # Bottom left to top right check
    is_bl_mas = check(map, "MAS", (cx - 1, cy + 1), (1, -1))
    is_bl_sam = check(map, "SAM", (cx - 1, cy + 1), (1, -1))
    is_bl = is_bl_mas || is_bl_sam

    return is_tl && is_bl
end

function getxshapedmas(map)
    centers = findall(x -> x == 'A', map)
    return sum(Base.map(x -> isxshapedmas(map, x[1], x[2]), centers))
end