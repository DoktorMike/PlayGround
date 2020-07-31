using Distributions, Zygote, ForwardDiff

function g1(x)
   return logpdf(Normal(1.0, 1.0), x[1])
   1
end

function g2(x)
   return logpdf(Normal(1.0, 1.0), x[1])
end

Zygote.refresh()
Zygote.gradient(g1, [0.75])
Zygote.gradient(g2, [0.75])

function f1(x)
    return 3*x
    1
end

f2(x) = return 3*x

Zygote.refresh()
Zygote.gradient(f1, 1.0)
Zygote.gradient(f2, 1.0)

function h1(x)
    return 3 .* x[1]
    1
end

h2(x) = return 3 .* x[1]

ForwardDiff.gradient(h1, [1.0])
ForwardDiff.gradient(h2, [1.0])

