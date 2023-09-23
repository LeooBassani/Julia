# Transport Modeling

# The company has two production sites (P1 and P2) and four major storage deposits (D1, D2, D3 and D4). The products can be produced
# at both production sites and can be stacked efficiently. The objectice is to minimize the Transport costs. The average for tranposting 
# one product one kilometer is $0.0375.

# Capacity production sites
#  P1    P2  
# 7500  8500

# Deposits demand
#  D1   D2   D3   D4
# 3250 3500 3500 3000

# Distance between the production sites and deposits (km)
#      D1  D2  D3   D4    
# P1  137  92  48  173
# P2   54 109 111   85

using JuMP
using Gurobi

# Parameters
Plants = ["P1", "P2"]
P = length(Plants)
Deposits = ["D1", "D2", "D3", "D4"]
D = length(Deposits)
PlantsCapacity = [7500, 8500]
DepositsCapacity = [3250, 3500, 3500, 3000]
Distance = [137 92 48 173;
            54 109 111 85]
F = 0.0375

# Model
CT = Model(Gurobi.Optimizer)
# Variables Plants and Deposits
@variable(CT, x[1:P, 1:D] >= 0)

# Objective function
@objective(CT, Min, sum(Distance[p,d] * F * x[p,d] for p=1:P, d=1:D))

# Constraints
# Plant Capacity limit
@constraint(CT, [p=1:P], sum(x[p,d] for d=1:D) <= PlantsCapacity[p])
# Deposit demand
@constraint(CT, [d=1:D], sum(x[p,d] for p=1:P) >= DepositsCapacity[d])

print(CT)

# Solving
optimize!(CT)
println("Terminal Status: $(termination_status(CT))")
if termination_status(CT) == MOI.OPTIMAL
    println("Optimal objective value: $(objective_value(CT))")
    println("Solution:")
    for p = 1:P
        for d in 1:D
            println(" $(Plants[p]) $(Deposits[d]) = $(value(x[p,d]))")
        end
    end
else
    println("No optimal solution available")
end