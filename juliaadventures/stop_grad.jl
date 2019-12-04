using Distributions
using Zygote

Zygote.refresh()
function testme(λ) # Does not work μ does not get correct gradients
    q = Distributions.Normal(λ[1], λ[2])
    x = rand(q) 
    @show x
    pdf(q, x)
end
function testme_drop(λ) # Works
    q = Distributions.Normal(λ[1], λ[2])
    x = rand(Zygote.dropgrad(q))
    @show x
    pdf(q, x)
end
function testme_reparam(λ) # Works
    q = Distributions.Normal(λ[1], λ[2])
    x = rand(Distributions.Normal(0, 1))*λ[2]+λ[1] 
    @show x
    pdf(Zygote.dropgrad(q), x)
end

gradient(x->testme(x), (3,2))
gradient(x->testme_drop(x), (3,2))
gradient(x->testme_reparam(x), (3,2))

# Testing gradient of pdf of q(x)~N(x|3, 2)
gradient(x->pdf(Distributions.Normal(x[1],x[2]), 2), (3,2))

