library(tibble)
library(dplyr)
library(ggplot2)

# Main function
# y is response and x is variable you want elasticity for
elasticity <- function(y, x) {
  tmpdf <- tibble::tibble(y = y, x = x)
  mylm <- lm(log(y) ~ log(x), data = tmpdf)
  coef(mylm)[2]
}

# Example
mydf <- tibble(
  x = c(rep(100, 10), rep(150, 20), rep(120, 5), rep(110, 10)),
  y = x**(-3.5) * exp(20) * rnorm(length(x), 1, 0.05)
)
mydf %>% ggplot(aes(x = x, y = y)) +
  geom_point() +
  # scale_x_log10() +
  # scale_y_log10() +
  theme_minimal()
myelasticity <- elasticity(mydf[["y"]], mydf[["x"]])
print(paste0("Found elasticity: ", round(myelasticity, 2)))



# example Effect in percent in REAL space
r <- function(p, b = -0.5) b * log(p)
ch <- function(cp = 0.01) exp(r(100 * (1 + cp))) / exp(r(100)) - 1
curve(ch(x), -0.9, 0.9,
  xlab = "Change in real price in percent",
  ylab = "Change in response in percent in real space"
)

# example Effect in percent in log space
r <- function(p, b = -0.5) b * log(p)
ch <- function(cp = 0.01) (r(100 * (1 + cp))) / (r(100)) - 1
curve(ch(x), -0.9, 0.9,
  xlab = "Change in real price in percent",
  ylab = "Change in response in percent in log space"
)


# uncertainty for action governed by p
# q is probability of the other action
myf <- function(q, p) (q - p**2 + 1) / 2
p <- q <- seq(0, 1, 0.001)
z <- outer(q, p, myf)
# persp(q, p, z, phi = 30, theta = 50)
image(q, p, z)
contour(z, add = TRUE)
