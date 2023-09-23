# Chair Production 2

# Formulate an LP to maximize the profit of the chair production

# 5 productions lines
# 8 different products

# Profit of each chair
# A B C D E F G H I J
# 6 5 9 5 6 3 4 7 4 3

# Capacity of each line
# Line  1  2  3  4  5
#      47 19 36 13 46

# Resource needed for each line
#    A  B C  D E  F G H  I J 
# 1  6  4 2  3 1 10 2 9  3 5
# 2  5  6 1  1 7  2 9 1  8 6
# 3  8 10 7  2 9  6 9 6  5 6
# 4  8  4 8 10 5  4 1 5  3 5
# 5  1  4 7  2 4  1 2 3 10 1


# Importing optimizer
# import  Pkg
# Pkg.add("JuMP")
# import  Gurobi
# Pkg.add("Gurobi")
using JuMP
using Gurobi

# Data
# Products
Chairs = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]
C = length(Chairs)
# Number of Production Lines
ProductionLines=[1,2,3,4,5]
P = length(ProductionLines)
# Profit of each chair
Profit = [6,5,9,5,6,3,4,7,4,3]
# Capacity of each production line
Capacity = [47,19,36,13,46]
# Matriz of use of each chair in production vs production line
RecourseUsage = [6 4 2 3 1 10 2 9 3 5;
                 5 6 1 1 7 2 9 1 8 6;
                 8 10 7 2 9 6 9 6 5 6;
                 8 4 8 10 5 4 1 5 3 5;
                 1 4 7 2 4 1 2 3 10 1]

# Model
IC2 = Model(Gurobi.Optimizer)

# x[c] is the number of chairs
@variable(IC2,x[1:C]>=0)

# Objective maximize profit
@objective(IC2, Max, sum(Profit[c]*x[c] for c=1:C))

# Ensuring production line capacity is not exceeded
@constraint(IC2, [p=1:P], sum(RecourseUsage[p,c]*x[c] for c=1:C) <= Capacity[p])

# Setting a optimizer time limit to 300s
# set_time_limit_sec(IC2, 300.0)

# Setting a 10% gap between the best possible objective values in HiGHS
# set_optimizer_attribute(IC2, "mip_rel_gap", 0.10)

# Setting in Gurobi
# set_optimizer_attribute(IC2, "MPGap", 0.10)

# Optimize
optimize!(IC2)
println("Termination Status: $(termination_status(IC2))")
if termination_status(IC2) == MOI.OPTIMAL
    println("Optimial objective value: $(objective_value(IC2))")
    for c=1:C
        if value(x[c])>0.001 # only print the chairs actually produced
            println("type of chairs: ", Chairs[c], " produced: ", round(Int64,value(x[c])))
        end
    end
else
    println("No optimal solution available")
end
