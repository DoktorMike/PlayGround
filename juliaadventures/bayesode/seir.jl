using DifferentialEquations
using Plots
using DataFrames
#using HDF5
using Turing


# SEIR model where R is not modeled since N = S+E+I+R is a constant
# In this implementation we set N=1
# β is the average number of contacts for a person multiplied by the probability
# of infecting a susceptible person
# σ is 1 / the average incubation period ~ 5 days for Covid-19?
# γ is the recovery rate or the reciprocal of the duration of the infection
# μ is the death rate which is set to equal the birth rate. For DK it's 61000/5800000 per year
function seir_ode(dY, Y, p, t)
    β, σ, γ, μ = p[1], p[2], p[3], p[4]
    S, E, I = Y[1], Y[2], Y[3]
    dY[1] = μ * (1 - S) - β * S * I
    dY[2] = β * S * I - (σ + μ) * E
    dY[3] = σ * E - (γ + μ) * I
end;

function seir(β, σ, γ, μ, tspan = (0.0, 100.0); S₀ = 0.99, E₀ = 0, I₀ = 0.01, R₀ = 0)
    par = [β, σ, γ, μ]
    init = [S₀, E₀, I₀]
    seir_prob = ODEProblem(seir_ode, init, tspan, par)
    sol = solve(seir_prob)
    R = ones(1, size(sol)[2]) - sum(sol, dims = 1)
    #plot(sol.t,[sol',R'],xlabel="Time",ylabel="Proportion")
    hcat(sol.t, sol[1, :], sol[2, :], sol[3, :], R')
end;

r0(β, σ, γ, μ) = (σ / (σ + μ)) * (β / (γ + μ));

# Danish numbers
res = seir(
    0.07 * 10,
    1 / 3,
    1 / 7,
    6e4 / (5.8e6 * 365),
    (0.0, 150.0),
    S₀ = 1 - 1.7e-7,
    E₀ = 0.0,
    I₀ = 1.7e-7,
)
plot(
    res[:, 1],
    res[:, 2:5],
    lab = ["Susceptible" "Exposed" "Infected" "Recovered"],
    xlabel = "Time",
    ylabel = "Proportion",
)
vline!([24], lab = "Today")
r0(0.08 * 10, 1 / 3, 1 / 7, 6e4 / (5.8e6 * 365))
resdf = hcat(res[:, 1], res[:, 2:5] * 5.8e6) |> DataFrame
names!(resdf, [:Day, :Susceptible, :Exposed, :Infected, :Recovered])
h5write("/tmp/seirdk.h5", "simulation/$a/babb", res)


#  ____                          ____  _____ ___ ____
# | __ )  __ _ _   _  ___  ___  / ___|| ____|_ _|  _ \
# |  _ \ / _` | | | |/ _ \/ __| \___ \|  _|  | || |_) |
# | |_) | (_| | |_| |  __/\__ \  ___) | |___ | ||  _ <
# |____/ \__,_|\__, |\___||___/ |____/|_____|___|_| \_\
#              |___/

using DifferentialEquations
using DataFrames
using DataFramesMeta
using CSV
using Turing
using Plots
using StatsPlots
using PrettyTables

data = CSV.read("csse_covid_19_time_series - 2021-02-07.csv", DataFrame)
data = CSV.File("csse_covid_19_time_series - 2021-04-24.csv") |> DataFrame
data = data[data.State .== "NA", :]
data = data[data.Country .== "Denmark", [:Date, :Confirmed, :Deaths, :Recovered, :Active]]
data = @transform(
    data,
    Confirmed = parse.(Float64, :Confirmed),
    Deaths = parse.(Float64, :Deaths),
    Recovered = parse.(Float64, :Recovered),
    Active = parse.(Float64, :Active)
)

p1 = scatter(data.Date, data.Recovered)
scatter!(p1, data.Date, data.Confirmed)
scatter!(p1, data.Date, data.Active)

function seirode(dy, y, p, t)
    N = 5.8e6
    Λ, β, σ, γ, μ = p
    S, E, I = y
    dy[1] = Λ * N - μ * S - (β * I * S) / N
    dy[2] = (β * I * S) / N - (μ + σ) * E
    dy[3] = σ * E - (γ + μ) * I
end

par = [6e4 / (5.8e6 * 365), 0.019 * 10, 1 / 3, 1 / 7, 6e4 / (5.8e6 * 365)]
init = [5.8e6, 0.0, 1.0]
tspan = (0.0, 381.0)
seir_prob = ODEProblem(seirode, init, tspan, par)
sol = solve(seir_prob, Tsit5(), saveat = 1.0)
#p1 = plot(sol)
p1 = scatter(sol.t, [ sol.u[i][3] for i in 1:length(sol.t)])
scatter!(p1, 1:length(data.Date), data.Active)

# SEIR model where R is not modeled since N = S+E+I+R is a constant
# In this implementation we set N=1
# β is the average number of contacts for a person multiplied by the probability
# of infecting a susceptible person
# σ is 1 / the average incubation period ~ 5 days for Covid-19?
# γ is the recovery rate or the reciprocal of the duration of the infection
# μ is the death rate which is set to equal the birth rate. For DK it's 61000/5800000 per year
function seir_ode(dY, Y, p, t)
    β, σ, γ, μ = p[1], p[2], p[3], p[4]
    S, E, I = Y[1], Y[2], Y[3]
    dY[1] = μ * (1 - S) - β * S * I
    dY[2] = β * S * I - (σ + μ) * E
    dY[3] = σ * E - (γ + μ) * I
end;

# Build a turing model around the ODE
Turing.setadbackend(:forwarddiff)

@model function fitseir(data, prob)
    σ2 ~ InverseGamma(2, 3)
    β ~ Normal(0.012 * 10, 0.006 * 10)
    #σ ~ Normal(1 / 3, 1 / 10)
    #γ ~ Normal(1 / 7, 1 / 20)
    #μ ~ Normal(6e4 / (5.8e6 * 365), 1e-6)
    #β = 0.07*10 
    σ = 1/2
    γ = 1/14
    μ = 6e4 / (5.8e6 * 365)
    p = [β, σ, γ, μ]
    rprob = remake(prob, p = p)
    predicted = solve(rprob, Tsit5(), saveat = 1.0)
    for i = 1:length(predicted)
        data[i] ~ Normal(predicted[i][3], σ2)
    end
end

#par = [0.012 * 10, 1 / 2, 1 / 14, 6e4 / (5.8e6 * 365)]
par = [0.12, 1 / 2, 1 / 14, 6e4 / (5.8e6 * 365)]
init = [1 - 1.7e-7, 0.0, 1.7e-7]
tspan = (0.0, 457.0)
seir_prob = ODEProblem(seir_ode, init, tspan, par)
sol = solve(seir_prob, Tsit5(), saveat = 1.0)
pl = scatter(sol.t, Array(data.Active)/5.8e6, ylim=[0,0.01])
plot!(pl, sol, w=2, legend=false)

model = fitseir(Array(data.Active)/5.8e6, seir_prob)
chain = sample(model, NUTS(0.65), MCMCThreads(), 1000, 4)

plot(chain)

# Plot the data we have
pl = scatter(sol.t, Array(data.Active)/5.8e6, ylim=[0, 0.01])
#pl = scatter(sol.t, Array(data.Active)/5.8e6)
chainarray = Array(chain)
for k in 1:300
    p = [chainarray[rand(1:4000), 1], 1/2, 1/14, 6e4/(5.8e6 * 365)]
    #p = [rand(Normal(0.7, 0.01)), 1/3, 1/7, 6e4/(5.8e6 * 365)]
    resol = solve(remake(seir_prob, p=p), Tsit5(), saveat=1.0)
    plot!(resol, alpha=0.1, color="#BBBBBB", legend=false)
end
plot!(sol, w=1, legend=false)


