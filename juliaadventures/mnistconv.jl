using Knet
using Plots
using StatPlots

# Define necessary functions
function predict(w, x0)
    x1 = pool(relu.(conv4(w[1],x0) .+ w[2]))
    x2 = pool(relu.(conv4(w[3],x1) .+ w[4]))
    x3 = relu.(w[5]*mat(x2) .+ w[6])
    return w[7]*x3 .+ w[8]
end

loss(ω, x, ygold) = nll(predict(ω, x), ygold)

lossgradient = grad(loss)

function train(model, data, optim)
    for (x,y) in data
        grads = lossgradient(model,x,y)
        update!(model, grads, optim)
    end
end

# Load the data
include(Knet.dir("data","mnist.jl"))
xtrn, ytrn, xtst, ytst = mnist()
dtrn = minibatch(xtrn, ytrn, 100)
dtst = minibatch(xtst, ytst, 100)

# Initialise neural network
ω = Any[xavier(Float32, 5, 5, 1, 20),  zeros(Float32, 1, 1, 20, 1),
        xavier(Float32, 5, 5, 20, 50), zeros(Float32, 1, 1, 50, 1),
        xavier(Float32, 500, 800),     zeros(Float32, 500, 1),
        xavier(Float32, 10, 500),      zeros(Float32, 10, 1) ]

o = optimizers(ω, Adam)
println((:epoch, 0, :trn, accuracy(ω, dtrn, predict), :tst, accuracy(ω, dtst, predict)))
for epoch=1:10
    train(ω, dtrn, o)
    println((:epoch, epoch, :trn, accuracy(ω, dtrn, predict), :tst, accuracy(ω, dtst, predict)))
end


