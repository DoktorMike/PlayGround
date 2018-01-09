#' ---
#' title : Boston Housing example 
#' author : Michael Green
#' date : January 10, 2018
#' ---

#' # Motivation
#'
#' I love new initiatives that tries to do something new and innovative. The relatively new language Julia is one of my favorite languages. It features a lot of good stuff in addition to being targeted towards computational people like me. I won't bore you with the details of the language itself but suffice it to say that we finally have a general purpose language where you don't have to compromise expressiveness with efficiency.

#' ## Prerequisites
#' 
#' When reading this it helps if you have a basic understanding of Neural networks and their mathematical properties. Mathwise, basic linear algebra will do for the majority of the post.
#'
#' # Short introductory example
#'
#' Instead of writing on and on about how cool this new language is I will just show you how quickly you can get a simple neural network up and running. The first example we will create is the BostonHousing dataset. This is baked into the deep learning library Knet. So let's start by fetching the data.

using Knet;
include(Knet.dir("data","housing.jl"));
x,y = housing();

#' Now that we have the data we also need to define the basic functions that will make up our network. We will start with the predict function where we define $\omega$ and $x$ as input. $\omega$ in this case is our parameters which is a 2 element array containing weights in the first element and biases in the second. The $x$ contains the dataset which in our case is a matrix of size 506x13, i.e., 506 observations and 13 covariates.

predict(ω, x) = ω[1] * x .+ ω[2];
loss(ω, x, y) = mean(abs2, predict(ω, x)-y);
lossgradient = grad(loss);

function train(ω, data; lr=0.01) 
    for (x,y) in data
        dω = lossgradient(ω, x, y)
        for i in 1:length(ω)
            ω[i] -= dω[i]*lr
        end
    end
    return ω
end;

#' Let's have a look at the first 5 variables of the data set.

using Plots;
using StatPlots;

