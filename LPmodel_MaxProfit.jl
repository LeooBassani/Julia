# Chair Production

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


#-------------------------------------------------------------------------------------------------

# Jewellery Production

# Profit of each jewellery
#  1  2  3  4  5
# 50 35 85 60 55

# Three machines are used to produce the jewellery components, which are assemble by two employees

# Machine time needed for each necklace (minutes)
#    1 2  3  4 5
# 1  7 0  0  9 0
# 2  5 7 11  0 5
# 3  0 3  8 15 3

# Jewellery assembly line (minutes)
#  1 2  3 4 5
# 12 3 11 9 6

# A full day work, bith for the assembly line and the machines is 7,5h

# A estimate demand for each jewellery is available

# Jewellery demand
#  1  2  3  4  5 
# 25 10 12 15 60

# Formulate an LP that can be used to maximize the daily profit

using JuMP
using Gurobi

# Data
Jewellery = ["Jewellery 1", "Jewellery 2", "Jewellery 3", "Jewellery 4", "Jewellery 5"]
J = length(Jewellery)
Machines = ["Machine 1", "Machine 2", "Machine 3"]
M = length(Machines)
Profit = [50 35 85 60 55]
AssemblyLine = [12 3 11 9 6]
MachineTime = [7 0 0 9 0;
               5 7 11 0 5;
               0 3 8 15 3]
DayMinutes = 60 * 7.5
NoAssemblyWorkers = 3
Demand = [25 10 12 15 60]

# Model
JP = Model(Gurobi.Optimizer)
@variable(JP, x[j=1:J]>=0)

# Maximize Profit
@objective(JP, Max, sum(Profit[j]*x[j] for j=1:J))

# Constraints
# Machhine constraints
@constraint(JP, [m=1:M],
           sum(MachineTime[m,j]*x[j] for j=1:J) <= DayMinutes)
# Assembly Capacity
@constraint(JP, sum(AssemblyLine[j]*x[j] for j=1:J) <= DayMinutes*NoAssemblyWorkers)
# Demand Limits
@constraint(JP, [j=1:J], x[j] <= Demand[j])

# Solving
solution = optimize!(JP)
println("Terminal status: $(termination_status(JP))")
if termination_status(JP) == MOI.OPTIMAL
    println("Optimal value: $(objective_value(JP))")
    for j=1:J
        println("Production of $(Jewellery[j]): ", value(x[j]))
    end
else
    println("No optimal solution available")
end
