using Symbolics
using Plots
using ModelingToolkit
using DifferentialEquations

@variables x y

x^2 + y^2

# Partial derivatives are easy
Symbolics.derivative(x^2 + y^2, x)
Symbolics.derivative(x^2 + y^2, y)

# Gradients are easy
Symbolics.gradient(x^2 + y^2, [x, y])

# Replace parts of an equation
# Replace x by 2y
substitute(sin(x)^2 + 2*cos(x)^2, Dict(x => 2y))
# Replace x by scalar 1 which evaluates it
substitute(sin(x)^2 + 2*cos(x)^2, Dict(x => 1))

# Simplify
simplify(sin(x)^2 + 2 + cos(x)^2)

# Some simplification happsn immediately
2x -x

# Assignment of expressions
ex = sin(x)^2 + 2*cos(x)^2
ex/ex
ex*2

for i in 1:10
	print(i)
end

Symbolics.solve_for(4x*tanh(y/3)==0, [y])


# Solve an optimization

@variables x m β α

dfdx = Symbolics.derivative(β*tanh(x/α), x)

Symbolics.solve_for(dfdx > 1, [x])
