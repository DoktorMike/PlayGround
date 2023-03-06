using RxInfer
using Random
using Plots

ns = rand(Binomial(300, 0.3), 100)
trueθ = [0.3, 0.5, 0.2] # detractors, neutral, promoters
dataset = float.([rand(Multinomial(ns[i], trueθ)) for i in eachindex(ns)])
#dataset = reduce(hcat, dataset)

struct MyMultinomial end 

@node Multinomial Stochastic [ out, n, p ]

# GraphPPL.jl export `@model` macro for model specification
# It accepts a regular Julia function and builds an FFG under the hood
@model function npsmodel(n)
    # `datavar` creates data 'inputs' in our model
    # We will pass data later on to these inputs
    # In this example we create a sequence of inputs that accepts Float64
    #y = datavar(Float64, n)
    #y = datavar(Float64, m, n)
    y = datavar(Vector{Float64}, n)
    # We endow θ parameter of our model with some prior
    θ ~ Dirichlet([10, 10, 10])
    # We assume that outcome of each coin flip 
    # is governed by the Bernoulli distribution
    for i in 1:n
        y[i] ~ Multinomial(sum(y[i]), θ)
    end
end

result = inference(
    model=npsmodel(size(dataset, 1)),
    data=(y=dataset,)
)

estθ = result.posteriors[:θ]

rθ = range(0, 1, length=1000)
p = plot(title="Inference results")
plot!(rθ, (x) -> pdf(Beta(2.0, 7.0), x), fillalpha=0.3, fillrange=0, label="P(θ)", c=1,)
plot!(rθ, (x) -> pdf(estθ, x), fillalpha=0.3, fillrange=0, label="P(θ|y)", c=3)
vline!([trueθ], label="Real θ")

