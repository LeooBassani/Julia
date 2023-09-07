# Chair Production

# The company Incredible Chairs produces two different types of chairs, A and B, where one unit of Chair A can be 
# sold for a profit of 4 and one unit of Chair B can be sold for a profit of 6. The chairs are produced on three production lines:

# Line 1: requires 2 hours to produce one unit of Chair A, and at most 14 hours can be used due to other production on the line.
# Line 2: requires 3 hours to produce one unit of Chair B, and at most 15 hours can be used.
# Line 3: requires 4 hours to produce one unit of Chair A and 3 hours to produce one unit of chair B, and at most 36 hours can be used.

# How many of each type of chair to produce in one day as the best feasible production plan?

# Importing optimizer
# import  Pkg
# Pkg.add("JuMP")
# import  Pkg
# Pkg.add("HiGHS")
using JuMP
using HiGHS

# Difining model
IC = Model(HiGHS.Optimizer)

# Decision variables (variable that we want to dicovery)
@variable(IC,xA>=0, Int)
@variable(IC,xB>=0, Int)

#  Objective function
@objective(IC,Max,4*xA + 6*xB)

# constraints (that limit our value)
# 2*xA <= 14
# 3*xB <= 15
# 4*xA + 3xB <= 36
@constraint(IC,2*xA <= 14)
@constraint(IC,3*xB <= 15)
@constraint(IC,4*xA + 3*xB <= 36)

# Showing the variables
print(IC)

# Optmizer
optimize!(IC)
println("Termination Status: $(termination_status(IC))")

# Results
if termination_status(IC) == MOI.OPTIMAL
        println("Optimimal objective value: $(objective_value(IC))")
        println("xA: ",round(Int64,value(xA)))
        println("xB: ",round(Int64,value(xB)))
else
    println("No optimal solution available")
end