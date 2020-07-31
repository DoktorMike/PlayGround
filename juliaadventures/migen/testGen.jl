using Gen

@gen function foo(prob::Float64)
    z1 = @trace(bernoulli(prob), :a)
    z2 = @trace(bernoulli(prob), :b)
    return z1 || z2
end

xs = rand(5)
ys = rand(5)
server = VizServer(8000)
viz = Viz(server, joinpath(@__DIR__, "vue/dist"), 
          Dict("xs" => xs, "ys" => ys, "num" => length(xs), 
               "xlim" => [minimum(xs), maximum(xs)],
               "ylim" => [minimum(ys), maximum(ys)]))
openInBrowser(viz)
