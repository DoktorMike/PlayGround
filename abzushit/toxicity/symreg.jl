using SymbolicRegression
using SymbolicUtils
using CSV
using DataFrames


mydf = CSV.read("trndf.csv", DataFrame)
# x1: lna5p, x2: lna3p, x3: lnacount, x4: aso_len, x5: dnacount
X = Matrix(Float32.(mydf[:, 6:10]))'
y = Float32.(mydf[:, :too_toxic])

#X = randn(Float32, 5, 100)
#y = 2 * cos.(X[4, :]) + X[1, :] .^ 2 .- 2

sigmoid(x) = 1 / (1 + exp(-x))

options = SymbolicRegression.Options(
    binary_operators=(+, *, /, -, ^),
    unary_operators=(exp, cos, sigmoid),
    npopulations=20
)

hallOfFame = EquationSearch(X, y, niterations=20, options=options, numprocs=4)

dominating = calculateParetoFrontier(X, y, hallOfFame, options)
eqn = node_to_symbolic(dominating[end].tree, options)
println(simplify(eqn))