include(Knet.dir("data","housing.jl"));
x,y = housing();
gr();
scatter(x', y[1,:], layout=(3,5), reg=true, size=(950,500))

#' Here's the training part of the script where we define and train a perceptron, i.e., a linear neural network on the Boston Housing dataset. We track the error every 10th epoch and register it in our DataFrame. 

using DataFrames
ω = Any[ 0.1*randn(1,13), 0.0 ];
errdf = DataFrame(Epoch=1:20, Error=0.0);
cntr = 1;
for i=1:200
    train(ω, [(x,y)])
    if mod(i, 10) == 0
        println("Epoch $i: $(round(loss(ω,x,y)))")
        errdf[cntr, :Epoch]=i
        errdf[cntr, :Error]=loss(ω,x,y)
        cntr+=1
    end
end

#' If you inspect the training error per epoch you'll see that the error steadily goes down but flattens out after around 150. This is when we have reached the minimum error we can achieve with this small model. The plot on the right hand side shows the correlation between the predicted house prices and the real observed ones. The fit is not bad but there are definitely outliers.

p1 = scatter(errdf[:,:Epoch], errdf[:,:Error], xlabel="Epoch", ylabel="Error")
p2 = scatter(predict(ω, x)', y', reg=true, xlabel="Predicted", ylabel="Observed")
plot(p1, p2, layout=(1,2), size=(950,500))

#' ## Increasing model complexity
#' Since we made a toy model before which basically was a simple multiple linear regression model, we will step into the land of deep learning. Well, we'll use two hidden layers instead of none. The way to go about this is actually ridiculously simple. Since we've written all code so far in Raw Julia except for the grad function, which comes from the AutoGrad package, we can readily extend the depth of our network. But before we move on let's save the network we trained from before.

ω1 = ω;

#' Now that that's out of the way the next thing we need to do is to define the weights of our network and thereby our new structure. We will build a neural network with 
#' - One input layer of size 13
#' - A hidden layer of size 64
#' - Another hidden layer of size 15
#' - A final output layer which will be our prediction
#' which will have way more parameters than needed to solve this, but we'll add all these parameters just for fun. We'll return to why this is a horrible idea later. Knowing the overall structure we can now define our new $\omega$. When you read it please bear in mind that we use a [weights,bias,weights,bias] structure.

ω = Any[0.1f0*randn(Float32,64,13), zeros(Float32,64,1),
        0.1f0*randn(Float32,15,64), zeros(Float32,15,1),
        0.1f0*randn(Float32,1,15),  zeros(Float32,1,1)]

#' The $\omega$ is not the only thing we need to fix. We also need a new prediction function. Now, instead of making it targeted towards our specific network, we will instead write one that works for any number of layers. It's given below. Notice the ReLu function in the hidden nodes. If you don't know why this is a good idea there are several papers that explains why in great detail. The short version is that it helps with the vanishing gradients problem in deep networks.

function predict(ω, x) 
    x = mat(x)
    for i=1:2:length(ω)-2
        x = relu.(ω[i]*x .+ ω[i+1])
    end
    return ω[end-1]*x .+ ω[end]
end

#' Regarding the loss and the gradient of the loss we use exactly the same code! No need for any changes. This is one of the AutoGrad's superpowers; It can differentiate almost any Julia function. The same is also true for our training function. It also doesn't change. Nor do the loop where we apply it. Cool stuff my friends. 

loss(ω, x, y) = mean(abs2, predict(ω, x)-y)
lossgradient = grad(loss)

errdf = DataFrame(Epoch=1:60, Error=0.0)
cntr = 1
for i=1:600
    train(ω, [(x,y)])
    if mod(i, 10) == 0
        errdf[cntr, :Epoch]=i
        errdf[cntr, :Error]=loss(ω,x,y)
        cntr+=1
    end
end

#' Let's then have a look at the naive performance shall we? We start out by showing the same plots as we did for the linear model. It might not be super obvious what happened, but the error went down by a lot.

p3 = scatter(errdf[:,:Epoch], errdf[:,:Error], xlabel="Epoch", ylabel="Error")
p4 = scatter(predict(ω, x)', y', reg=true, xlabel="Predicted", ylabel="Observed")
plot(p3, p4, layout=(1,2), size=(950,500))

#' But the interesting comparison is of course how much better the fit really was. We can show the correlation plots from both models next to each other. The correlation for the first model was `j print(round(cor(predict(ω1, x)', y'), 2))` while for our latest version it was `j print(round(cor(predict(ω, x)', y'), 2))`.

plot(p2, p4, layout=(1,2), size=(950,500))

#' As the complexity is probably high enough it makes sense to check if it's too flexible and have a validation run duing our fitting process. This is usually rather instructive when dealing with highly parameterized functions. We start by splitting our data set up in training and testing. 

xtrn, xtst = x[:, 1:400], x[:, 401:end]
ytrn, ytst = y[:, 1:400], y[:, 401:end]

ω = Any[0.1f0*randn(Float32,64,13), zeros(Float32,64,1),
        0.1f0*randn(Float32,15,64), zeros(Float32,15,1),
        0.1f0*randn(Float32,1,15),  zeros(Float32,1,1)]
errdf = DataFrame(Epoch=1:60, TrnError=0.0, ValError=0.0)
cntr = 1
for i=1:600
    train(ω, [(xtrn, ytrn)])
    if mod(i, 10) == 0
        errdf[cntr, :Epoch]=i
        errdf[cntr, :TrnError]=loss(ω,xtrn,ytrn)
        errdf[cntr, :ValError]=loss(ω,xtst,ytst)
        cntr+=1
    end
end

#' After doing the training we can inspect what happens with the training and validation error over time. What you are seeing is extremely typical for neural networks that are not regularized or treated in a Bayesian way. Initially both the training error and the validation error goes down. However, as the model gets better and better at fitting the traning set it gets worse at the validation set which is not part of the training. 

using StatPlots
@df errdf[5:60,:] plot(:Epoch, [:ValError, :TrnError], xlabel="Epoch", ylabel="Error", 
                       label=["Validation" "Training"], lw=3)

