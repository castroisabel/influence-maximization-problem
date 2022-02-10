function bfs(g, node)
    p = [node]

    for i=1:size(g,1)
        if g[i,node] != 0
            append!(p, i)
        end
    end

    for i in p
        for j=1:size(g,1)
            if (g[j,i] != 0) & (j ∉ p)
                append!(p,j)
            end
        end
    end

    return sort(p)
end