using MatrixProfile
using CSV
using DataFrames
using TimeZones
using Plots


data = CSV.read("btcusdt-1h-since-2019.csv", DataFrame)
data.datetime = DateTime.(ZonedDateTime.(String.(data.datetime), "y-m-dTH:M:s+z"))
data = sort(data, order(:datetime))
data.return = [0; data[2:end, :close] ./ data[1:(end-1), :close]] .- 1
data = data[2:end, :]
mat = Float32.(data[!,2:end])

profile = matrix_profile(mat[1:1000,6], 100)
plot(profile)

k = 3
mot = motifs(profile, k; r=2, th=5)
plot(profile, mot)
# plot(mot) # Motifs can be plotted on their own for a different view.
