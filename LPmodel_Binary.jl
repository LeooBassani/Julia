# Binary Modeling

# Five people apllied for five different jobs. Each person ranked their preferenced job a scale from 1 to 5 (with five the best). Each person
# can only do one job, and one job can only be done by one person.
# Formulate an LP that can be used to find the best assignment of the jobs. The best assigment is the one that maximize the total preferences.

#    A B C D E
# 1  1 3 2 5 5
# 2  5 2 1 1 2
# 3  1 5 1 1 1
# 4  4 5 4 4 4
# 5  3 5 3 5 3

using JuMP
using Gurobi

# data
Person = [1 2 3 4 5]
C = length(Person)

Jobs = [1 2 3 4 5]
J = length(Jobs)

Wish = [1 3 2 5 5;
        5 2 1 1 2;
        1 5 1 1 1;
        4 5 4 4 4;
        3 5 3 5 3]

# Model
CJ = Model(Gurobi.Optimizer)
@variable(CJ, x[j=1:J, c=1:C]>=0)

# Objective Function - Maximize 
@objective(CJ, Max, sum(Wish[j,c]*x[c,j] for j=1:J, c=1:C))

# Constraint 
# One job per person
@constraint(CJ, [c=1:C],
            sum(x[j,c] for j=1:J) == 1)

# One person per job
@constraint(CJ, [j=1:J],
            sum(x[j,c] for c=1:C) == 1)

# Solving
solution = optimize!(CJ)
println("Termination Status: $(termination_status(CJ))")

if termination_status(CJ) == MOI.OPTIMAL
    println("Optimal objective function: $(objective_value(CJ))")
    for c=1:C
        for j=1:J
            if value(x[j,c])>0.999
                println("Person: ", c, " Doing Job: ", j)
            end
        end
    end
else
    println("No optimal solution available")
end