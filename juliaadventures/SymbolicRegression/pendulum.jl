using SymbolicRegression
using SymbolicUtils
using Plots

# The true Period in seconds for a pendulum
t(l, g) = 2π * √(l / g)

# Generate noisy measurements
X = rand(3, 100) * 100
y = t.(X[1,:], 9.82) .+ randn(100)/5
scatter(X[1,:], y)

# Set up search space
options = SymbolicRegression.Options(
    binary_operators=(+, *, /, -),
    unary_operators=(cos, exp, sqrt),
    npopulations=20
)

# Find the true equation
hallOfFame = EquationSearch(X, y, niterations=10, options=options, numprocs=4)

# Check the top ones
dominating = calculateParetoFrontier(X, y, hallOfFame, options)

# Get the best equation
eqn = node_to_symbolic(dominating[end].tree, options)
println(simplify(eqn))

# Turn it into a function
tt(x1) = sqrt_abs(-0.020584408 + (-4.0222845 * x1))
tt(x1) = 0.14141124 + sqrt_abs(-1.9897838 * (sqrt_abs(0.82935035) + (-2 * x1)))

# Plot the discovered one vs the truth
p = scatter(1:100, tt.(1:100))
scatter!(p, 1:100, t.(1:100, 9.82))




