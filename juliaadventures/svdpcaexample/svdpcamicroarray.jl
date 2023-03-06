using LinearAlgebra
using Statistics
using DataFrames
using GLMakie
using CSV

# Load data and put in matrix and vector
mydf = CSV.read("data/ovarian.csv", DataFrame)
X = Matrix(mydf[:, Not(:Class)])
y = mydf[:, :Class]

# Do a PCA by Remove means from each column of X and performing and SVD on the
# resulting matrix
x̂ = [mean(X[:, i]) for i in 1:size(X, 2)]
B = X .- x̂'
U, Σ, Vₜ = svd(B)

pc1 = Vₜ[:, 1]' * X'
pc2 = Vₜ[:, 2]' * X'
pc3 = Vₜ[:, 3]' * X'

colors = [:blue, :magenta]
colors = [colors[i+1] for i in (y .== "Cancer")]
scatter(pc1[1, :], pc2[1, :], pc3[1, :], color=colors)
