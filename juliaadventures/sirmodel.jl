using DifferentialEquations
using Plots
using AutomaticDocstrings
using DataFrames
using HDF5

# SEIR model where R is not modeled since N = S+E+I+R is a constant
# In this implementation we set N=1
# β is the average number of contacts for a person multiplied by the probability
# of infecting a susceptible person
# σ is 1 / the average incubation period ~ 5 days for Covid-19?
# γ is the recovery rate or the reciprocal of the duration of the infection
# μ is the death rate which is set to equal the birth rate. For DK it's 61000/5800000 per year
function seir_ode(dY,Y,p,t)
    β, σ, γ, μ = p[1], p[2], p[3], p[4]
    S, E, I = Y[1], Y[2], Y[3]
    dY[1] = μ*(1-S)-β*S*I
    dY[2] = β*S*I-(σ+μ)*E
    dY[3] = σ*E - (γ+μ)*I
end;

function seir(β, σ, γ, μ, tspan=(0.0,100.0); S₀=0.99, E₀=0, I₀=0.01, R₀=0)
    par=[β, σ, γ, μ]
    init=[S₀, E₀, I₀]
    seir_prob = ODEProblem(seir_ode,init,tspan,par)
    sol=solve(seir_prob);
    R=ones(1,size(sol)[2])-sum(sol,dims=1);
    #plot(sol.t,[sol',R'],xlabel="Time",ylabel="Proportion")
    hcat(sol.t, sol[1,:], sol[2,:], sol[3,:], R')
end;

r0(β, σ, γ, μ) = (σ/(σ+μ))*(β/(γ+μ));

seir(0.16, 0.20, 0.077, 6e4/(5.8e6*365), (0.0, 100.0))

seir(0.16, 0.25, 0.077, 6e4/(5.8e6*365), (0.0, 100.0))

seir(0.5, 0.25, 0.077, 6e4/(5.8e6*365), (0.0, 100.0))

seir(0.5, 0.25, 0.077, 6e4/(5.8e6*365), (0.0, 100.0), S₀=1-1.7e-7, I₀=1.7e-7)

# Danish numbers
res = seir(0.07*10, 1/3, 1/7, 6e4/(5.8e6*365), (0.0, 150.0), S₀=1-1.7e-7, E₀=0.0, I₀=1.7e-7)
plot(res[:,1], res[:, 2:5], lab=["Susceptible" "Exposed" "Infected" "Recovered"], xlabel="Time", ylabel="Proportion")
vline!([24], lab="Today")
r0(0.08*10, 1/3, 1/7, 6e4/(5.8e6*365))
resdf = hcat(res[:,1],res[:,2:5]*5.8e6) |> DataFrame
names!(resdf, [:Day, :Susceptible, :Exposed, :Infected, :Recovered])
h5write("/tmp/seirdk.h5", "simulation/$a/babb", res)

βs = 0.1:0.05:0.9
σs = 0.1:0.05:0.9
γs = 0.1:0.05:0.9
params = reshape([ [β, σ, γ] for β=βs, σ=σs, γ=γs], length(βs)*length(σs)*length(γs))

rm("/tmp/seirdk.h5")
for i in 1:length(params)
    res = seir(params[i]..., 6e4/(5.8e6*365), (0.0, 150.0), S₀=1-1.7e-7, E₀=0.0, I₀=1.7e-7)
    R₀ = r0(params[i]..., 6e4/(5.8e6*365))
    h5write("/tmp/seirdk.h5", "simulation/$i/seirdata", res)
    h5write("/tmp/seirdk.h5", "simulation/$i/ro", R₀)
    h5write("/tmp/seirdk.h5", "simulation/$i/params", params[i])
end
