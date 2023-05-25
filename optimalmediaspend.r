library(tibble)
library(dplyr)
library(ggplot2)
library(tidyr)
library(bammm)


pm <- 100
b <- 1000
mydf <- tibble(
    Investment = seq(0, 1000000, by = 10000),
    Radio = b * tanh(Investment / (0.2 * median(Investment))) + rnorm(length(Investment), 0, b / 10),
    OOH = b * tanh(Investment / (2 * median(Investment))) + rnorm(length(Investment), 0, b / 10),
    TV = b * tanh(Investment / (1 * median(Investment))) + rnorm(length(Investment), 0, b / 10)
)
mydflong <- mydf %>%
    pivot_longer(-Investment, names_to = "Media", values_to = "Effect")

mydflong %>%
    ggplot(aes(x = Investment, y = Effect, color = Media)) +
    # geom_smooth(method = lm, formula = y ~ tanh(x / 200000)) +
    geom_smooth() +
    geom_point() +
    theme_dracula()


# Fit data
loss <- function(p, media = "TV") {
    i <- mydf[["Investment"]]
    y <- mydf[[media]]
    sqrt(mean((y - p[1] * tanh(i / (median(i) * p[2])))^2))
}
loss(c(1000, 1), "TV")
restv <- optim(c(100, 3), loss, media = "TV")
resradio <- optim(c(100, 3), loss, media = "Radio")
resooh <- optim(c(100, 3), loss, media = "OOH")
pars <- list(TV = restv$par, Radio = resradio$par, OOH = resooh$par)

# Predict
predfn <- function(i, mi, p) tanh(i / (mi * p[[2]])) * p[[1]]
sapredfn <- \(x)  predfn(
    mydflong[["Investment"]][x],
    median(mydf[["Investment"]]),
    pars[[mydflong[["Media"]][x]]]
)
mydflong[["Pred"]] <- sapply(seq_len(nrow(mydflong)), FUN = sapredfn)
mydflong %>%
    ggplot(aes(x = Investment, y = Effect, color = Media)) +
    # geom_smooth(method = lm, formula = y ~ tanh(x / 200000)) +
    geom_point(aes(x = Investment, y = Pred)) +
    # geom_smooth() +
    geom_point() +
    theme_dracula()
