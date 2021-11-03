# X is Distribution in number of Sales people
# Y is all other factors than can result in numbers from -inf to +inf  it can be Marketing plus Price plus whatever
# The plot shows the effect from 0 to 1 where Red is 1 and white is 0
x <- seq(0, 0.05, 0.001)
y <- seq(-0.5, 5, 0.1)
z <- outer(x, y, function(xx, yy) 1 / (1 + exp(-yy) / (xx**0.5)))
image(x, y, z)
contour(x, y, z, add = T)

persp(x, y, z, phi = 15, lphi = -30, theta = -50, ltheta = 50, col =  "#003781", ylab="Marketing levers", xlab = "Salesforce", zlab = "New policies")
