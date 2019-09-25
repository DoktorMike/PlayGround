using Zygote
Zygote.refresh()

struct Dense
    β1
    β2
end

(m::Dense)(x) = x*m.β1.+m.β2

dm = Dense([2,3], 4)
dm([1 1])


gradient(dm->dm(x), dm)


ω = rand(3,2)
x = rand(2)
ω*x
gradient(ω -> sum(ω*x), ω)[1]


f(x) = 3*x+1

gradient(f, 2)

f'(3)



using Zygote
struct Linear
    W
    b
end
(l::Linear)(x) = l.W * x .+ l.b

model = Linear(rand(2, 5), rand(2))
x = rand(5)
dmodel = gradient(model -> sum(model(x)), model)[1]

function dummy()
    model = Linear(rand(2, 5), rand(2))
    x = rand(5)
    dmodel = gradient(model -> sum(model(x)), model)[1]
end

