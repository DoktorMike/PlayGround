using MXNet

#--------------------------------------------------------------------------------
# define lenet

# input
data = mx.Variable(:data)

# first conv
conv1 = @mx.chain mx.Convolution(data, kernel=(5,5), num_filter=20)  =>
mx.Activation(act_type=:tanh) =>
mx.Pooling(pool_type=:max, kernel=(2,2), stride=(2,2))

# second conv
conv2 = @mx.chain mx.Convolution(conv1, kernel=(5,5), num_filter=50) =>
mx.Activation(act_type=:tanh) =>
mx.Pooling(pool_type=:max, kernel=(2,2), stride=(2,2))

# first fully-connected
fc1   = @mx.chain mx.Flatten(conv2) =>
mx.FullyConnected(num_hidden=500) =>
mx.Activation(act_type=:tanh)

# second fully-connected
fc2   = mx.FullyConnected(fc1, num_hidden=10)

# softmax loss
lenet = mx.SoftmaxOutput(fc2, name=:softmax)


#--------------------------------------------------------------------------------
# load data
batch_size = 100
include("mnist-data.jl")
train_provider, eval_provider = get_mnist_providers(batch_size; flat=false)

#--------------------------------------------------------------------------------
# model
model = mx.FeedForward(lenet, context=mx.cpu())

# optimizer
optimizer = mx.SGD(lr=0.05, momentum=0.9, weight_decay=0.00001)

# fit parameters
mx.fit(model, optimizer, train_provider, n_epoch=10, eval_data=eval_provider)

# Visualize it
open("network.dot", "w") do f write(f, mx.to_graphviz(lenet)) end

#--------------------------------------------------------------------------------
# evaluate model

# predictions
probs = mx.predict(model, eval_provider)

# collect all labels from eval data
labels = Array[]
for batch in eval_provider
    push!(labels, copy(mx.get(eval_provider, batch, :softmax_label)))
end
labels = cat(1, labels...)

# Now we use compute the accuracy
correct = 0
for i = 1:length(labels)
    # labels are 0...9
    if indmax(probs[:,i]) == labels[i]+1
        correct += 1
    end
end
accuracy = 100correct/length(labels)
println(mx.format("Accuracy on eval set: {1:.2f}%", accuracy))

# find silly examples
outliers = []
for i = 1:length(labels)
    pred = indmax(probs[:,i])-1
    prob = maximum(probs[:,i])
    obs = labels[i]
    if pred != obs push!(outliers, [i, pred, obs, prob]) end
end

using DataFrames
using Plots
tmpdf=DataFrame(outliers)
scatter(convert(Array, tmpdf[2,:])', convert(Array, tmpdf[4,:])')
histogram(convert(Array, tmpdf[4,:])', xlims=(0,1), 
          xlabel="Likelihood", ylabel="Frequency")

# Save files
using JLD
save("mymxnetresults.jld", 
    # "model", model, "lenet", lenet, 
     "probs", probs, "labels", labels,
     "outliers", outliers, "tmpdf", tmpdf)

using JLD, DataFrames, Knet, MXNet, Plots
#model = load("mymxnetresults.jld", "model")
#lenet = load("mymxnetresults.jld", "lenet")
probs = load("mymxnetresults.jld", "probs")
labels = load("mymxnetresults.jld", "labels")
outliers = load("mymxnetresults.jld", "outliers")
tmpdf = load("mymxnetresults.jld", "tmpdf")

