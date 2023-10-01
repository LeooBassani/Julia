import Pkg
Pkg.add("DataStructures")
using DataStructures

# Cretaing a function
function dijkstra(graph, start)
    # Create an array to store distances to vertices
    distances = Dict(v => Inf for v in keys(graph))
    distances[start] = 0
    
    # Create an array to keep track of visited vertices
    visited = Set()
    
    while true
        # Find the vertex with the smallest distance that has not been visited
        min_vertex = nothing
        min_distance = Inf
        for (vertex, distance) in distances
            if !(vertex in visited) && distance < min_distance
                min_vertex = vertex
                min_distance = distance
            end
        end
        
        # If all vertices have been visited or are unreachable, exit the loop
        if min_vertex === nothing || min_distance == Inf
            break
        end
        
        # Mark the current vertex as visited
        push!(visited, min_vertex)
        
        # Update distances to neighboring vertices
        for (neighbor, weight) in graph[min_vertex]
            new_distance = distances[min_vertex] + weight
            if new_distance < distances[neighbor]
                distances[neighbor] = new_distance
            end
        end
    end
    
    return distances
end

# Exercise
graph = Dict(
    "A" => [("B", 4), ("D", 2)],
    "B" => [("C", 8), ("E", 5)],
    "C" => [],
    "D" => [("B", 1), ("E", 7), ("G", 3)],
    "E" => [("C", 1), ("F", 4)],
    "F" => [("C", 3)],
    "G" => [("F", 2)]
)

start_vertex = "A"
result = dijkstra(graph, start_vertex)
println("Shortest path from $start_vertex: ")
for (vertex, distance) in result
    println("$vertex: $distance")
end