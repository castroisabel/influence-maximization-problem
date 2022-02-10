function powerset(x::Vector{T}) where T
    result = Vector{T}[[]]
    for elem in x, j in eachindex(result)
        push!(result, [result[j] ; elem])
    end
    result
end

function scenarios(g, opc)
    n = size(g,1) 

    # Calculation of different possible scenarios
    scenario = [g[i,j] for j in 1:n, i in 1:n if g[i,j]!=0]
    scenario_index = [float(i) for i in 1:length(scenario)]
    c = powerset(scenario_index)

    # Replacement of empty spaces by the negative equivalent to identify the edges that were not connected
    for i in 1:length(c)
        if length(c[i]) < length(scenario)
            for j ∈ scenario_index
                if j ∉ c[i] 
                    append!(c[i], -j)
                end
            end
        end
    end

    c = reverse(c) # Better view compared to the article

    # Arrange in ascending order of absolute value to identify corresponding vertices
    for i=1:length(c)
        c[i] = sort(c[i], by=abs)
    end

    # Association of the corresponding probabilities
    for i in 1:length(c)
        for j in 1:length(c[i])
            if c[i][j]>=0
                c[i][j] = round(scenario[round(Int32, c[i][j])], digits = 1)
            else
                if opc == 1
                    c[i][j] = round(1-scenario[round(Int32,abs(c[i][j]))], digits = 1)
                else
                    c[i][j] = 0
                end
            end
        end
    end

    return c
end
