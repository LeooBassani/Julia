# Project Scheduling

# Given the list below, you need to make a project plan, i.e. when should each task be performed. To keep things simple, we simply work 
# with full working days. Notice that some tasks need to be finished before other tasks can be performed.

# List of tasks
# 1. Remove Stuff: duration 1 day
# 2. Shed Demolition: after Remove Stuff, duration 3 days
# 3. Pipe Work: after Shed Demolition, duration 5 days
# 4. Electric Work: after Shed Demolition, duration 3 days
# 5. Flagstones: after Pipe Work and Electric Work, duration 7 days
# 6. Shed Foundations: after Pipe Work and Electric Work, duration 4 days
# 7. Wood Frames: after Shed Foundations, duration 3 days
# 8. Painting: after Wood Frames, duration 1 day
# 9. Roofing: after Wood Frames, duration 1 day
# 10. Roofing Felt: after Roofing, duration 1 day
# 11. Interior Installations: after Roofing, duration 3 days
# 12. Insert Stuff: after Roofing, duration 1 day
# 13. Hand over: after flagstones, painting, roofing felt, interior installations and insert stuff, duration 0 days

# Implement the Tool Shed Project Scheduling and minimize the number of days needed before hand over

# However, as an early finish looking at the plan and contact all the contractors, who use more than one day for the job, and ask how 
# much they can speed up the work, and how much overtime pay they need per speed-up day. This gives the information below.
# 1. Shed Demolition: Can be reduced 1 day at an overtime pay of 500 per day
# 2. Pipe Work: Can be reduced 3 days at an overtime pay of 2000 per day
# 3. Electric Work: Can be reduced 1 day at an overtime pay of 4000 per day
# 4. Flag Stones: Can be reduced 4 days at an overtime pay of 1000 per day
# 5. Shed Foundations: Can be reduced 2 days at an overtime pay of 1000 per day
# 6. Wood Frames: Can be reduced 2 days at an overtime pay of 1500 per day
# 7. Interior Installations: Can be reduced 2 days at an overtime pay of 1500 per day

# For comparison, you also calculate the earliest completion times if you have a budget of 5000 and if you have a a budget of 10000

# -------------------------------------------------------------------------------------------------------------------------------------------------------
# Sets 
# t E tasks = {Remove Stuff, Shed Demolition....}
# MaxSpeedPat = maximal number of days that a task can be speed up
# OverTimePay = extra cost for each day which is speed up
# Budget = how much money you can spend

# Parameters
# Predecessors t2, t1: Predecessors t2, t1 = 1 if task t2 should be preceded by task t1

# Decicion variables
# Starting day of tasks t: xt >= 0
# The start t: 0 <= yt <= MaxSpeedPat

# Model
# Minimize the starting point of the last task T 

# Constraints
# Predence constraint 
    # xt1 + Duration t1 - yt1 <= xt2 (for all predecessors who's = 1)
# Budget
    # Sum (OverTimePay * yt1 <= Budget)

#----------------------------------------------------------------------------------------------------------------------------------------------------------
# import Pkg
# Pkg.add("Clp")
using JuMP
using Clp

# Parameters
Tasks = ["Remove Stuff", "Shed Demolition", "Pipe Work", "Electric Work", "Flagstones", "Shed Foundations", "Wood Frames", "Painting", "Roofing", "Roofing Felt",
        "Interior Installations", "Insert Stuff", "Hand over"]
T = length(Tasks)

# duration time in days of each task
Duration = [1,3,5,3,7,4,3,1,1,1,3,1,0]
MaxSpeedPat = [0,1,3,1,4,2,2,0,0,0,2,0,0]

# Budget
Budget = 5000
#Budget = 10000
OverTimePay = [0,500,2000,4000,1000,1000,1500,0,0,0,1500,0,0]

Predecessors = zeros(T,T)
# Task 1

# Task 2
Predecessors[2,1]=1
# Task 3
Predecessors[3,2]=1
# Task 4
Predecessors[4,2]=1
# Task 5
Predecessors[5,3]=1
Predecessors[5,4]=1
# Task 6
Predecessors[6,3]=1
Predecessors[6,4]=1
# Task 7
Predecessors[7,6]=1
# Task 8
Predecessors[8,7]=1
# Task 9
Predecessors[9,7]=1
# Task 10
Predecessors[10,9]=1
# Task 11
Predecessors[11,9]=1
# Task 12
Predecessors[12,9]=1
# Task 13
Predecessors[13,5]=1
Predecessors[13,8]=1
Predecessors[13,10]=1
Predecessors[13,11]=1
Predecessors[13,12]=1

# Model
schedule = Model(Clp.Optimizer)

# Start time of task
@variable(schedule, 0 <= x[t=1:T])
# Save time
@variable(schedule, 0 <= y[t=1:T] <= MaxSpeedPat[t])

# Objective function
@objective(schedule, Min, x[T])

# Force predecessors relation
@constraint(schedule, [t1=1:T,t2=1:T; Predecessors[t2,t1]==1],
            x[t1] + Duration[t1] - y[t1] <= x[t2]
            )

@constraint(schedule, 
            sum(OverTimePay[t]*y[t] for t=1:T) <= Budget)

# Solving
optimize!(schedule)
println("Termination Status: $(termination_status(schedule))")

# Results
if termination_status(schedule) == MOI.OPTIMAL
    println("Results:")
    println("Objective: $(objective_value(schedule))")
    println("x: ", value.(x))
    println("y: ", value.(y))
    for t=1:T
        println("Task: ", Tasks[t], "\t starting day: ", value(x[t]), "\t Duration:\t", Duration[t])
    end
else
    println("No optimal solution")
end