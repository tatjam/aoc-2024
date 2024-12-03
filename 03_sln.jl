
function get_code()
    return read("03_input.txt", String)
end

function total(code)
    sum(map(x -> parse(Int, x.captures[1]) * parse(Int, x.captures[2]), eachmatch(r"mul\((\d+)\,(\d+)\)", code)))
end

function in_do(dos, donts, off)
    last_do = 0
    last_dont = -1
    for do_call ∈ dos
        if do_call < off
            last_do = do_call
        end
    end

    for dont_call ∈ donts
        if dont_call < off
            last_dont = dont_call
        end
    end

    return last_do > last_dont
end

function conditional_total(code::String)
    dos = map(x -> x.offset, eachmatch(r"do\(\)", code))
    donts = map(x -> x.offset, eachmatch(r"don't\(\)", code))

    total = 0

    for match ∈ eachmatch(r"mul\((\d+)\,(\d+)\)", code)
        off = match.offset

        if in_do(dos, donts, off)
            num0 = parse(Int, match.captures[1])
            num1 = parse(Int, match.captures[2])
            total += num0 * num1
        end
    end

    return total
end