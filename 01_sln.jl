using DataFrames
using CSV

function get_data()
    data = DataFrame(CSV.File("01_input.txt", header=["left", "right"], delim=' ', ignorerepeated=true))
    return data
end

function get_distance()
    data = get_data()
    return sum(abs.(sort(data.right) - sort(data.left)))
end

function get_similarity()
    data = get_data()
    total = 0
    for elem ∈ data.left
        total += elem * count(x -> x == elem, data.right)
    end
    return total
end