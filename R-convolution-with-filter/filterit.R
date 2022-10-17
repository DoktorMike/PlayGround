library(tidyverse)

kernel <- c(1:6, 5:1)
kernel <- kernel / sum(kernel)
kernel
qplot(seq_along(kernel), kernel)

X <- matrix(0, nrow = 40, ncol = 3)
X[15, 1] <- 1
X[1, 2] <- 1
X[10, 3] <- 1

stats::filter(X, kernel, method = "convolution")
stats::filter(X, 0.5, method = "convolution")

cx <- stats::filter(X, kernel, method = "conv", sides = 1)
cx
cx %>% plot()
