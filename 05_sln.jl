using ReadableRegex

function separateinput()
    lines = readlines("05_input.txt")
    rules = String[]
    updates = String[]

    readingrules = true

    for line ∈ lines
        if readingrules
            if isempty(line)
                readingrules = false
            else
                push!(rules, line)
            end
        else
            push!(updates, line)
        end
    end

    return (rules_txt=rules, updates_txt=updates)
end

# Returns an array of tuples each with a rule
function getrules(rules_txt)
    rules = Tuple{Int32,Int32}[]

    for line ∈ rules_txt
        captures = match(r"(\d+)\|(\d+)", line).captures
        push!(rules, (parse(Int32, captures[1]), parse(Int32, captures[2])))
    end

    return rules
end

function getupdates(updates_txt)
    updates = Array{Array{Int32}}(undef, 0)

    regex = capture(one_or_more(DIGIT)) * zero_or_more(',')
    for line ∈ updates_txt
        update = Array{Int32}(undef, 0)
        matches = eachmatch(regex, line)
        for match ∈ matches
            push!(update, parse(Int32, match.captures[1]))
        end
        push!(updates, update)
    end

    return updates
end

function isordered(update, rules)
    for rule ∈ rules
        idxfirst = findfirst(x -> x == rule[1], update)
        idxsecond = findlast(x -> x == rule[2], update)

        if !isnothing(idxfirst) && !isnothing(idxsecond)
            if idxfirst > idxsecond
                return false
            end
        end
    end

    return true
end

function solve1(updates, rules)
    sum = 0
    for goodupdate ∈ filter(x -> isordered(x, rules), updates)
        sum += goodupdate[end÷2+1]
    end
    return sum
end

function applyrule!(update, rule)
    aidx = findfirst(x -> x == rule[1], update)
    bidx = findlast(x -> x == rule[2], update)
    if isnothing(aidx) || isnothing(bidx)
        return
    end

    if aidx > bidx
        # Swap the elements
        update[aidx] = rule[2]
        update[bidx] = rule[1]
    end
end

function sortupdate(update, rules)
    update_copy = copy(update)
    while !isordered(update_copy, rules)
        for rule ∈ rules
            applyrule!(update_copy, rule)
        end
    end
    return update_copy
end

function solve2(updates, rules)
    sum = 0
    for badupdate ∈ filter(x -> !isordered(x, rules), updates)
        sorted = sortupdate(badupdate, rules)
        sum += sorted[end÷2+1]
    end
    return sum
end