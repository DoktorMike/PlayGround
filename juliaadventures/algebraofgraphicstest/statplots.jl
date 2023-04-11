using AlgebraOfGraphics
using DataFramesMeta
using CategoricalArrays
using StatsBase
using RDatasets
using GLMakie
GLMakie.activate!()

mydf = RDatasets.dataset("gamair", "wine")
mydf.category = zeros(size(mydf)[1]) .+ 1
mydf.category[24:end] .= 2
mydf.category = categorical(mydf.category)
mydf


## Histogram in 1 and 2 dimensions
data(mydf) * mapping(:"s.temp") * histogram() |> draw

data(mydf) * mapping(:"s.temp", :"w.rain") * histogram() |> draw

## Densities in 1 and 2 dimensions
data(mydf) * mapping(:"s.temp") * AlgebraOfGraphics.density() |> draw

data(mydf) * mapping(:"s.temp") * AlgebraOfGraphics.density() * visual(; color=(:blue, 0.75)) |> draw

data(mydf) * mapping(:"s.temp") * AlgebraOfGraphics.density() * visual(; color=("blue", 0.75)) |> draw

data(mydf) * mapping(:"s.temp", :"w.rain") * AlgebraOfGraphics.density() |> draw

# Here we lift the density to a third dimension as well as the color
draw(data(mydf) * mapping(:"s.temp", :"w.rain") * AlgebraOfGraphics.density() *
     visual(Surface); axis=(; type=Axis3))

draw(data(mydf) * mapping(:"s.temp", :"w.rain"; layout=:category) *
     AlgebraOfGraphics.density() *
     visual(Surface); axis=(; type=Axis3))

## Linear
data(mydf) * mapping(:"s.temp", :"w.rain") * linear() |> draw

data(mydf) * mapping(:"s.temp", :"w.rain") * (linear() + visual(Scatter)) |> draw

data(mydf) * mapping(:"s.temp", :"w.rain"; color = :category) * (linear() + visual(Scatter)) |> draw

data(mydf) * mapping(:"s.temp", :"w.rain"; color = :category) * (smooth() + visual(Scatter)) |> draw

data(mydf) * mapping(:"s.temp", :"w.rain"; color = :category) * (smooth() + visual(Scatter; markersize = 23)) |> draw

data(mydf) * mapping(:"s.temp", :"w.rain"; color = :category) * (smooth() + visual(Scatter; marker = '+', markersize = 23)) |> draw

data(mydf) * mapping(:"s.temp", :"w.rain"; color = :category) * (smooth(; degree = 5) + visual(Scatter; marker = '+', markersize = 23)) |> draw
