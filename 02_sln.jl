using Combinatorics

function get_reports()
    lines = readlines("02_input.txt")
    reports = map(x -> parse.(Int, x), split.(lines, ' '))
    return reports
end

function is_safe(report)
    max_diff = -999999
    min_diff = 999999
    max_absdiff = -9999
    min_absdiff = 9999
    for pair ∈ zip(report[1:end-1], report[2:end])
        dist = pair[2] - pair[1]
        absdist = abs(dist)
        if dist > max_diff
            max_diff = dist
        end

        if dist < min_diff
            min_diff = dist
        end

        if absdist > max_absdiff
            max_absdiff = absdist
        end

        if absdist < min_absdiff
            min_absdiff = absdist
        end
    end


    if (min_diff > 0 && max_diff > 0) || (min_diff < 0 && max_diff < 0)
        if max_absdiff <= 3 && min_absdiff >= 1
            return true
        end
    end

    return false

end

function is_safe_with_damper(report)
    # Brute-force approach
    for comb ∈ combinations(report, length(report) - 1)
        if is_safe(comb)
            return true
        end
    end

    return false

end