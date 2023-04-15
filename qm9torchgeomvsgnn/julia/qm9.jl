using GraphNeuralNetworks
using MLDatasets
using Graphs

data = TUDataset("QM9")


# From MLDatasets.Graphs to Graphs.jl
mlg = data.graphs[1]
s, t = mlg.edge_index
g = Graphs.Graph(mlg.num_nodes)
for (i, j) in zip(s, t)
    Graphs.add_edge!(g, i, j)
end
