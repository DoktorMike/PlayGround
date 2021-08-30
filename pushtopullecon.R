# X is Distribution in number of Sales people
# Y is all other factors than can result in numbers from -inf to +inf  it can be Marketing plus Price plus whatever
# The plot shows the effect from 0 to 1 where Red is 1 and white is 0
x <- seq(0, 100, 1)
y <- seq(-4, 3, 0.02)
z <- outer(x, y, function(xx, yy) 1 / (1 + exp(-yy) / (xx**0.5)))
image(x, y, z)
contour(x, y, z, add = T)

persp(x, y, z, phi = -15, lphi = -50, theta = 30, ltheta = 50, col = "green")
