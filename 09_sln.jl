using Base.Iterators: partition

# Returns pairs of each block ID, its length and its location, everything else is 
# empty space. Positions count starting at 0
function getblocks()
    #line = collect(readlines("09_input.txt")[1])
    line = collect(readlines("09_input.txt")[1])
    out = []
    ptr = 0
    id = 0
    for pairs in partition(line, 2)
        nfile = parse(Int64, pairs[1])
        push!(out, (id=id, len=nfile, off=ptr))
        id += 1
        if length(pairs) == 2
            nempty = parse(Int64, pairs[2])
            ptr += nfile + nempty
        end
    end
    return out
end

# Creates an empty disk given all blocks, where empty is represented by -1
function make_emptydisk(blocks)
    last = 0
    for block in blocks
        if block.len + block.off > last
            last = block.len + block.off
        end
    end
    return fill(-1, last + 1)
end

function placefiles!(disk, blocks)
    for block in blocks
        disk[block.off+1:block.off+block.len] .= block.id
    end
end

# Returns 0 if impossible to find
function last_nonempty(disk)
    for i in reverse(eachindex(disk))
        if disk[i] != -1
            return i
        end
    end
    return 0
end

# Returns 0 if impossible to find
function first_empty(disk)
    for i in eachindex(disk)
        if disk[i] == -1
            return i
        end
    end
    return 0
end

# Returns true if defragmentation was possible
function fragment_one!(disk)
    last = last_nonempty(disk)
    first = first_empty(disk)
    if first < last
        disk[first] = disk[last]
        disk[last] = -1
        return true
    else
        return false
    end
end

function fragment!(disk)
    while fragment_one!(disk)
    end
end

function find_blockid(blocks, id)
    for i in eachindex(blocks)
        if blocks[i].id == id
            return i
        end
    end
    return 0
end

function tryfragment_block!(blocks, id)
    i = find_blockid(blocks, id)
    for si in 1:(i-1)
        freespace = blocks[si+1].off - blocks[si].off - blocks[si].len
        if freespace >= blocks[i].len
            block = blocks[i]
            insert!(blocks, si + 1, (
                id=block.id,
                len=block.len,
                off=blocks[si].off + blocks[si].len
            ))
            deleteat!(blocks, i + 1)
            return true
        end
    end
    return false
end

# In this case, we move whole blocks
function fragment_blockwise!(blocks)
    maxid = blocks[end].id

    for id in maxid:-1:0
        moved = tryfragment_block!(blocks, id)
        if id % 100 == 0
            display(id)
            display(maxid)
        end
    end
end

function checksum(disk)
    sum = convert(BigInt, 0)

    for i in eachindex(disk)
        if disk[i] != -1
            sum += (i - 1) * disk[i]
        end
    end
    return sum
end

function solve1()
    blocks = getblocks()
    disk = make_emptydisk(blocks)
    placefiles!(disk, blocks)
    fragment!(disk)
    return checksum(disk)
end

function solve2()
    blocks = getblocks()
    fragment_blockwise!(blocks)
    disk = make_emptydisk(blocks)
    placefiles!(disk, blocks)
    return checksum(disk)
end