library(ggplot2)
library(patchwork)

coin <- rbinom(1e4, 1, 0.5)
coin1 <- cumsum(coin) # cumsum of 1
coin0 <- (1:length(coin)) - coin1 # cumsum of 0
# plot(coin1 / coin0)
# plot(abs(coin1 - coin0))

mydf <- tibble(
    Epoch = seq_along(coin1), CumSum1 = coin1, CumSum0 = coin0, Ratio = coin1 / coin0,
    Diff = abs(coin1 - coin0)
)

p1 <- mydf %>% ggplot(aes(x = Epoch, y = Ratio)) +
    geom_point()
