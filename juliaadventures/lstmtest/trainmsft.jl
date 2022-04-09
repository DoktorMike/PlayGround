using Flux
using CSV
using DataFrames
using DataFramesMeta
using Statistics
using UnicodePlots

# Load and normalize the data
rawdata = CSV.read("msft.csv", DataFrame)
rawdata = @transform(rawdata, :Norm = (:Close .- :Low) ./ (:High .- :Low))

moddf = Float32.(rawdata[:, "Norm"])
#μ, σ = mean(moddf), std(moddf)
#moddf = (moddf .- μ) ./ σ

# Define model
#m = Chain(LSTM(10, 20), Dense(20, 1))
m = Flux.Chain(Dense(30, 40), GRU(40, 20), Dense(20, 1))
θ = params(m)

# Build training data
function makedata(price)
	X = [price[i:i+29] for i in 1:length(price)-29];
	Y = [price[i] for i in 30:length(price)];
	(X,Y)
end
trndata = makedata(moddf[1:3700])
valdata = makedata(moddf[3701:end])

function loss(X,Y)
	m(X[1])
	sum([abs2(m(x)[1] - y) for (x, y) in zip(X, Y)])
end

opt = ADAM(0.001)
for epoch in 1:150
	Flux.reset!(m)
	g = gradient(θ) do
		loss(trndata[1], trndata[2])
	end
	Flux.Optimise.update!(opt, θ, g)
	trnloss = loss(trndata[1], trndata[2])
	valloss = loss(valdata[1],valdata[2])
	println("Epoch $epoch: $trnloss, $valloss")
end

# Plot it
Flux.reset!(m)
#m.(trndata[1][(length(trndata[1])-100):end]);
m.(trndata[1]);
ŷ = [m(x)[1] for x in valdata[1]];
y = valdata[2]
scatterplot(ŷ, y, width = 80, height = 40)

p = lineplot(1:length(ŷ), y, width = 80, height = 40)
lineplot!(p, 1:length(ŷ), ŷ)

Flux.reset!(m)
m(trndata[1][1]);
ŷ = [m(x)[1] for x in trndata[1][1:100]];
y = trndata[2][1:100]
p = lineplot(1:length(ŷ), y, width = 80, height = 40)
lineplot!(p, 1:length(ŷ), ŷ)
