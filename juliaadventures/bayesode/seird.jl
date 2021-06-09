using DifferentialEquations, Plots

function corona!(du,u,p,t)
    S,E,I,R,N,D,C = u
    F, β0,α,κ,μ,σ,γ,d,λ = p
    du[1] = -β0*S*F/N - β(t,β0,D,N,κ,α)*S*I/N -μ*S # susceptible
    du[2] = β0*S*F/N + β(t,β0,D,N,κ,α)*S*I/N -(σ+μ)*E # exposed
    du[3] = σ*E - (γ+μ)*I # infected
    du[4] = γ*I - μ*R # removed (recovered + dead)
    du[5] = -μ*N # total population
    du[6] = d*γ*I - λ*D # severe, critical cases, and deaths
    du[7] = σ*E # +cumulative cases
end

β(t,β0,D,N,κ,α) = β0*(1-α)*(1-D/N)^κ
S0 = 14e6
u0 = [0.9*S0, 0.0, 0.0, 0.0, S0, 0.0, 0.0]
p = [10.0, 0.5944, 0.4239, 1117.3, 0.02, 1/3, 1/5,0.2, 1/11.2]
R0 = p[2]/p[7]*p[6]/(p[6]+p[5])
tspan = [0.0, 365.0]

prob = ODEProblem(corona!, u0, tspan, p)
@time sol = solve(prob, Tsit5())
plot(sol, vars=[2,3,4,6])

