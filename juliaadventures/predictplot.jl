using BayesianLinearRegression
using CSV
using DataFrames
using LinearAlgebra
using UnicodePlots


function genfakedata()
    # Prepare data which consists of 5 input x1-x5 and 6 outputs y1-y6
    # In the end we add a bias x6
    # myloc = joinpath(dirname(pathof(MyPkg)), "..", "data")
    myloc = "./data/fake_series_alviss.csv"
    df = CSV.File(myloc) |> DataFrame!
    X = df[:,2:6]
    Y = df[:,7:12]
    X[:,:x6] .= 1.0
    X = Matrix(X)
    Y = Matrix(Y)
    return Y, X
end

function genfpred(Y,X)
    k, m = size(X)[2], size(Y)[2]
    B₀ = zeros(k, m)
    Λ₀ = Matrix{Float64}(I*2, k, k)
    V₀ = Matrix{Float64}(I*2, m, m)
    ν₀ = 1
    f = BayesianLinearRegression.generatepredictfn(Y,X,Λ₀,V₀,ν₀,B₀)
    return f
end

Y, X = genfakedata()

f = genfpred(Y, X)

yy = f(X)
i = 1
p = lineplot(1:100, Y[:,i], width=80, height=30, color=:red)
lineplot!(p, 1:100, yy[:,i], color=:blue)

