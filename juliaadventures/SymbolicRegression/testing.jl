using SymbolicRegression
using SymbolicUtils

# Dummy problem
X = randn(Float32, 5, 100)
y = 2 .* cos.(X[3, :]) .+ abs.(X[1, :]) .^ 1.2f0

pow_abs(x, y) = abs(x)^y
options = SymbolicRegression.Options(
    binary_operators=(+, *, /, -, pow_abs),
    unary_operators=(cos, exp),
    npopulations=20
)

hallOfFame = EquationSearch(X, y, niterations=10, options=options, numprocs=4)
dominating = calculateParetoFrontier(X, y, hallOfFame, options)
eqn = node_to_symbolic(dominating[end].tree, options)
println(simplify(eqn))
println(simplify(eqn*5 + 3))

# Allianz Switzerland example
using SymbolicRegression
using SymbolicUtils
using CSV
using DataFrames

data = CSV.File("data/switzerlandmimdata.csv") |> DataFrame

X = Float32.(data[:, Not(:PoliciesPCB2C)] |> Matrix |> transpose)
y = Float32.(data[:, :PoliciesPCB2C])
options = SymbolicRegression.Options(
    binary_operators=(+, *, /, -),
    unary_operators=(tanh,),
    npopulations=20
)

hallOfFame = EquationSearch(X, y, niterations=10, options=options, numprocs=4)

dominating = calculateParetoFrontier(X, y, hallOfFame, options)

eqn = node_to_symbolic(dominating[end].tree, options)

println(simplify(eqn))



# Allianz Spain example
using SymbolicRegression
using SymbolicUtils
using CSV
using DataFrames

data = CSV.File("data/allianzes.csv") |> DataFrame

X = Float32.(data[:, Not(:KPI)] |> Matrix |> transpose)
y = Float32.(data[:, :KPI])
options = SymbolicRegression.Options(
    binary_operators=(+, *, /, -),
    unary_operators=(tanh,),
    npopulations=20
)

hallOfFame = EquationSearch(X, y, niterations=10, options=options, numprocs=4)

dominating = calculateParetoFrontier(X, y, hallOfFame, options)

eqn = node_to_symbolic(dominating[end].tree, options)

println(simplify(eqn))


# (x6 * (1.0 / ((-1.0 * x7) + x8))) + ((-1.0 * x5) * (1.0 / ((-1.0 * x7) + x8)))
# Comp * (1/((-1 * Distribution) + Brand)) + ((-1*MediaOnline) * (1 / ((-1*Distribution) + Brand)))
#


## Push to pull ES

using SymbolicRegression
using SymbolicUtils
using CSV
using DataFrames

data = CSV.File("data/p2pspaintiedagents.csv") |> DataFrame
X = data[:, [:CommissionsPureCommission, :BrandPC, :MediaOffline, :MediaOnline, :Price, :Covid, :Cars, :GTrends, :Unemp]]
X = Float32.(Matrix(X)')
y = Float32.(data[:, :PoliciesNew])

options = SymbolicRegression.Options(
    binary_operators=(+, *, /, -),
    unary_operators=(tanh, exp, log),
    npopulations=20
)

hallOfFame = EquationSearch(X, y, niterations=10, options=options)

dominating = calculateParetoFrontier(X, y, hallOfFame, options)

eqn = node_to_symbolic(dominating[end].tree, options)

println(simplify(eqn))


# AIFeynman example
using SymbolicRegression
using SymbolicUtils
using CSV
using DataFrames
using DelimitedFiles

data = readdlm("./example1.txt", ' ', Float64)
inds = rand(1:10000, 100)
X = Float32.(data[inds, 1:3] |> transpose)
y = Float32.(data[inds, 4])

options = SymbolicRegression.Options(
    binary_operators=(+, *, /, -),
    unary_operators=(tanh, sqrt, exp, log, ),
    npopulations=20
)
hallOfFame = EquationSearch(X, y, niterations=10, options=options, numprocs=4)

dominating = calculateParetoFrontier(X, y, hallOfFame, options)

eqn = node_to_symbolic(dominating[end].tree, options)
println(simplify(eqn))


