using Gen
using GenViz
using PyPlot

@gen function line_model(xs::Vector{Float64})
    n = length(xs)
    
    # We begin by sampling a slope and intercept for the line.
    # Before we have seen the data, we don't know the values of
    # these parameters, so we treat them as random choices. The
    # distributions they are drawn from represent our prior beliefs
    # about the parameters: in this case, that neither the slope nor the
    # intercept will be more than a couple points away from 0.
    slope = @trace(normal(0, 1), :slope)
    intercept = @trace(normal(0, 2), :intercept)
    
    # Given the slope and intercept, we can sample y coordinates
    # for each of the x coordinates in our input vector.
    for (i, x) in enumerate(xs)
        @trace(normal(slope * x + intercept, 0.1), (:y, i))
    end
    
    # The return value of the model is often not particularly important,
    # Here, we simply return n, the number of points.
    return n
end


xs = [-5., -4., -3., -.2, -1., 0., 1., 2., 3., 4., 5.]
n = line_model(xs)
println(n)


# Get the trace of the function
trace = Gen.simulate(line_model, (xs,))

# Get the arguments that was sent to the function during the trace
Gen.get_args(trace)

# Get the values of the random choices made
println(Gen.get_choices(trace))
choices = Gen.get_choices(trace)
println(choices[:slope])
println(choices[:intercept])
println(choices[(:y, 2)]) # Get the second value of why which is a consequence of xs[2]

# The values can be fetched from the trace too
println(trace[:slope])
trace[:slope]==choices[:slope]

# The return value of the function is also recorded
println(Gen.get_retval(trace)); # There are 11 values in xs!


function render_trace(trace; show_data=true)
    
    # Pull out xs from the trace
    xs = get_args(trace)[1]
    
    xmin = minimum(xs)
    xmax = maximum(xs)
    if show_data
        ys = [trace[(:y, i)] for i=1:length(xs)]
        
        # Plot the data set
        scatter(xs, ys, c="black")
    end
    
    # Pull out slope and intercept from the trace
    slope = trace[:slope]
    intercept = trace[:intercept]
    
    # Draw the line
    plot([xmin, xmax], slope *  [xmin, xmax] .+ intercept, color="black", alpha=0.5)
    ax = gca()
    ax[:set_xlim]((xmin, xmax))
    ax[:set_ylim]((xmin, xmax))
end;


function grid(renderer::Function, traces; ncols=6, nrows=3)
    figure(figsize=(16, 8))
    for (i, trace) in enumerate(traces)
        subplot(nrows, ncols, i)
        renderer(trace)
    end
end;

traces = [Gen.simulate(line_model, (xs,)) for _ in 1:10]
grid(render_trace, traces, ncols=5, nrows=2)

 
function infer_model(xs, ys, n, viz)
    constraints = choicemap()
    for (i, y) in enumerate(ys)
        constraints[(:y, i)] = y
    end
    (trace, _) = generate(line_model, (xs,), constraints)
    for i in 1:n
        putTrace!(viz, 1, trace_to_dict(trace))
        (trace, _) = metropolis_hastings(trace, select(:slope))
        (trace, _) = metropolis_hastings(trace, select(:intercept))
    end
    choices = get_choices(trace)
    return (choices[:slope], choices[:intercept])
end


xs = [-5., -4., -3., -.2, -1., 0., 1., 2., 3., 4., 5.]
ys = 1 .+ 3 .* xs .+ randn(length(xs))
infer_model(xs, ys, 10000)

server = VizServer(8000)
viz = Viz(server, joinpath(@__DIR__, "vue/dist"), Dict("xs" => xs, "ys" => ys, "num" => length(xs), "xlim" => [minimum(xs), maximum(xs)], "ylim" => [minimum(ys), maximum(ys)]))
openInBrowser(viz)

xs = [-5., -4., -3., -.2, -1., 0., 1., 2., 3., 4., 5.]
ys = 1 .+ 3 .* xs .+ randn(length(xs))
infer_model(xs, ys, 10000, viz)
