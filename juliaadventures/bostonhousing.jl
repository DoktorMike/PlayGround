using Knet
using DataFrames

predict(ω, x) = ω[1] * x .+ ω[2]
loss(ω, x, y) = mean(abs2, predict(ω, x)-y)
lossgradient = grad(loss)

function train(ω, data; lr=0.01) 
    for (x,y) in data
        dω = lossgradient(ω, x, y)
        for i in 1:length(ω)
            ω[i] -= dω[i]*lr
        end
    end
    return ω
end

include(Knet.dir("data","housing.jl"))
x,y = housing()
ω = Any[ 0.1*randn(1,13), 0.0 ]
errdf = DataFrame(Epoch=1:10, Error=0.0)
cntr = 1
for i=1:100
    train(ω, [(x,y)])
    if mod(i, 10) == 0
        println("Epoch $i: $(loss(ω,x,y))")
        errdf[cntr, :Epoch]=i
        errdf[cntr, :Error]=loss(ω,x,y)
        cntr+=1
    end
end

display(errdf)

# MLP Instead
ω = Any[0.1f0*randn(Float32,64,13), zeros(Float32,64,1),
        0.1f0*randn(Float32,15,64), zeros(Float32,15,1),
        0.1f0*randn(Float32,1,15),  zeros(Float32,1,1)]

function predict(ω, x) 
    x = mat(x)
    for i=1:2:length(ω)-2
        x = relu.(ω[i]*x .+ ω[i+1])
    end
    return ω[end-1]*x .+ ω[end]
end

loss(ω, x, y) = mean(abs2, predict(ω, x)-y)
lossgradient = grad(loss)

errdf = DataFrame(Epoch=1:60, Error=0.0)
cntr = 1
for i=1:600
    train(ω, [(x,y)])
    if mod(i, 10) == 0
        println("Epoch $i: $(loss(ω,x,y))")
        errdf[cntr, :Epoch]=i
        errdf[cntr, :Error]=loss(ω,x,y)
        cntr+=1
    end
end


