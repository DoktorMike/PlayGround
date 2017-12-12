

# Long function definition
function sphere_vol(r)
    return 4/3*pi*r^3
end

pifun(r) = 2π*r

print(pifun(1))

# Short function definition
sphere2(x, y) = x*y
println(sphere2(2,3))

println(sphere_vol(3))

println(3pi)
println(3*pi)
println(3/4*pi)
println(3/4pi)
println(3/(4*pi))
println(3/(4pi))

println(π)

α=5
println(α)

println(Int('1'))
println("float(\"1\") = ", float("1"))
println("float('1') = ", float('1'))
println("Int(\"1\") = error")
println("Int('1') = ", Int('1'))

# Error handling

a=[]
# try, catch can be used to deal with errors as with many other languages
try
    a[3]=2
catch err
    showerror(STDOUT, err, backtrace());println()
end
println("Continuing after error")


