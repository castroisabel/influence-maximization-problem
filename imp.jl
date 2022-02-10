using JuMP, Gurobi, DelimitedFiles, CSV, DataFrames
include("breadth-first-search.jl")
include("scenarios.jl")

function imp(mu, k, p)
    R =  length(mu)
    V = size(p,1)
    model = Model(optimizer_with_attributes(Gurobi.Optimizer))

    # Decision variables
    @variable(model, y[i in 1:V], Bin)
    @variable(model, x[i in 1:V,r in 1:R], lower_bound = 0, upper_bound = 1)

    # Objective function
    @objective(model, Max, sum(mu[r]*x[i,r] for r in 1:R, i in 1:V))

    # Constraints
    @constraint(model, sum(y[i] for i in 1:V)==k)
    @constraint(model, [r in 1:R,i in 1:V], sum(y[j] for j in p[i,r])>= x[i,r])
    

    # Solving the model
    status = optimize!(model)
    zIP = objective_value(model)
    tzIP = MOI.get(model, MOI.SolveTimeSec())
    return(value.(y), zIP, tzIP)
end

function calculate_mu(g)
    n = size(g,1) 
    comb = scenarios(g, 1)
    mu = [] # Vector mu indicates the probability of each scenario
    for i in 1:length(comb)
        append!(mu, round(prod(comb[i]), digits = 4))
    end

    return mu
end

function calculate_pir(g)
    n = size(g,1)
    comb = scenarios(g,2)

    matrix = []
    push!(matrix,g)
    for h=2:length(comb)
        m = copy(g)
        k = 1
        for i=1:n
            for j=1:n
                if g[i,j] != 0
                    m[i,j] = comb[h][k]
                    k = k+1
                end
            end
        end
        push!(matrix,m)
    end

    # Set of all predecessor nodes of i in the rth scenario
    p_ir = [[i] for i in 1:n, j in 1:length(comb)]

    # Calculating the set P_ir
    for i=1:n
        for j=1:length(matrix)
            p_ir[i,j] = bfs(matrix[j],i)
        end
    end
    
    return p_ir
end

 g = [ 0 0.6 0 0 0;
      0 0 0 0.8 0;
      0 0 0 0.3 0;
      0 0.4 0 0 0.5;
      0 0 0 0 0]


mu = calculate_mu(g)
p_ir =calculate_pir(g)
n = size(g,1)
k = 2
y, great_value, time = imp(mu, k, p_ir)
println("Great value: ", round(great_value, digits = 3))
println("Processing time: ", time)
println("Solution: ",y)
