# Allianz example
using SymbolicRegression
using SymbolicUtils
using CSV
using DataFrames

data = CSV.File("leadsspain.csv") |> DataFrame
xdata = data[:, Not(r"lead*|Date")]

X = Float32.(xdata |> Matrix |> transpose)
y = Float32.(data[:, :leadDisplay])
options = SymbolicRegression.Options(
    binary_operators=(+, *, /, -, ^),
    unary_operators=(tanh, log, ),
    npopulations=20
)

hallOfFame = EquationSearch(X, y, niterations=10, options=options, numprocs=4)

dominating = calculateParetoFrontier(X, y, hallOfFame, options)

eqn = node_to_symbolic(dominating[end].tree, options)

println(simplify(eqn))

# (0.14379884 + x32) * ((-1 * x3) + x4 + x6) * x32 * log_abs(x32) * (log_abs(x31 + (0.0128802 * x7)) ^ -1)


