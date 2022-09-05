# Normal function definitions

# Simple
f1(x) = 2*x

# Long form
function f2(x)
    2*x
end

# Anonymous
f3 = x -> 2*x

# Functor: This is the way flux operates with layers

struct LinearReg{T}
    intercept::T
    slope::T
end

function (lr::LinearReg)(x)
    lr.slope*x+lr.intercept
end

function (lr::LinearReg)()
    lr.intercept
end

function (lr::LinearReg)()
    a = 3
    b = 5
    if a >b
        return 3
    end
end

