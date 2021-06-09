using Turing, Distributions, DifferentialEquations 

# Import MCMCChain, Plots, and StatsPlots for visualizations and diagnostics.
using MCMCChains, Plots, StatsPlots

# Set a seed for reproducibility.
using Random
Random.seed!(14);

# Disable Turing's progress meter for this tutorial.
#Turing.turnprogress(false)

using Logging
Logging.disable_logging(Logging.Warn)
LogLevel(1001)

function lotka_volterra(du,u,p,t)
  x, y = u
  α, β, γ, δ  = p
  du[1] = (α - β*y)x # dx =
  du[2] = (δ*x - γ)y # dy = 
end
p = [1.5, 1.0, 3.0, 1.0]
u0 = [1.0,1.0]
prob1 = ODEProblem(lotka_volterra,u0,(0.0,10.0),p)
sol = solve(prob1,Tsit5())
plot(sol)

# Add noise to the solution. this is our fake data! :)
sol1 = solve(prob1,Tsit5(),saveat=0.1)
odedata = Array(sol1) + 0.8 * randn(size(Array(sol1)))
plot(sol1, alpha = 0.3, legend = false); scatter!(sol1.t, odedata')

# Build a turing model around the ODE
Turing.setadbackend(:forwarddiff)

@model function fitlv(data, prob)
    σ ~ InverseGamma(2, 3)
    α ~ Truncated(Normal(1.5, 0.5), 0.5, 2.5)
    β ~ Truncated(Normal(1.2, 0.5), 0.0, 2.0)
    γ ~ Truncated(Normal(3.0, 0.5), 1.0, 4.0)
    δ ~ Truncated(Normal(1.0, 0.5), 0.0, 2.0)

    p = [α, β, γ, δ]
    rprob = remake(prob, p=p)
    predicted = solve(rprob, Tsit5(), saveat=0.1)

    for i in 1:length(predicted)
        data[:, i] ~ MvNormal(predicted[i], σ)
    end
end


model = fitlv(odedata, prob1)

#chain = mapreduce(c -> sample(model, NUTS(0.65), 1000), chainscat, 1:4)
chain = sample(model, NUTS(0.65), MCMCThreads(), 1000, 4)

plot(chain)

# Plot the data we have
pl = scatter(sol1.t, odedata')
chainarray = Array(chain)
for k in 1:300
    resol = solve(remake(prob1, p=chainarray[rand(1:3000), 1:4]), Tsit5(), saveat=0.1)
    plot!(resol, alpha=0.1, color="#BBBBBB", legend=false)
end
plot!(sol1, w=1, legend=false)


