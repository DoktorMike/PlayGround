using GLMakie

θ,ϕ = collect(0:π/24:2π), collect(0:π/24:π)
r = 900;
c = 400;
x = [r*sin(Φ)*cos(Θ) for Φ ∈ ϕ, Θ ∈ θ];
y = [r*sin(Φ)*sin(Θ) for Φ ∈ ϕ, Θ ∈ θ];
z = [r*cos(Φ) for Φ ∈ ϕ, Θ ∈ θ];

x1 = [c*sin(Φ)*cos(Θ) for Φ ∈ ϕ, Θ ∈ θ];
y1 = [c*sin(Φ)*sin(Θ) for Φ ∈ ϕ, Θ ∈ θ];
z1 = [c*cos(Φ) for Φ ∈ ϕ, Θ ∈ θ];

fig = Figure(resolution = (600,400))
ax = Axis3(fig[1,1], xlabel="x-label", ylabel = "y-label", zlabel = "z-label")
wireframe!(ax, x,y,z, color=:blue, transparency = true)
wireframe!(ax, x1,y1,z1, color =:green, transparency=true)
#surface!(ax, x,y,z, color=:blue, transparency = true)
#surface!(ax, x1,y1,z1, color =:green, transparency=true)
fig
