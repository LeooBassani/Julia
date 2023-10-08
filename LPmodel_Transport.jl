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

#----------------------------------------------------------------------------------------------------
# Transport Modeling (Chair Distribution) - Minimize cost

# plan the (possible) transport between the production sites, depots, and retailers. Each plant still has the same monthly capacity that cannot be exceeded, 
# while the depots too have the same capacities. There is also the option of sending products between depots and retailers and between plants and retailers.

# The average cost of transport per chair per km is €0.0375

# Production site capacity
#  P1    P2
# 7500  8500

# Depot Capacities
#  D1   D2   D3   D4
# 3250 3500 3500 3000

# Distance between production sites and depots (km)
#    D1   D2  D3  D4
# P1 137  92  48 173
# P2 54  109 111  85

# Distance between production sites and retailers (km)
#    R1   R2  R3  R4  R5  R6
# P1 307 260 215 196 148 268
# P2 234 173 194 264 204 218

# Distances between depots and retailers (km)
#     R1 R2 R3  R4   R5  R6
# D1 109 58  65  187 128 88
# D2 214 163 54  89  26  114
# D3 223 173 97  71  29  162
# D4 81  51  133 239 170 155

# Retailer demand
#  R1   R2   R3   R4   R5   R6
# 1500 2500 2000 3000 2000 3000

# Formulate an LP to find the minimum-cost transportation plan

using JuMP
using Gurobi
using Printf

# Decision Variables
# Amount of products transported from plant p to depots d >= 0 (xpd)
# Amount of products transported from plant p to retailer r >= 0 (xpr)
# Amount of products transported from depots d to retailer r >= 0 (xdr)

# Parameters
# Production Plants
Plants = ["P1", "P2"]
P = length(Plants)
# Depots
Depots = ["D1", "D2", "D3", "D4"]
D = length(Depots)
# Retailers
Retailers = ["R1", "R2", "R3", "R4", "R5", "R6"]
R = length(Retailers)
# Plant Capacity
PlantCapacity = [7500, 8500]
# Depot Capacity
DepotCapacity = [3250, 3500, 3500, 3000]
# Retailers Capacity
RetailerDemand = [1500 2500 2000 3000 2000 3000]
# Distance between plants and depots
PDdist = [137 92 48 173;
          54 109 111 85]
# Distance between plants and retailers
PRdist = [307 260 215 196 148 268;
         234 173 194 264 204 218]
# Distances between depots and retailers
DRdist = [109 58 65 187 128 88;
          214 163 54 89 26 114;
          223 173 97 71 29 162;
          81 51 133 239 170 155]
# Fixed cost per km
F = 0.0375

# Model
CD = Model(Gurobi.Optimizer)
@variable(CD, xpd[p=1:P, d=1:D] >= 0)
@variable(CD, xpr[p=1:P, r=1:R] >= 0)
@variable(CD, xdr[d=1:D, r=1:R] >= 0)

# Objective function: minimize transportation costs
@objective(CD, Min,
           sum(PDdist[p,d]*F*xpd[p,d] for p=1:P, d=1:D) +
           sum(PRdist[p,r]*F*xpr[p,r] for p=1:P, r=1:R) +
           sum(DRdist[d,r]*F*xdr[d,r] for d=1:D, r=1:R))

# Constraints
# Production capacity limit for plant
@constraint(CD, [p=1:P],
           sum(xpd[p,d] for d=1:D) + sum(xpr[p,r] for r=1:R) <= PlantCapacity[p])
# Product capacity per depot
@constraint(CD, [d=1:D],
           sum(xdr[d,r] for r=1:R) <= DepotCapacity[d])
# What goes out of a depot must come into a depot
@constraint(CD, [d=1:D],
           sum(xpd[p,d] for p=1:P) == sum(xdr[d,r] for r=1:R))
# Ensure that a retailer demand is satisfied
@constraint(CD, [r=1:R],
           sum(xpr[p,r] for p=1:P) + sum(xdr[d,r] for d=1:D) == RetailerDemand[r])

# Solving
optimize!(CD)
println("Termination Status $(termination_status(CD))")

# Results
println("---------------------------")
if termination_status(CD) == MOI.OPTIMAL
    println("RESULTS: ")
    println("objective = $(objective_value(CD))")
    
    @printf "Plant transports\n"
    for p=1:P
        @printf "\t%s\n" Plants[p]
        @printf "\t\tDepots\n"
        for d=1:D
            if value(xpd[p,d])>0.001
                @printf "\t\t%s\tTransport: %.2f\n" Depots[d] value(xpd[p,d])
            end
        end

        @printf "\t\tRetailers\n"
        for r=1:R
            if value(xpr[p,r])>0.001
                @printf "\t\t%s\tTransport: %.2f\n" Retailers[r] value(xpr[p,r])
            end
        end

        @printf "\n"
    end

    @printf "Depots\n"
    for d=1:D
        @printf "\t%s\n" Depots[d]
        for r=1:R
            if value(xdr[d,r])>0.001
                @printf "\t\t%s\tTransport: %.2f\n" Retailers[r] value(xdr[d,r])
            end
        end

        @printf "\n"
    end
else
    println(" No solution")
end
